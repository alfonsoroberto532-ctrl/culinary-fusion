import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/game_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CulinaryFusionApp());
}

class CulinaryFusionApp extends StatelessWidget {
  const CulinaryFusionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState()..init(),
      child: MaterialApp(
        title: 'Culinary Fusion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
