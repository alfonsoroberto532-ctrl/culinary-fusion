import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/insumo.dart';
import '../providers/insumos_provider.dart';

class InsumosScreen extends StatelessWidget {
  const InsumosScreen({super.key});

  void _abrirFormulario(BuildContext context, {Insumo? insumo}) {
    showDialog(context: context, builder: (_) => _FormularioInsumo(insumo: insumo));
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<InsumosProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo insumo'),
      ),
      body: prov.cargando
          ? const Center(child: CircularProgressIndicator())
          : prov.insumos.isEmpty
              ? const Center(child: Text('Aún no has agregado insumos.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: prov.insumos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final ins = prov.insumos[i];
                    final porUnidad = ins.tipoConsumo == TipoConsumo.porHuespedEstadia ? 'por huésped' : 'por noche';
                    return Card(
                      child: ListTile(
                        title: Text(ins.nombre),
                        subtitle: Text(
                          'Costo unitario: \$${ins.costoUnitario.toStringAsFixed(2)} · '
                          'Consumo: ${ins.cantidadConsumoEstandar} $porUnidad',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'editar') _abrirFormulario(context, insumo: ins);
                            if (v == 'baja') context.read<InsumosProvider>().desactivar(ins.id!);
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
    );
  }
}

class _FormularioInsumo extends StatefulWidget {
  final Insumo? insumo;
  const _FormularioInsumo({this.insumo});

  @override
  State<_FormularioInsumo> createState() => _FormularioInsumoState();
}

class _FormularioInsumoState extends State<_FormularioInsumo> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _costoCompra;
  late final TextEditingController _cantidadRinde;
  late final TextEditingController _consumoEstandar;
  late TipoConsumo _tipoConsumo;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.insumo?.nombre ?? '');
    _costoCompra = TextEditingController(text: widget.insumo?.costoCompra.toString() ?? '');
    _cantidadRinde = TextEditingController(text: widget.insumo?.cantidadRinde.toString() ?? '');
    _consumoEstandar = TextEditingController(text: widget.insumo?.cantidadConsumoEstandar.toString() ?? '');
    _tipoConsumo = widget.insumo?.tipoConsumo ?? TipoConsumo.porHuespedEstadia;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<InsumosProvider>();
    final insumo = Insumo(
      id: widget.insumo?.id,
      nombre: _nombre.text.trim(),
      costoCompra: double.parse(_costoCompra.text),
      cantidadRinde: double.parse(_cantidadRinde.text),
      tipoConsumo: _tipoConsumo,
      cantidadConsumoEstandar: double.parse(_consumoEstandar.text),
    );
    if (widget.insumo == null) {
      await prov.crear(insumo);
    } else {
      await prov.actualizar(insumo);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.insumo == null ? 'Nuevo insumo' : 'Editar insumo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costoCompra,
                decoration: const InputDecoration(labelText: 'Costo del lote comprado'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (double.tryParse(v ?? '') == null) ? 'Número inválido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cantidadRinde,
                decoration: const InputDecoration(labelText: 'Unidades que rinde el lote'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (double.tryParse(v ?? '') == null) ? 'Número inválido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TipoConsumo>(
                value: _tipoConsumo,
                decoration: const InputDecoration(labelText: 'Se consume'),
                items: const [
                  DropdownMenuItem(value: TipoConsumo.porHuespedEstadia, child: Text('Por huésped (toda la estadía)')),
                  DropdownMenuItem(value: TipoConsumo.porNocheHabitacion, child: Text('Por noche')),
                ],
                onChanged: (v) => setState(() => _tipoConsumo = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _consumoEstandar,
                decoration: const InputDecoration(labelText: 'Cantidad consumida estándar'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (double.tryParse(v ?? '') == null) ? 'Número inválido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}