class ExpenseCategory {
  final int? id;
  final String name;
  final String iconName;
  final bool isSystem;

  ExpenseCategory({
    this.id,
    required this.name,
    this.iconName = 'receipt',
    this.isSystem = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'isSystem': isSystem ? 1 : 0,
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconName: map['iconName'] as String? ?? 'receipt',
      isSystem: (map['isSystem'] as int? ?? 0) == 1,
    );
  }

  static const List<String> defaultCategories = [
    'Suministros',
    'Mantenimiento',
    'Servicios (Luz/Agua/Internet)',
    'Nómina',
    'Impuestos',
    'Marketing',
    'Otros',
  ];
}

class Expense {
  final int? id;
  final int date;
  final String categoryName;
  final String description;
  final double amount;
  final String currency;
  final double exchangeRateToPrimary;
  final int? roomId;
  final int? reservationId;
  final String? supplier;
  final String notes;

  Expense({
    this.id,
    int? date,
    required this.categoryName,
    required this.description,
    required this.amount,
    this.currency = 'USD',
    this.exchangeRateToPrimary = 1.0,
    this.roomId,
    this.reservationId,
    this.supplier,
    this.notes = '',
  }) : date = date ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'categoryName': categoryName,
      'description': description,
      'amount': amount,
      'currency': currency,
      'exchangeRateToPrimary': exchangeRateToPrimary,
      'roomId': roomId,
      'reservationId': reservationId,
      'supplier': supplier,
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      date: map['date'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      categoryName: map['categoryName'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      exchangeRateToPrimary: (map['exchangeRateToPrimary'] as num?)?.toDouble() ?? 1.0,
      roomId: map['roomId'] as int?,
      reservationId: map['reservationId'] as int?,
      supplier: map['supplier'] as String?,
      notes: map['notes'] as String? ?? '',
    );
  }
}
