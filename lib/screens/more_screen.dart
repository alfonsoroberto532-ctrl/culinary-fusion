import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'guests_screen.dart';
import 'supplies_screen.dart';
import 'operations_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (_MoreItem('Huéspedes', 'Directorio de huéspedes', Icons.people_alt_rounded, AppColors.tealPrimary, const GuestsScreen())),
      (_MoreItem('Suministros', 'Inventario y stock', Icons.inventory_2_rounded, AppColors.amberSecondary, const SuppliesScreen())),
      (_MoreItem('Operaciones', 'Limpieza y mantenimiento', Icons.build_rounded, AppColors.statusMaintenance, const OperationsScreen())),
      (_MoreItem('Estadísticas', 'Rentabilidad y ocupación', Icons.bar_chart_rounded, AppColors.emeraldTertiary, const StatisticsScreen())),
      (_MoreItem('Configuración', 'Tasas de cambio y ajustes', Icons.settings_rounded, AppColors.slateOnSurfaceVariant, const SettingsScreen())),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Más')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = items[i];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: item.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, color: item.color),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12.5)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
            ),
          );
        },
      ),
    );
  }
}

class _MoreItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;
  _MoreItem(this.title, this.subtitle, this.icon, this.color, this.screen);
}
