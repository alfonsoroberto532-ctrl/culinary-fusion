import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/customers_data.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
import '../theme/game_visuals.dart';
import '../widgets/merge_board.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Column(
      children: [
        if (gameState.activeOrders.isNotEmpty) _OrdersStrip(gameState: gameState),
        const Expanded(child: MergeBoard(showOrders: true)),
      ],
    );
  }
}

class _OrdersStrip extends StatelessWidget {
  final GameState gameState;
  const _OrdersStrip({required this.gameState});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
        children: gameState.activeOrders.map((order) {
          final customer = CustomersData.byId[order.customerId];
          final recipe = gameState.recipeEngine.byId(order.recipeIds.first);
          final ready = (recipe?.timesPrepared ?? 0) > 0;
          return Container(
            width: 176,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(10),
            decoration: softCardDecoration(
              radius: 16,
              color: ready ? const Color(0xFFE9FBF1) : AppColors.surface,
              borderColor: ready ? AppColors.success.withValues(alpha: 0.4) : const Color(0xFFF0E1C4),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
                  child: customer == null
                      ? const Text('🙂', style: TextStyle(fontSize: 18))
                      : GameVisual(assetPath: customer.imagePath, emoji: customer.emoji, size: 22),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recipe?.name ?? '???',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.savings_rounded, size: 12, color: AppColors.goldDark),
                          const SizedBox(width: 2),
                          Text('${order.rewardCoins}', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 28,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ready ? AppColors.success : const Color(0xFFE0D6C4),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: ready ? () => gameState.deliverOrder(order.id) : null,
                          child: const Text('Entregar', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
