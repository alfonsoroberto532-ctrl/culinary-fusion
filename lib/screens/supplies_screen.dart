import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/supply.dart';
import '../repositories/supply_repository.dart';
import '../widgets/empty_state.dart';
import 'supply_form_sheet.dart';
import 'movement_dialog.dart';

class SuppliesScreen extends StatefulWidget {
  const SuppliesScreen({super.key});

  @override
  State<SuppliesScreen> createState() => _SuppliesScreenState();
}

class _SuppliesScreenState extends State<SuppliesScreen> {
  final _repo = SupplyRepository();
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  List<SupplyItem> _items = [];
  bool _loading = true;
  bool _onlyLowStock = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _repo.getAll();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  List<SupplyItem> get _filtered =>
      _onlyLowStock ? _items.where((i) => i.isLowStock).toList() : _items;

  Future<void> _delete(SupplyItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Suministro'),
        content: Text('¿Eliminar "${item.name}" del inventario?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.delete(item.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = _items.where((i) => i.isLowStock).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Suministros')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await showSupplyFormSheet(context);
          if (saved == true) _load();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (lowStockCount > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: InkWell(
                        onTap: () => setState(() => _onlyLowStock = !_onlyLowStock),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.alertWarning.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.alertWarning.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.alertWarning, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '$lowStockCount suministro(s) con stock bajo · toca para ${_onlyLowStock ? "ver todos" : "filtrar"}',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: _filtered.isEmpty
                        ? const EmptyState(
                            icon: Icons.inventory_2_rounded,
                            title: 'Sin suministros',
                            message: 'Agrega tu primer suministro con el botón +',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _supplyCard(_filtered[i]),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _supplyCard(SupplyItem item) {
    final color = item.isLowStock ? AppColors.alertWarning : AppColors.emeraldTertiary;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(item.isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_rounded, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                      Text(item.category, style: const TextStyle(fontSize: 12, color: AppColors.slateOnSurfaceVariant)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') {
                      final saved = await showSupplyFormSheet(context, item: item);
                      if (saved == true) _load();
                    } else if (v == 'delete') {
                      _delete(item);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.currentStock.toStringAsFixed(1)} ${item.unit} en stock',
                  style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13),
                ),
                Text('mín: ${item.minStock.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11.5, color: AppColors.slateOnSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Últ. compra: ${_currency.format(item.lastPurchasePrice)}', style: const TextStyle(fontSize: 11.5, color: AppColors.slateOnSurfaceVariant)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final saved = await showMovementDialog(context, item);
                  if (saved == true) _load();
                },
                icon: const Icon(Icons.swap_vert_rounded, size: 16),
                label: const Text('Registrar Movimiento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
