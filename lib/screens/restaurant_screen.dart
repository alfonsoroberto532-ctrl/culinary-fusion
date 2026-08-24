import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../theme/app_theme.dart';
import '../theme/game_visuals.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final restaurant = gameState.restaurant;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: gradientCardDecoration(AppColors.heroGradient, radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(restaurant.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: restaurant.restorationProgress,
                  minHeight: 10,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
              const SizedBox(height: 6),
              Text('${restaurant.restoredCount}/${restaurant.elements.length} elementos restaurados',
                  style: const TextStyle(color: Colors.white, fontSize: 12.5)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('Restauración', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...restaurant.elements.map((e) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: softCardDecoration(
              radius: 16,
              color: e.restored ? const Color(0xFFE9FBF1) : AppColors.surface,
              borderColor: e.restored ? AppColors.success.withValues(alpha: 0.35) : const Color(0xFFF0E1C4),
            ),
            child: Row(
              children: [
                Icon(e.restored ? Icons.check_circle_rounded : Icons.build_circle_outlined,
                    color: e.restored ? AppColors.success : AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(
                        e.restored ? 'Restaurado' : 'Costo: ${e.cost} monedas',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (!e.restored)
                  ElevatedButton(
                    onPressed: () => gameState.restoreElement(e.id),
                    child: const Text('Restaurar'),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 18),
        Text('Decoración', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...gameState.decorations.map((d) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: softCardDecoration(radius: 16),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
                  child: GameVisual(assetPath: d.imagePath, emoji: d.emoji, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(d.category, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                if (!d.unlocked)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark),
                    onPressed: () => gameState.unlockDecoration(d.id),
                    child: Text('${d.cost} 🪙'),
                  )
                else
                  Switch(
                    value: d.placed,
                    activeColor: AppColors.secondary,
                    onChanged: (_) => gameState.togglePlaceDecoration(d.id),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
