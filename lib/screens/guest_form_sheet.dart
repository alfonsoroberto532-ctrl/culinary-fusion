import 'package:flutter/material.dart';
import '../models/guest.dart';
import '../repositories/guest_repository.dart';

Future<bool?> showGuestFormSheet(BuildContext context, {Guest? guest}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GuestFormSheet(guest: guest),
  );
}

class _GuestFormSheet extends StatefulWidget {
  final Guest? guest;
  const _GuestFormSheet({this.guest});

  @override
  State<_GuestFormSheet> createState() => _GuestFormSheetState();
}

class _GuestFormSheetState extends State<_GuestFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _repo = GuestRepository();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _nationalityCtrl;
  late final TextEditingController _documentCtrl;
  late final TextEditingController _notesCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.guest;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _phoneCtrl = TextEditingController(text: g?.phone ?? '');
    _nationalityCtrl = TextEditingController(text: g?.nationality ?? '');
    _documentCtrl = TextEditingController(text: g?.documentId ?? '');
    _notesCtrl = TextEditingController(text: g?.notes ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final guest = Guest(
      id: widget.guest?.id,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      nationality: _nationalityCtrl.text.trim(),
      documentId: _documentCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );
    if (widget.guest == null) {
      await _repo.insert(guest);
    } else {
      await _repo.update(guest);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.guest != null;
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
                Text(isEdit ? 'Editar Huésped' : 'Nuevo Huésped', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nationalityCtrl,
                  decoration: const InputDecoration(labelText: 'Nacionalidad'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _documentCtrl,
                  decoration: const InputDecoration(labelText: 'Documento / Pasaporte'),
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
                        : Text(isEdit ? 'Guardar Cambios' : 'Crear Huésped'),
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
