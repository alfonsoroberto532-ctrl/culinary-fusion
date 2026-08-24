import 'enums.dart';

class Recipe {
  final String id;
  final String name;
  final String emoji;
  final String category; // pizzas, hamburguesas, pastas, postres, bebidas...
  final List<String> ingredientIds; // ingredientes/objetos requeridos (por id)
  final Rarity rarity;
  final int xpReward;
  final int coinReward;
  final bool isSecret; // no aparece en el libro hasta descubrirse
  final bool isLegendary;
  final String discoveryFlavorText; // frase mostrada al descubrirla

  // Estado mutable de progreso del jugador con esta receta
  int timesPrepared;
  int masteryStars; // 0-5, sube con veces preparada

  Recipe({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.ingredientIds,
    required this.rarity,
    required this.xpReward,
    required this.coinReward,
    this.isSecret = false,
    this.isLegendary = false,
    this.discoveryFlavorText = '¡Eso no estaba en el libro!',
    this.timesPrepared = 0,
    this.masteryStars = 0,
  });

  void registerPreparation() {
    timesPrepared++;
    // Cada 5 preparaciones sube una estrella de dominio, hasta 5.
    masteryStars = (timesPrepared ~/ 5).clamp(0, 5);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timesPrepared': timesPrepared,
        'masteryStars': masteryStars,
      };

  void applySave(Map<String, dynamic> json) {
    timesPrepared = json['timesPrepared'] as int? ?? 0;
    masteryStars = json['masteryStars'] as int? ?? 0;
  }
}
