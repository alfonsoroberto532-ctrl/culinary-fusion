import 'package:flutter/material.dart';
import '../models/supply.dart';
import '../repositories/supply_repository.dart';

Future<bool?> showMovementDialog(BuildContext context, SupplyItem item) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _MovementDialog(item: item),
  );
}

class _MovementDialog extends StatefulWidget {
  final SupplyItem item;
  const _MovementDialog({required this.item});

  @override
  State<_MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends State<_MovementDialog> {
  final _repo = SupplyRepository();
  final _qtyCtrl = TextEditingController();
  String _type = InventoryMovementType.purchase;
  bool _saving = false;

  static const _typeLabels = {
    InventoryMovementType.purchase: 'Compra (+)',
    InventoryMovementType.consumption: 'Consumo (-)',
    InventoryMovementType.adjustment: 'Ajuste (+/-)',
    InventoryMovementType.waste: 'Merma (-)',
  };

  Future<void> _save() async {
    final qty = double.tryParse(_qtyCtrl.text);
    if (qty == null || qty <= 0) return;
    setState(() => _saving = true);
    await _repo.registerMovement(InventoryMovement(
      supplyItemId: widget.item.id!,
      movementType: _type,
      quantity: qty,
    ));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Movimiento — ${widget.item.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Tipo de movimiento'),
            items: _typeLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _qtyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Cantidad (${widget.item.unit})'),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _saving ? null : _save, child: const Text('Registrar')),
      ],
    );
  }
}
