import 'enums.dart';

/// Un generador (huerto, molino, horno, lechería, carnicería...).
/// Produce ingredientes de forma INMEDIATA al tocarlo, sin temporizadores.
/// Puede mejorar de nivel para desbloquear más variedad, nunca para
/// aumentar tiempos de espera (no existen tiempos de espera).
class Generator {
  final String id;
  final String name;
  final String emoji;
  final TreeId treeId;
  int level; // nivel actual del generador (empieza en 1)
  final int maxLevel;
  // Ingredientes que produce en cada nivel: nivel -> lista de ingredientIds posibles
  final Map<int, List<String>> productionByLevel;
  final Map<int, int> upgradeCostByLevel; // costo en monedas para subir AL nivel indicado

  Generator({
    required this.id,
    required this.name,
    required this.emoji,
    required this.treeId,
    required this.productionByLevel,
    required this.upgradeCostByLevel,
    this.level = 1,
    this.maxLevel = 4,
  });

  List<String> get availableIngredientIds => productionByLevel[level] ?? const [];

  bool get canUpgrade => level < maxLevel;

  int? get nextUpgradeCost => canUpgrade ? upgradeCostByLevel[level + 1] : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
      };

  void applySave(Map<String, dynamic> json) {
    level = json['level'] as int? ?? level;
  }
}
