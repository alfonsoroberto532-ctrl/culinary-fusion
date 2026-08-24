class DecorationItem {
  final String id;
  final String name;
  final String emoji;
  final String category; // mesas, sillas, lamparas, plantas...
  final int cost;
  bool unlocked;
  bool placed;

  DecorationItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.cost,
    this.unlocked = false,
    this.placed = false,
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'unlocked': unlocked, 'placed': placed};

  void applySave(Map<String, dynamic> json) {
    unlocked = json['unlocked'] as bool? ?? false;
    placed = json['placed'] as bool? ?? false;
  }
}
