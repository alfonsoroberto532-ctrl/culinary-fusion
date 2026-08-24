import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/merge_board.dart';

/// Modo laboratorio: sin pedidos, sin límites, sin presión.
/// El jugador puede generar, fusionar y experimentar libremente.
class FreeCookScreen extends StatelessWidget {
  const FreeCookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.tealGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Free Cook · Laboratorio gastronómico'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<GameState>().toggleFreeCook();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: softCardDecoration(radius: 14, color: AppColors.surfaceAlt),
            child: const Text(
              'Sin energía · Sin vidas · Sin esperas · Cocina todo lo que quieras',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const Expanded(child: MergeBoard(showOrders: false)),
        ],
      ),
    );
  }
}
