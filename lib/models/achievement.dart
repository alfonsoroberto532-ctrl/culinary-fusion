class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  bool unlocked;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.unlocked = false,
  });

  Map<String, dynamic> toJson() => {'id': id, 'unlocked': unlocked};

  void applySave(Map<String, dynamic> json) {
    unlocked = json['unlocked'] as bool? ?? false;
  }
}
