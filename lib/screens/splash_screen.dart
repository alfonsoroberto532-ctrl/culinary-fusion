import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Pantalla de marca al abrir la app: chef + logo + barra de progreso.
/// Espera a que [GameState.isReady] sea true (guardado cargado, pedidos
/// generados) Y a que pase una duración mínima, para que la marca se vea
/// siempre aunque la carga sea instantánea. Luego navega a [HomeScreen]
/// con un fade, sin dejar la splash en el stack de navegación.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const _minDuration = Duration(milliseconds: 1800);
  late final AnimationController _progress;
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _minDuration)..forward();
    Future.delayed(_minDuration, () {
      if (!mounted) return;
      setState(() => _minTimeElapsed = true);
      _maybeNavigate();
    });
    // Por si GameState ya estaba listo antes de que se construyera el frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeNavigate());
  }

  void _maybeNavigate() {
    if (!mounted) return;
    final ready = context.read<GameState>().isReady;
    if (ready && _minTimeElapsed) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escucha isReady: si init() termina antes que el timer mínimo,
    // esta rebuild + el callback del timer disparan la navegación.
    context.watch<GameState>().isReady;
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeNavigate());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.heroGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Ilustración de marca. Coloca tu PNG en
                // assets/images/splash/splash_chef.png (declarado en
                // pubspec.yaml). Si falta, cae a un ícono simple sin
                // romper la pantalla.
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Image.asset(
                    'assets/images/splash/splash_chef.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Culinary Fusion',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Merge, Cook, Discover',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                const Spacer(flex: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) => LinearProgressIndicator(
                      value: _progress.value,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Alistando la cocina...',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
