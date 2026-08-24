import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Barra superior fija del "lienzo de juego": nivel, energía, monedas,
/// gemas y acceso rápido a la tienda. No es un AppBar de navegación:
/// es parte del HUD del juego y siempre permanece anclada arriba.
///
/// Energía y gemas son infinitas por diseño: no se guardan ni se gastan
/// en ningún lado, así que el HUD solo las muestra con el símbolo ∞ en
/// vez de recibir/pintar un número que nunca baja.
class GameHud extends StatelessWidget {
  final int level;
  final double levelProgress; // 0..1, xp hacia el siguiente nivel
  final int coins;
  final VoidCallback onShopTap;

  const GameHud({
    super.key,
    required this.level,
    required this.levelProgress,
    required this.coins,
    required this.onShopTap,
  });

  /// Punto de destino para la animación de "monedas voladoras"
  /// (ver widgets/flying_reward.dart). Es estático porque solo existe
  /// un HUD activo en toda la app, y así el key sobrevive a que
  /// HomeScreen reconstruya GameHud en cada notifyListeners().
  static final GlobalKey coinsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).padding.top + 8, 10, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          _LevelBadge(level: level, progress: levelProgress),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _Chip(icon: Icons.bolt_rounded, color: const Color(0xFFFFD54F), value: '∞'),
                  const SizedBox(width: 6),
                  _CoinChip(key: coinsKey, coins: coins),
                  const SizedBox(width: 6),
                  _Chip(icon: Icons.diamond_rounded, color: const Color(0xFFB388FF), value: '∞'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ShopButton(onTap: onShopTap),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final double progress;
  const _LevelBadge({required this.level, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0, 1),
            strokeWidth: 3.5,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
          ),
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Text(
              '$level',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de monedas con memoria de su valor anterior: cuando [coins] sube
/// (llega un pedido entregado, termina el vuelo de monedas del HUD),
/// hace un pequeño rebote elástico en vez de solo redibujar el número.
class _CoinChip extends StatefulWidget {
  final int coins;
  const _CoinChip({super.key, required this.coins});

  @override
  State<_CoinChip> createState() => _CoinChipState();
}

class _CoinChipState extends State<_CoinChip> with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  @override
  void didUpdateWidget(covariant _CoinChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coins != oldWidget.coins) {
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.32).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
        TweenSequenceItem(tween: Tween(begin: 1.32, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 65),
      ]).animate(_bounce),
      child: _Chip(icon: Icons.savings_rounded, color: AppColors.gold, value: '${widget.coins}'),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  const _Chip({required this.icon, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _ShopButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ShopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: const Icon(Icons.storefront_rounded, color: AppColors.primaryDark, size: 22),
      ),
    );
  }
}