class Player {
  String name;
  int level;
  int xp;
  int coins;

  Player({this.name = 'Chef', this.level = 1, this.xp = 0, this.coins = 100});

  // XP necesaria para subir del nivel actual al siguiente.
  int get xpToNextLevel => 100 + (level - 1) * 50;

  void addXp(int amount) {
    xp += amount;
    while (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      level++;
    }
  }

  void addCoins(int amount) => coins += amount;

  bool spendCoins(int amount) {
    if (coins < amount) return false;
    coins -= amount;
    return true;
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'level': level, 'xp': xp, 'coins': coins};

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'] as String? ?? 'Chef',
        level: json['level'] as int? ?? 1,
        xp: json['xp'] as int? ?? 0,
        coins: json['coins'] as int? ?? 100,
      );
}
