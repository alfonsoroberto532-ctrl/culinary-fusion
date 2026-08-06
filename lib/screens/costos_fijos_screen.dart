import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/costo_fijo.dart';
import '../providers/costos_fijos_provider.dart';

class CostosFijosScreen extends StatelessWidget {
  const CostosFijosScreen({super.key});

  void _abrirFormulario(BuildContext context, {CostoFijo? costo}) {
    showDialog(context: context, builder: (_) => _FormularioCostoFijo(costo: costo));
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CostosFijosProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo costo'),
      ),
      body: prov.cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: prov.costosFijos.isEmpty
                      ? const Center(child: Text('Aún no has agregado costos fijos.'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: prov.costosFijos.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final c = prov.costosFijos[i];
                            return Card(
                              child: ListTile(
                                title: Text(c.nombre),
                                subtitle: Text('\$${c.montoMensual.toStringAsFixed(2)} / mes'),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'editar') _abrirFormulario(context, costo: c);
                                    if (v == 'baja') context.read<CostosFijosProvider>().desactivar(c.id!);
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                                    PopupMenuItem(value: 'baja', child: Text('Dar de baja')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total mensual', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('\$${prov.totalMensual.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _FormularioCostoFijo extends StatefulWidget {
  final CostoFijo? costo;
  const _FormularioCostoFijo({this.costo});

  @override
  State<_FormularioCostoFijo> createState() => _FormularioCostoFijoState();
}

class _FormularioCostoFijoState extends State<_FormularioCostoFijo> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _monto;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.costo?.nombre ?? '');
    _monto = TextEditingController(text: widget.costo?.montoMensual.toString() ?? '');
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<CostosFijosProvider>();
    final costo = CostoFijo(
      id: widget.costo?.id,
      nombre: _nombre.text.trim(),
      montoMensual: double.parse(_monto.text),
    );
    if (widget.costo == null) {
      await prov.crear(costo);
    } else {
      await prov.actualizar(costo);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.costo == null ? 'Nuevo costo fijo' : 'Editar costo fijo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre (ej. Electricidad)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _monto,
              decoration: const InputDecoration(labelText: 'Monto mensual'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (double.tryParse(v ?? '') == null) ? 'Número inválido' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}