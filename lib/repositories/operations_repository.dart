import '../db/db_helper.dart';
import '../models/operations.dart';
import '../models/room.dart';
import 'room_repository.dart';

class OperationsRepository {
  final _dbHelper = DBHelper.instance;
  final _roomRepo = RoomRepository();

  // ---- Limpieza ----

  Future<List<CleaningRecord>> getCleaningRecords({int? roomId}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'cleaning_records',
      where: roomId != null ? 'roomId = ?' : null,
      whereArgs: roomId != null ? [roomId] : null,
      orderBy: 'date DESC',
    );
    return rows.map((r) => CleaningRecord.fromMap(r)).toList();
  }

  /// Marca la habitación como en limpieza y crea el registro correspondiente.
  Future<int> startCleaning(int roomId) async {
    final db = await _dbHelper.database;
    await _roomRepo.updateStatus(roomId, RoomStatus.cleaning);
    return db.insert('cleaning_records', CleaningRecord(
      roomId: roomId,
      status: CleaningStatus.inProgress,
    ).toMap()..remove('id'));
  }

  /// Completa la limpieza: actualiza el registro y libera la habitación.
  Future<void> completeCleaning(int recordId, int roomId, {String productsUsed = '', String notes = ''}) async {
    final db = await _dbHelper.database;
    await db.update(
      'cleaning_records',
      {'status': CleaningStatus.completed, 'productsUsed': productsUsed, 'notes': notes},
      where: 'id = ?',
      whereArgs: [recordId],
    );
    await _roomRepo.updateStatus(roomId, RoomStatus.available);
  }

  /// Registra limpieza directa (sin flujo de "en progreso"), útil para marcar rápido.
  Future<void> quickCompleteCleaning(int roomId, {String notes = ''}) async {
    final db = await _dbHelper.database;
    await db.insert('cleaning_records', CleaningRecord(
      roomId: roomId,
      status: CleaningStatus.completed,
      notes: notes,
    ).toMap()..remove('id'));
    await _roomRepo.updateStatus(roomId, RoomStatus.available);
  }

  // ---- Mantenimiento ----

  Future<List<MaintenanceRecord>> getMaintenanceRecords({int? roomId, String? status}) async {
    final db = await _dbHelper.database;
    final conditions = <String>[];
    final args = <Object?>[];
    if (roomId != null) {
      conditions.add('roomId = ?');
      args.add(roomId);
    }
    if (status != null) {
      conditions.add('status = ?');
      args.add(status);
    }
    final rows = await db.query(
      'maintenance_records',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'reportedDate DESC',
    );
    return rows.map((r) => MaintenanceRecord.fromMap(r)).toList();
  }

  Future<int> reportIssue(MaintenanceRecord record) async {
    final db = await _dbHelper.database;
    final id = await db.insert('maintenance_records', record.toMap()..remove('id'));
    if (record.priority == MaintenancePriority.critical || record.priority == MaintenancePriority.high) {
      await _roomRepo.updateStatus(record.roomId, RoomStatus.maintenance);
    }
    await _dbHelper.logAudit('MAINTENANCE', id, 'CREATE', record.issue);
    return id;
  }

  Future<void> updateMaintenanceRecord(MaintenanceRecord record) async {
    final db = await _dbHelper.database;
    await db.update('maintenance_records', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> resolveMaintenance(int recordId, int roomId, {double cost = 0, String? technician}) async {
    final db = await _dbHelper.database;
    await db.update(
      'maintenance_records',
      {
        'status': MaintenanceStatus.resolved,
        'cost': cost,
        'technician': technician,
        'resolvedDate': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [recordId],
    );
    await _roomRepo.updateStatus(roomId, RoomStatus.available);
  }
}
