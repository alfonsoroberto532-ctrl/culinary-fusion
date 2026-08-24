import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/game_state.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import '../theme/game_visuals.dart';

class RecipeBookScreen extends StatelessWidget {
  const RecipeBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final visible = gameState.recipeEngine.visibleInBook(gameState.discovery.discoveredRecipeIds);
    final byCategory = <String, List<Recipe>>{};
    for (final r in gameState.recipes) {
      byCategory.putIfAbsent(r.category, () => []).add(r);
    }

    return ListView(
      padding: const EdgeInsets.all(14),
      children: byCategory.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...entry.value.map((r) {
                final isVisible = visible.contains(r);
                final rarity = isVisible ? r.rarity : Rarity.comun;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: softCardDecoration(
                    radius: 16,
                    color: isVisible ? rarity.colorSoft : AppColors.surface,
                    borderColor: isVisible ? rarity.color.withValues(alpha: 0.35) : const Color(0xFFF0E1C4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: isVisible
                            ? GameVisual(assetPath: r.imagePath, emoji: r.emoji, size: 26)
                            : const Text('❓', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isVisible ? r.name : '???',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                            ),
                            const SizedBox(height: 2),
                            if (isVisible)
                              Row(
                                children: [
                                  Text('★' * r.rarity.stars, style: TextStyle(fontSize: 11, color: rarity.color)),
                                  Text('☆' * (5 - r.rarity.stars), style: const TextStyle(fontSize: 11, color: Color(0xFFD8CBB4))),
                                  const SizedBox(width: 6),
                                  Text('· Preparada ${r.timesPrepared}x', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              )
                            else
                              const Text('Descúbrela experimentando en la cocina',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      if (isVisible)
                        Text('${'★' * r.masteryStars}${'☆' * (5 - r.masteryStars)}',
                            style: const TextStyle(fontSize: 10, color: AppColors.goldDark)),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }
}
