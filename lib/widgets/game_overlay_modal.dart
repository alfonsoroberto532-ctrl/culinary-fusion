import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Abre [child] como una capa flotante centrada sobre el juego, con fondo
/// semi-transparente — nunca como un panel que se desliza desde un borde
/// ni como una ruta de navegación con su propio AppBar/tab.
Future<void> showGameOverlay(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, anim, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, anim2, _) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Opacity(
        opacity: anim.value.clamp(0, 1),
        child: Transform.scale(
          scale: 0.92 + 0.08 * curved.value.clamp(0, 1),
          child: _OverlayCard(title: title, icon: icon, child: child),
        ),
      );
    },
  );
}

class _OverlayCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _OverlayCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: mq.padding.top + 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 30, offset: Offset(0, 12))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.heroGradient),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
