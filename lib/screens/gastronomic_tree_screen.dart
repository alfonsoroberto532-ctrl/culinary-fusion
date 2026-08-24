import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/ingredients_data.dart';
import '../models/enums.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
import '../theme/game_visuals.dart';

class GastronomicTreeScreen extends StatelessWidget {
  const GastronomicTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final discovered = gameState.discovery.discoveredIngredientIds;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: TreeId.values.map((tree) {
        final chain = IngredientsData.byTree(tree);
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tree.label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: chain.length,
                  separatorBuilder: (_, __) =>
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted)),
                  itemBuilder: (context, i) {
                    final ingredient = chain[i];
                    final known = discovered.contains(ingredient.id);
                    final rarity = ingredient.rarity;
                    return Container(
                      width: 76,
                      decoration: softCardDecoration(
                        radius: 14,
                        color: known ? rarity.colorSoft : const Color(0xFFF2EEE6),
                        borderColor: known ? rarity.color.withValues(alpha: 0.4) : const Color(0xFFE3DACB),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          known
                              ? GameVisual(assetPath: ingredient.imagePath, emoji: ingredient.emoji, size: 26)
                              : const Text('❓', style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            known ? ingredient.name : '???',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
