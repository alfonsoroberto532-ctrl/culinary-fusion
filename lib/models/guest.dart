class Guest {
  final int? id;
  final String name;
  final String phone;
  final String nationality;
  final String documentId;
  final String notes;
  final int createdAt;

  Guest({
    this.id,
    required this.name,
    this.phone = '',
    this.nationality = '',
    this.documentId = '',
    this.notes = '',
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  Guest copyWith({
    int? id,
    String? name,
    String? phone,
    String? nationality,
    String? documentId,
    String? notes,
  }) {
    return Guest(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      documentId: documentId ?? this.documentId,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'nationality': nationality,
      'documentId': documentId,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory Guest.fromMap(Map<String, dynamic> map) {
    return Guest(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      nationality: map['nationality'] as String? ?? '',
      documentId: map['documentId'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
