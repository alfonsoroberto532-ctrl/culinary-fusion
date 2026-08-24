import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/dialogue_overlay.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_overlay_modal.dart';
import 'free_cook_screen.dart';
import 'gastronomic_tree_screen.dart';
import 'kitchen_screen.dart';
import 'missions_screen.dart';
import 'recipe_book_screen.dart';
import 'restaurant_screen.dart';

/// Pantalla principal como lienzo único de juego: la Cocina (tablero de
/// merge) siempre está de fondo. Recetario, Restaurante/Tienda, Árbol
/// gastronómico y Misiones se abren como overlays flotantes encima del
/// mismo tablero, nunca como rutas hermanas con su propio tab.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openOverlay(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    showGameOverlay(context, title: title, icon: icon, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final showDialogue = gameState.lastPopupTitle != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Lienzo base: HUD fijo arriba + tablero de cocina siempre visible.
          Column(
            children: [
              GameHud(
                level: gameState.player.level,
                levelProgress: gameState.player.xp / gameState.player.xpToNextLevel,
                coins: gameState.player.coins,
                onShopTap: () => _openOverlay(
                  context,
                  title: 'Restaurante',
                  icon: Icons.storefront_rounded,
                  child: const RestaurantScreen(),
                ),
              ),
              const Expanded(child: KitchenScreen()),
            ],
          ),

          // Menú rápido flotante: reemplaza el NavigationBar inferior.
          Positioned(
            right: 12,
            bottom: 16,
            child: _QuickMenu(
              onRecipes: () => _openOverlay(
                context,
                title: 'Recetario',
                icon: Icons.menu_book_rounded,
                child: const RecipeBookScreen(),
              ),
              onTree: () => _openOverlay(
                context,
                title: 'Árbol gastronómico',
                icon: Icons.account_tree_rounded,
                child: const GastronomicTreeScreen(),
              ),
              onMissions: () => _openOverlay(
                context,
                title: 'Misiones',
                icon: Icons.flag_rounded,
                child: const MissionsScreen(),
              ),
              onFreeCook: () {
                gameState.toggleFreeCook();
                if (gameState.freeCookMode) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const FreeCookScreen(),
                  ));
                }
              },
            ),
          ),

          // Diálogo de personaje: descubrimientos y logros, superpuesto
          // al tablero en vez de un SnackBar genérico.
          if (showDialogue)
            DialogueOverlay(
              emoji: '✨',
              name: gameState.lastPopupTitle ?? '',
              text: gameState.lastPopupSubtitle ?? '',
              onDismiss: gameState.clearPopup,
            ),
        ],
      ),
    );
  }
}

/// Columna de botones circulares flotantes para abrir los overlays de
/// Recetario, Árbol y Misiones, más el acceso a Free Cook.
class _QuickMenu extends StatelessWidget {
  final VoidCallback onRecipes;
  final VoidCallback onTree;
  final VoidCallback onMissions;
  final VoidCallback onFreeCook;

  const _QuickMenu({
    required this.onRecipes,
    required this.onTree,
    required this.onMissions,
    required this.onFreeCook,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuickButton(icon: Icons.menu_book_rounded, tooltip: 'Recetario', onTap: onRecipes),
        const SizedBox(height: 10),
        _QuickButton(icon: Icons.account_tree_rounded, tooltip: 'Árbol', onTap: onTree),
        const SizedBox(height: 10),
        _QuickButton(icon: Icons.flag_rounded, tooltip: 'Misiones', onTap: onMissions),
        const SizedBox(height: 10),
        _QuickButton(icon: Icons.spa_rounded, tooltip: 'Free Cook', onTap: onFreeCook),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _QuickButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.heroGradient),
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
