import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/ingredients_data.dart';
import '../game/merge_engine.dart';
import '../models/game_state.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import 'merge_tile.dart';

class MergeBoard extends StatelessWidget {
  final bool showOrders;
  const MergeBoard({super.key, this.showOrders = true});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Column(
      children: [
        _GeneratorsRow(gameState: gameState),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0E1C4)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Escena ilustrada de fondo (cocina/terraza). Coloca el
                // PNG en assets/images/backgrounds/board_bg.png (y
                // declara la carpeta en pubspec.yaml). Si falta, cae al
                // color plano anterior sin romper la pantalla.
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/backgrounds/board_bg.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFFBF3E7),
                    ),
                  ),
                ),
                GridView.builder(
                  itemCount: kBoardSize,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: kBoardColumns,
                  ),
                  itemBuilder: (context, index) {
                    final item = gameState.board[index];
                    final selected = item != null && gameState.cookingSelection.contains(item.uid);
                    return MergeTile(
                      index: index,
                      item: item,
                      selected: selected,
                      justMerged: gameState.lastMergeCellIndex == index,
                      onBurstComplete: gameState.clearMergeEvent,
                      onDropped: (from, to) => gameState.moveOrMerge(from, to),
                      onTap: (i) {
                        final tapped = gameState.board[i];
                        if (tapped == null) return;
                        if (selected) {
                          gameState.removeFromCookingSelection(tapped.uid);
                        } else {
                          gameState.addToCookingSelection(i);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        _CookingBar(gameState: gameState),
      ],
    );
  }
}

class _GeneratorsRow extends StatelessWidget {
  final GameState gameState;
  const _GeneratorsRow({required this.gameState});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        children: gameState.generators.map((g) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                final freeIndex = gameState.board.indexWhere((e) => e == null);
                if (freeIndex == -1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tablero lleno. Vende u ordena algo primero.')),
                  );
                  return;
                }
                gameState.generateInto(g.id, freeIndex);
              },
              child: Container(
                width: 72,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: gradientCardDecoration(AppColors.tealGradient, radius: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Text(g.emoji, style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      g.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    Text('Nv.${g.level}', style: const TextStyle(fontSize: 9, color: Colors.white70)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CookingBar extends StatelessWidget {
  final GameState gameState;
  const _CookingBar({required this.gameState});

  @override
  Widget build(BuildContext context) {
    final selectedNames = gameState.cookingSelection.map((uid) {
      final item = gameState.board.firstWhere(
        (i) => i?.uid == uid,
        orElse: () => null,
      );
      if (item == null) return '';
      return IngredientsData.byId[item.ingredientId]?.emoji ?? '';
    }).where((s) => s.isNotEmpty).join(' + ');

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: softCardDecoration(radius: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              gameState.cookingSelection.isEmpty
                  ? 'Toca ingredientes del tablero para cocinar'
                  : selectedNames,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: gameState.cookingSelection.isEmpty ? 12.5 : 18,
                color: gameState.cookingSelection.isEmpty ? AppColors.textMuted : AppColors.textDark,
              ),
            ),
          ),
          if (gameState.cookingSelection.isNotEmpty)
            TextButton(
              onPressed: gameState.clearCookingSelection,
              child: const Text('Limpiar'),
            ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              disabledBackgroundColor: const Color(0xFFE0D6C4),
            ),
            onPressed: gameState.cookingSelection.isEmpty
                ? null
                : () {
                    final Recipe? recipe = gameState.tryCook();
                    if (recipe == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Esa combinación todavía no forma ninguna receta.')),
                      );
                    }
                  },
            icon: const Icon(Icons.restaurant, size: 18),
            label: const Text('Cocinar'),
          ),
        ],
      ),
    );
  }
}
