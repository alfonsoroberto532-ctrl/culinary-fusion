import '../db/db_helper.dart';
import '../models/reservation.dart';
import '../models/room.dart';
import 'room_repository.dart';
import 'guest_repository.dart';

class ReservationRepository {
  final _dbHelper = DBHelper.instance;
  final _roomRepo = RoomRepository();
  final _guestRepo = GuestRepository();

  Future<List<Reservation>> getAll({String? status}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'reservations',
      where: status != null ? 'status = ?' : null,
      whereArgs: status != null ? [status] : null,
      orderBy: 'checkInDate DESC',
    );
    return rows.map((r) => Reservation.fromMap(r)).toList();
  }

  Future<Reservation?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('reservations', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Reservation.fromMap(rows.first);
  }

  /// Comprueba si una habitación está libre en el rango de fechas dado
  /// (excluyendo, opcionalmente, la reserva actual al editar).
  Future<bool> isRoomAvailable({
    required int roomId,
    required int checkIn,
    required int checkOut,
    int? excludeReservationId,
  }) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'reservations',
      where: '''
        roomId = ?
        AND status != ?
        AND id != ?
        AND checkInDate < ?
        AND checkOutDate > ?
      ''',
      whereArgs: [
        roomId,
        ReservationStatus.cancelled,
        excludeReservationId ?? -1,
        checkOut,
        checkIn,
      ],
    );
    return rows.isEmpty;
  }

  Future<int> insert(Reservation reservation) async {
    final db = await _dbHelper.database;
    final map = reservation.toMap()..remove('id');
    final id = await db.insert('reservations', map);
    // Reserva confirmada -> habitación pasa a RESERVED si no está ocupada
    final room = await _roomRepo.getById(reservation.roomId);
    if (room != null && room.status == RoomStatus.available) {
      await _roomRepo.updateStatus(reservation.roomId, RoomStatus.reserved);
    }
    await _dbHelper.logAudit('RESERVATION', id, 'CREATE', 'Reserva creada');
    return id;
  }

  Future<void> update(Reservation reservation) async {
    final db = await _dbHelper.database;
    await db.update('reservations', reservation.toMap(), where: 'id = ?', whereArgs: [reservation.id]);
    await _dbHelper.logAudit('RESERVATION', reservation.id!, 'UPDATE', 'Reserva actualizada');
  }

  Future<void> checkIn(int reservationId) async {
    final res = await getById(reservationId);
    if (res == null) return;
    await update(res.copyWith(status: ReservationStatus.checkedIn));
    await _roomRepo.updateStatus(res.roomId, RoomStatus.occupied);
  }

  Future<void> checkOut(int reservationId) async {
    final res = await getById(reservationId);
    if (res == null) return;
    await update(res.copyWith(status: ReservationStatus.checkedOut));
    await _roomRepo.updateStatus(res.roomId, RoomStatus.cleaningPending);
  }

  Future<void> cancel(int reservationId) async {
    final res = await getById(reservationId);
    if (res == null) return;
    await update(res.copyWith(status: ReservationStatus.cancelled));
    final room = await _roomRepo.getById(res.roomId);
    if (room != null && room.status == RoomStatus.reserved) {
      await _roomRepo.updateStatus(res.roomId, RoomStatus.available);
    }
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete('reservations', where: 'id = ?', whereArgs: [id]);
    await _dbHelper.logAudit('RESERVATION', id, 'DELETE', 'Reserva eliminada');
  }

  // ---- Pagos ----

  Future<List<Payment>> getPayments(int reservationId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'payments',
      where: 'reservationId = ?',
      whereArgs: [reservationId],
      orderBy: 'date DESC',
    );
    return rows.map((r) => Payment.fromMap(r)).toList();
  }

  Future<int> addPayment(Payment payment) async {
    final db = await _dbHelper.database;
    final map = payment.toMap()..remove('id');
    final id = await db.insert('payments', map);
    await _dbHelper.logAudit(
      'PAYMENT',
      id,
      'CREATE',
      'Pago de ${payment.amount} ${payment.currency} registrado',
    );
    return id;
  }

  Future<void> deletePayment(int id) async {
    final db = await _dbHelper.database;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Vista enriquecida ----

  Future<ReservationWithDetails?> getWithDetails(int reservationId) async {
    final reservation = await getById(reservationId);
    if (reservation == null) return null;
    final guest = await _guestRepo.getById(reservation.guestId);
    final room = await _roomRepo.getById(reservation.roomId);
    if (guest == null || room == null) return null;
    final payments = await getPayments(reservationId);
    final relatedExpenses = await _relatedExpensesTotal(reservationId);
    return ReservationWithDetails(
      reservation: reservation,
      guest: guest,
      room: room,
      payments: payments,
      relatedExpensesTotal: relatedExpenses,
    );
  }

  Future<List<ReservationWithDetails>> getAllWithDetails({String? status}) async {
    final reservations = await getAll(status: status);
    final result = <ReservationWithDetails>[];
    for (final r in reservations) {
      final guest = await _guestRepo.getById(r.guestId);
      final room = await _roomRepo.getById(r.roomId);
      if (guest == null || room == null) continue;
      final payments = await getPayments(r.id!);
      final relatedExpenses = await _relatedExpensesTotal(r.id!);
      result.add(ReservationWithDetails(
        reservation: r,
        guest: guest,
        room: room,
        payments: payments,
        relatedExpensesTotal: relatedExpenses,
      ));
    }
    return result;
  }

  Future<double> _relatedExpensesTotal(int reservationId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE reservationId = ?',
      [reservationId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Reservas activas (confirmadas o con check-in hecho) que tocan hoy.
  Future<List<Reservation>> arrivalsToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = start + const Duration(days: 1).inMilliseconds;
    final db = await _dbHelper.database;
    final rows = await db.query(
      'reservations',
      where: 'checkInDate >= ? AND checkInDate < ? AND status = ?',
      whereArgs: [start, end, ReservationStatus.confirmed],
    );
    return rows.map((r) => Reservation.fromMap(r)).toList();
  }

  Future<List<Reservation>> departuresToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = start + const Duration(days: 1).inMilliseconds;
    final db = await _dbHelper.database;
    final rows = await db.query(
      'reservations',
      where: 'checkOutDate >= ? AND checkOutDate < ? AND status = ?',
      whereArgs: [start, end, ReservationStatus.checkedIn],
    );
    return rows.map((r) => Reservation.fromMap(r)).toList();
  }
}
