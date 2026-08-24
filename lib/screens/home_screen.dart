import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../theme/app_theme.dart';
import 'free_cook_screen.dart';
import 'gastronomic_tree_screen.dart';
import 'kitchen_screen.dart';
import 'missions_screen.dart';
import 'recipe_book_screen.dart';
import 'restaurant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  final _screens = const [
    KitchenScreen(),
    RecipeBookScreen(),
    RestaurantScreen(),
    GastronomicTreeScreen(),
    MissionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    // Muestra el popup de descubrimiento/logro más reciente, si lo hay.
    if (gameState.lastPopupTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final title = gameState.lastPopupTitle;
        final subtitle = gameState.lastPopupSubtitle;
        gameState.clearPopup();
        if (title == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.zero,
            duration: const Duration(seconds: 3),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: gradientCardDecoration(AppColors.heroGradient, radius: 16),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        if (subtitle != null)
                          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            _StatChip(icon: Icons.star_rounded, label: 'Nv. ${gameState.player.level}', color: AppColors.gold),
            const SizedBox(width: 8),
            _StatChip(icon: Icons.savings_rounded, label: '${gameState.player.coins}', color: Colors.white),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                gameState.toggleFreeCook();
                if (gameState.freeCookMode) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const FreeCookScreen(),
                  ));
                }
              },
              icon: const Icon(Icons.spa, color: Colors.white, size: 18),
              label: const Text('Free Cook', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _tabIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.kitchen_rounded), label: 'Cocina'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Recetas'),
          NavigationDestination(icon: Icon(Icons.storefront_rounded), label: 'Restaurante'),
          NavigationDestination(icon: Icon(Icons.account_tree_rounded), label: 'Árbol'),
          NavigationDestination(icon: Icon(Icons.flag_rounded), label: 'Misiones'),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
