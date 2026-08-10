class RoomStatus {
  static const String available = 'AVAILABLE';
  static const String reserved = 'RESERVED';
  static const String occupied = 'OCCUPIED';
  static const String cleaningPending = 'CLEANING_PENDING';
  static const String cleaning = 'CLEANING';
  static const String maintenance = 'MAINTENANCE';
}

enum RoomType {
  single('Individual', 'SINGLE'),
  double_('Doble Matrimonial', 'DOUBLE'),
  dormitory('Compartida / Litera', 'DORMITORY'),
  suite('Suite Premium', 'SUITE'),
  entireHouse('Casa / Propiedad Completa', 'ENTIRE_HOUSE');

  final String label;
  final String code;
  const RoomType(this.label, this.code);

  static RoomType fromCode(String code) {
    return RoomType.values.firstWhere(
      (t) => t.code.toUpperCase() == code.toUpperCase(),
      orElse: () => RoomType.double_,
    );
  }
}

class Room {
  final int? id;
  final String name;
  final String description;
  final int capacity;
  final double pricePerNight;
  final String currency;
  final String status;
  final String roomType;
  final bool isEntireProperty;
  final String features; // separadas por coma
  final String notes;
  final String? photoUri;

  Room({
    this.id,
    required this.name,
    this.description = '',
    this.capacity = 2,
    this.pricePerNight = 30.0,
    this.currency = 'USD',
    this.status = RoomStatus.available,
    this.roomType = 'DOUBLE',
    this.isEntireProperty = false,
    this.features = 'Aire Acondicionado, Baño Privado, Wi-Fi',
    this.notes = '',
    this.photoUri,
  });

  List<String> get featureList =>
      features.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Room copyWith({
    int? id,
    String? name,
    String? description,
    int? capacity,
    double? pricePerNight,
    String? currency,
    String? status,
    String? roomType,
    bool? isEntireProperty,
    String? features,
    String? notes,
    String? photoUri,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      roomType: roomType ?? this.roomType,
      isEntireProperty: isEntireProperty ?? this.isEntireProperty,
      features: features ?? this.features,
      notes: notes ?? this.notes,
      photoUri: photoUri ?? this.photoUri,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'pricePerNight': pricePerNight,
      'currency': currency,
      'status': status,
      'roomType': roomType,
      'isEntireProperty': isEntireProperty ? 1 : 0,
      'features': features,
      'notes': notes,
      'photoUri': photoUri,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      capacity: map['capacity'] as int? ?? 2,
      pricePerNight: (map['pricePerNight'] as num?)?.toDouble() ?? 30.0,
      currency: map['currency'] as String? ?? 'USD',
      status: map['status'] as String? ?? RoomStatus.available,
      roomType: map['roomType'] as String? ?? 'DOUBLE',
      isEntireProperty: (map['isEntireProperty'] as int? ?? 0) == 1,
      features: map['features'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      photoUri: map['photoUri'] as String?,
    );
  }
}
