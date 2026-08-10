class CleaningStatus {
  static const String pending = 'PENDING';
  static const String inProgress = 'IN_PROGRESS';
  static const String completed = 'COMPLETED';
}

class CleaningRecord {
  final int? id;
  final int roomId;
  final int date;
  final String status;
  final String productsUsed;
  final String notes;

  CleaningRecord({
    this.id,
    required this.roomId,
    int? date,
    this.status = CleaningStatus.completed,
    this.productsUsed = '',
    this.notes = '',
  }) : date = date ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'date': date,
      'status': status,
      'productsUsed': productsUsed,
      'notes': notes,
    };
  }

  factory CleaningRecord.fromMap(Map<String, dynamic> map) {
    return CleaningRecord(
      id: map['id'] as int?,
      roomId: map['roomId'] as int,
      date: map['date'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      status: map['status'] as String? ?? CleaningStatus.completed,
      productsUsed: map['productsUsed'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }
}

class MaintenancePriority {
  static const String low = 'LOW';
  static const String medium = 'MEDIUM';
  static const String high = 'HIGH';
  static const String critical = 'CRITICAL';

  static String label(String v) {
    switch (v) {
      case low:
        return 'Baja';
      case medium:
        return 'Media';
      case high:
        return 'Alta';
      case critical:
        return 'Crítica';
      default:
        return v;
    }
  }
}

class MaintenanceStatus {
  static const String pending = 'PENDING';
  static const String inRepair = 'IN_REPAIR';
  static const String resolved = 'RESOLVED';

  static String label(String v) {
    switch (v) {
      case pending:
        return 'Pendiente';
      case inRepair:
        return 'En Reparación';
      case resolved:
        return 'Resuelto';
      default:
        return v;
    }
  }
}

class MaintenanceRecord {
  final int? id;
  final int roomId;
  final String issue;
  final String priority;
  final String status;
  final double cost;
  final String currency;
  final String? technician;
  final int reportedDate;
  final int? resolvedDate;
  final String notes;

  MaintenanceRecord({
    this.id,
    required this.roomId,
    required this.issue,
    this.priority = MaintenancePriority.medium,
    this.status = MaintenanceStatus.pending,
    this.cost = 0.0,
    this.currency = 'USD',
    this.technician,
    int? reportedDate,
    this.resolvedDate,
    this.notes = '',
  }) : reportedDate = reportedDate ?? DateTime.now().millisecondsSinceEpoch;

  MaintenanceRecord copyWith({
    String? status,
    double? cost,
    String? technician,
    int? resolvedDate,
    String? notes,
  }) {
    return MaintenanceRecord(
      id: id,
      roomId: roomId,
      issue: issue,
      priority: priority,
      status: status ?? this.status,
      cost: cost ?? this.cost,
      currency: currency,
      technician: technician ?? this.technician,
      reportedDate: reportedDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'issue': issue,
      'priority': priority,
      'status': status,
      'cost': cost,
      'currency': currency,
      'technician': technician,
      'reportedDate': reportedDate,
      'resolvedDate': resolvedDate,
      'notes': notes,
    };
  }

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      id: map['id'] as int?,
      roomId: map['roomId'] as int,
      issue: map['issue'] as String,
      priority: map['priority'] as String? ?? MaintenancePriority.medium,
      status: map['status'] as String? ?? MaintenanceStatus.pending,
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      technician: map['technician'] as String?,
      reportedDate: map['reportedDate'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      resolvedDate: map['resolvedDate'] as int?,
      notes: map['notes'] as String? ?? '',
    );
  }
}
