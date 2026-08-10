class SupplyItem {
  final int? id;
  final String name;
  final String category; // Limpieza, Baño, Cocina, Mantenimiento, Varios
  final String unit; // Unidad, Rollo, Litro, Kg, Caja, Paquete, Botella
  final double currentStock;
  final double minStock;
  final double lastPurchasePrice;
  final String currency;
  final String? supplier;
  final int lastPurchaseDate;

  SupplyItem({
    this.id,
    required this.name,
    this.category = 'Limpieza',
    this.unit = 'Unidad',
    this.currentStock = 0.0,
    this.minStock = 5.0,
    this.lastPurchasePrice = 0.0,
    this.currency = 'USD',
    this.supplier,
    int? lastPurchaseDate,
  }) : lastPurchaseDate = lastPurchaseDate ?? DateTime.now().millisecondsSinceEpoch;

  bool get isLowStock => currentStock <= minStock;

  SupplyItem copyWith({
    int? id,
    String? name,
    String? category,
    String? unit,
    double? currentStock,
    double? minStock,
    double? lastPurchasePrice,
    String? currency,
    String? supplier,
    int? lastPurchaseDate,
  }) {
    return SupplyItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      lastPurchasePrice: lastPurchasePrice ?? this.lastPurchasePrice,
      currency: currency ?? this.currency,
      supplier: supplier ?? this.supplier,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'currentStock': currentStock,
      'minStock': minStock,
      'lastPurchasePrice': lastPurchasePrice,
      'currency': currency,
      'supplier': supplier,
      'lastPurchaseDate': lastPurchaseDate,
    };
  }

  factory SupplyItem.fromMap(Map<String, dynamic> map) {
    return SupplyItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String? ?? 'Limpieza',
      unit: map['unit'] as String? ?? 'Unidad',
      currentStock: (map['currentStock'] as num?)?.toDouble() ?? 0.0,
      minStock: (map['minStock'] as num?)?.toDouble() ?? 5.0,
      lastPurchasePrice: (map['lastPurchasePrice'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      supplier: map['supplier'] as String?,
      lastPurchaseDate: map['lastPurchaseDate'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  static const List<String> categories = ['Limpieza', 'Baño', 'Cocina', 'Mantenimiento', 'Varios'];
  static const List<String> units = ['Unidad', 'Rollo', 'Litro', 'Kg', 'Caja', 'Paquete', 'Botella'];
}

class InventoryMovementType {
  static const String purchase = 'COMPRA';
  static const String consumption = 'CONSUMO';
  static const String adjustment = 'AJUSTE';
  static const String waste = 'MERMA';
}

class InventoryMovement {
  final int? id;
  final int supplyItemId;
  final String movementType;
  final double quantity;
  final int date;
  final int? roomId;
  final int? reservationId;
  final String notes;

  InventoryMovement({
    this.id,
    required this.supplyItemId,
    required this.movementType,
    required this.quantity,
    int? date,
    this.roomId,
    this.reservationId,
    this.notes = '',
  }) : date = date ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplyItemId': supplyItemId,
      'movementType': movementType,
      'quantity': quantity,
      'date': date,
      'roomId': roomId,
      'reservationId': reservationId,
      'notes': notes,
    };
  }

  factory InventoryMovement.fromMap(Map<String, dynamic> map) {
    return InventoryMovement(
      id: map['id'] as int?,
      supplyItemId: map['supplyItemId'] as int,
      movementType: map['movementType'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      date: map['date'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      roomId: map['roomId'] as int?,
      reservationId: map['reservationId'] as int?,
      notes: map['notes'] as String? ?? '',
    );
  }
}
