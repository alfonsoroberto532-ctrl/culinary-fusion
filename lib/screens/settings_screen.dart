import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/exchange_rate.dart';
import '../repositories/finance_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repo = FinanceRepository();
  final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  bool _loading = true;
  List<ExchangeRate> _rates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rates = await _repo.getExchangeRates();
    if (!mounted) return;
    setState(() {
      _rates = rates;
      _loading = false;
    });
  }

  Future<void> _editRate(ExchangeRate? rate) async {
    final codeCtrl = TextEditingController(text: rate?.currencyCode ?? '');
    final valueCtrl = TextEditingController(text: rate != null ? rate.rateToPrimary.toString() : '');
    final formKey = GlobalKey<FormState>();
    final isEdit = rate != null;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Editar Tasa: ${rate.currencyCode}' : 'Nueva Moneda'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEdit)
                TextFormField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 4,
                  decoration: const InputDecoration(labelText: 'Código (ej. USD, CUP, EUR)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
              TextFormField(
                controller: valueCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Unidades por 1 USD',
                  helperText: 'Ej: si 1 USD = 380 CUP, ingresa 380',
                ),
                validator: (v) => (double.tryParse((v ?? '').replaceAll(',', '.')) == null) ? 'Inválido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (saved == true && formKey.currentState!.validate()) {
      final code = isEdit ? rate.currencyCode : codeCtrl.text.trim().toUpperCase();
      final value = double.tryParse(valueCtrl.text.replaceAll(',', '.')) ?? 1.0;
      await _repo.upsertExchangeRate(ExchangeRate(currencyCode: code, rateToPrimary: value));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editRate(null),
        child: const Icon(Icons.add_rounded),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                children: [
                  const Text('Tasas de Cambio', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text(
                    'La moneda primaria del sistema es USD. El resto de las monedas se convierten a partir de estas tasas.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.slateOnSurfaceVariant),
                  ),
                  const SizedBox(height: 14),
                  ..._rates.map(_rateCard),
                  const SizedBox(height: 28),
                  const Text('Acerca de', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.tealPrimary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.villa_rounded, color: AppColors.tealPrimary),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('VaraNova Hostal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                                SizedBox(height: 2),
                                Text('Gestión integral para hostales y casas de renta',
                                    style: TextStyle(fontSize: 12, color: AppColors.slateOnSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _rateCard(ExchangeRate rate) {
    final isPrimary = rate.currencyCode == 'USD';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.amberSecondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              rate.currencyCode,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.amberSecondary),
            ),
          ),
        ),
        title: Text(
          isPrimary ? '${rate.currencyCode} · Moneda Primaria' : rate.currencyCode,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          isPrimary
              ? 'Base del sistema (1.0)'
              : '1 USD = ${rate.rateToPrimary.toStringAsFixed(2)} ${rate.currencyCode}\nActualizado ${_dateFmt.format(DateTime.fromMillisecondsSinceEpoch(rate.lastUpdated))}',
          style: const TextStyle(fontSize: 11.5),
        ),
        isThreeLine: !isPrimary,
        trailing: isPrimary
            ? null
            : IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                onPressed: () => _editRate(rate),
              ),
      ),
    );
  }
}
