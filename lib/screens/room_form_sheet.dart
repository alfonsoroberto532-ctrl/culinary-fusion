import 'package:flutter/material.dart';
import '../models/room.dart';
import '../repositories/room_repository.dart';

Future<bool?> showRoomFormSheet(BuildContext context, {Room? room}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RoomFormSheet(room: room),
  );
}

class _RoomFormSheet extends StatefulWidget {
  final Room? room;
  const _RoomFormSheet({this.room});

  @override
  State<_RoomFormSheet> createState() => _RoomFormSheetState();
}

class _RoomFormSheetState extends State<_RoomFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _repo = RoomRepository();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _featuresCtrl;
  late final TextEditingController _notesCtrl;
  late String _currency;
  late RoomType _roomType;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _capacityCtrl = TextEditingController(text: (r?.capacity ?? 2).toString());
    _priceCtrl = TextEditingController(text: (r?.pricePerNight ?? 30.0).toString());
    _featuresCtrl = TextEditingController(text: r?.features ?? 'Aire Acondicionado, Baño Privado, Wi-Fi');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _currency = r?.currency ?? 'USD';
    _roomType = RoomType.fromCode(r?.roomType ?? 'DOUBLE');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final room = Room(
      id: widget.room?.id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      capacity: int.tryParse(_capacityCtrl.text) ?? 2,
      pricePerNight: double.tryParse(_priceCtrl.text) ?? 0,
      currency: _currency,
      status: widget.room?.status ?? RoomStatus.available,
      roomType: _roomType.code,
      isEntireProperty: _roomType == RoomType.entireHouse,
      features: _featuresCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );
    if (widget.room == null) {
      await _repo.insert(room);
    } else {
      await _repo.update(room);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.room != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
                Text(isEdit ? 'Editar Habitación' : 'Nueva Habitación',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RoomType>(
                  initialValue: _roomType,
                  decoration: const InputDecoration(labelText: 'Tipo de Habitación'),
                  items: RoomType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _roomType = v ?? _roomType),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacityCtrl,
                        decoration: const InputDecoration(labelText: 'Capacidad'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _priceCtrl,
                        decoration: const InputDecoration(labelText: 'Precio / Noche'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => (double.tryParse(v ?? '') == null) ? 'Inválido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration: const InputDecoration(labelText: 'Moneda'),
                        items: const ['USD', 'CUP', 'EUR']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _currency = v ?? 'USD'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _featuresCtrl,
                  decoration: const InputDecoration(labelText: 'Características (separadas por coma)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notas'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Guardar Cambios' : 'Crear Habitación'),
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
