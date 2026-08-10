import 'guest.dart';

class ReservationStatus {
  static const String confirmed = 'CONFIRMED';
  static const String checkedIn = 'CHECKED_IN';
  static const String checkedOut = 'CHECKED_OUT';
  static const String cancelled = 'CANCELLED';

  static String label(String status) {
    switch (status) {
      case confirmed:
        return 'Confirmada';
      case checkedIn:
        return 'Check-In Hecho';
      case checkedOut:
        return 'Check-Out Hecho';
      case cancelled:
        return 'Cancelada';
      default:
        return status;
    }
  }
}

class Reservation {
  final int? id;
  final int guestId;
  final int roomId;
  final int checkInDate; // epoch millis
  final int checkOutDate; // epoch millis
  final String checkInTime;
  final String checkOutTime;
  final int guestCount;
  final double pricePerNight;
  final double totalPrice;
  final double advancePayment;
  final String currency;
  final String status;
  final String notes;
  final int createdAt;

  Reservation({
    this.id,
    required this.guestId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    this.checkInTime = '14:00',
    this.checkOutTime = '11:00',
    this.guestCount = 1,
    this.pricePerNight = 0.0,
    this.totalPrice = 0.0,
    this.advancePayment = 0.0,
    this.currency = 'USD',
    this.status = ReservationStatus.confirmed,
    this.notes = '',
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  int get nights {
    final diff = checkOutDate - checkInDate;
    final days = diff ~/ (1000 * 60 * 60 * 24);
    return days > 0 ? days : 1;
  }

  Reservation copyWith({
    int? id,
    int? guestId,
    int? roomId,
    int? checkInDate,
    int? checkOutDate,
    String? checkInTime,
    String? checkOutTime,
    int? guestCount,
    double? pricePerNight,
    double? totalPrice,
    double? advancePayment,
    String? currency,
    String? status,
    String? notes,
  }) {
    return Reservation(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      roomId: roomId ?? this.roomId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      guestCount: guestCount ?? this.guestCount,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      totalPrice: totalPrice ?? this.totalPrice,
      advancePayment: advancePayment ?? this.advancePayment,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guestId': guestId,
      'roomId': roomId,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'guestCount': guestCount,
      'pricePerNight': pricePerNight,
      'totalPrice': totalPrice,
      'advancePayment': advancePayment,
      'currency': currency,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'] as int?,
      guestId: map['guestId'] as int,
      roomId: map['roomId'] as int,
      checkInDate: map['checkInDate'] as int,
      checkOutDate: map['checkOutDate'] as int,
      checkInTime: map['checkInTime'] as String? ?? '14:00',
      checkOutTime: map['checkOutTime'] as String? ?? '11:00',
      guestCount: map['guestCount'] as int? ?? 1,
      pricePerNight: (map['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      advancePayment: (map['advancePayment'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      status: map['status'] as String? ?? ReservationStatus.confirmed,
      notes: map['notes'] as String? ?? '',
      createdAt:
          map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class Payment {
  final int? id;
  final int reservationId;
  final double amount;
  final String currency;
  final double exchangeRateToPrimary;
  final int date;
  final String paymentType; // Adelanto, Pago Final, Parcial
  final String notes;

  Payment({
    this.id,
    required this.reservationId,
    required this.amount,
    this.currency = 'USD',
    this.exchangeRateToPrimary = 1.0,
    int? date,
    this.paymentType = 'Adelanto',
    this.notes = '',
  }) : date = date ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reservationId': reservationId,
      'amount': amount,
      'currency': currency,
      'exchangeRateToPrimary': exchangeRateToPrimary,
      'date': date,
      'paymentType': paymentType,
      'notes': notes,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      reservationId: map['reservationId'] as int,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      exchangeRateToPrimary:
          (map['exchangeRateToPrimary'] as num?)?.toDouble() ?? 1.0,
      date: map['date'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      paymentType: map['paymentType'] as String? ?? 'Adelanto',
      notes: map['notes'] as String? ?? '',
    );
  }
}

/// Reserva enriquecida con huésped, habitación y pagos — equivalente a
/// ReservationWithDetails del proyecto base.
class ReservationWithDetails {
  final Reservation reservation;
  final Guest guest;
  final dynamic room; // Room — tipado dynamic para evitar import circular
  final List<Payment> payments;
  final double relatedExpensesTotal;

  ReservationWithDetails({
    required this.reservation,
    required this.guest,
    required this.room,
    this.payments = const [],
    this.relatedExpensesTotal = 0.0,
  });

  int get nights => reservation.nights;

  double get totalPaid => payments.fold(0.0, (sum, p) => sum + p.amount);

  double get pendingBalance {
    final pending = reservation.totalPrice - totalPaid;
    return pending > 0 ? pending : 0.0;
  }

  double get netProfit => reservation.totalPrice - relatedExpensesTotal;

  double get profitMarginPercent => reservation.totalPrice > 0
      ? (netProfit / reservation.totalPrice) * 100
      : 0.0;
}
