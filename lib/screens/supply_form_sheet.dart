import 'package:flutter/material.dart';
import '../models/supply.dart';
import '../repositories/supply_repository.dart';

Future<bool?> showSupplyFormSheet(BuildContext context, {SupplyItem? item}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SupplyFormSheet(item: item),
  );
}

class _SupplyFormSheet extends StatefulWidget {
  final SupplyItem? item;
  const _SupplyFormSheet({this.item});

  @override
  State<_SupplyFormSheet> createState() => _SupplyFormSheetState();
}

class _SupplyFormSheetState extends State<_SupplyFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _repo = SupplyRepository();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _minStockCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _supplierCtrl;
  late String _category;
  late String _unit;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _stockCtrl = TextEditingController(text: (i?.currentStock ?? 0).toString());
    _minStockCtrl = TextEditingController(text: (i?.minStock ?? 5).toString());
    _priceCtrl = TextEditingController(text: (i?.lastPurchasePrice ?? 0).toString());
    _supplierCtrl = TextEditingController(text: i?.supplier ?? '');
    _category = i?.category ?? SupplyItem.categories.first;
    _unit = i?.unit ?? SupplyItem.units.first;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final item = SupplyItem(
      id: widget.item?.id,
      name: _nameCtrl.text.trim(),
      category: _category,
      unit: _unit,
      currentStock: double.tryParse(_stockCtrl.text) ?? 0,
      minStock: double.tryParse(_minStockCtrl.text) ?? 5,
      lastPurchasePrice: double.tryParse(_priceCtrl.text) ?? 0,
      supplier: _supplierCtrl.text.trim().isEmpty ? null : _supplierCtrl.text.trim(),
    );
    if (widget.item == null) {
      await _repo.insert(item);
    } else {
      await _repo.update(item);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(isEdit ? 'Editar Suministro' : 'Nuevo Suministro', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                        items: SupplyItem.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _category = v ?? _category),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        decoration: const InputDecoration(labelText: 'Unidad'),
                        items: SupplyItem.units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (v) => setState(() => _unit = v ?? _unit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockCtrl,
                        decoration: const InputDecoration(labelText: 'Stock Actual'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minStockCtrl,
                        decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(labelText: 'Último Precio de Compra'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _supplierCtrl,
                  decoration: const InputDecoration(labelText: 'Proveedor (opcional)'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Guardar Cambios' : 'Crear Suministro'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
