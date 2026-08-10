class ExchangeRate {
  final String currencyCode; // CUP, USD, EUR, CAD, etc.
  final double rateToPrimary; // cuántas unidades de esta moneda = 1 moneda base
  final int lastUpdated;

  ExchangeRate({
    required this.currencyCode,
    required this.rateToPrimary,
    int? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'currencyCode': currencyCode,
      'rateToPrimary': rateToPrimary,
      'lastUpdated': lastUpdated,
    };
  }

  factory ExchangeRate.fromMap(Map<String, dynamic> map) {
    return ExchangeRate(
      currencyCode: map['currencyCode'] as String,
      rateToPrimary: (map['rateToPrimary'] as num).toDouble(),
      lastUpdated: map['lastUpdated'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
