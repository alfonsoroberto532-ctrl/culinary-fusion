enum MissionType {
  mergeCount,
  discoverRecipes,
  prepareRecipe,
  restoreElements,
  deliverOrders,
  earnCoins,
  discoverIngredients,
  unlockDecorations,
}

class Mission {
  final String id;
  final String description;
  final MissionType type;
  final String? targetId; // p.ej. una receta específica, si aplica
  final int targetCount;
  int progress;
  final int rewardCoins;
  final int rewardXp;
  bool claimed;

  Mission({
    required this.id,
    required this.description,
    required this.type,
    required this.targetCount,
    required this.rewardCoins,
    required this.rewardXp,
    this.targetId,
    this.progress = 0,
    this.claimed = false,
  });

  bool get isComplete => progress >= targetCount;

  Map<String, dynamic> toJson() =>
      {'id': id, 'progress': progress, 'claimed': claimed};

  void applySave(Map<String, dynamic> json) {
    progress = json['progress'] as int? ?? 0;
    claimed = json['claimed'] as bool? ?? false;
  }
}
