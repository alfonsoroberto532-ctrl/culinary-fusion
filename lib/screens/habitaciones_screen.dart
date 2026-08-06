import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habitacion.dart';
import '../providers/habitaciones_provider.dart';

class HabitacionesScreen extends StatelessWidget {
  const HabitacionesScreen({super.key});

  void _abrirFormulario(BuildContext context, {Habitacion? habitacion}) {
    showDialog(context: context, builder: (_) => _FormularioHabitacion(habitacion: habitacion));
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<HabitacionesProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva habitación'),
      ),
      body: prov.cargando
          ? const Center(child: CircularProgressIndicator())
          : prov.habitaciones.isEmpty
              ? const Center(child: Text('Aún no has agregado habitaciones.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: prov.habitaciones.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final h = prov.habitaciones[i];
                    return Card(
                      child: ListTile(
                        title: Text(h.nombre),
                        subtitle: Text('Capacidad: ${h.capacidadMaxima} · \$${h.precioBaseNoche.toStringAsFixed(2)} / noche'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'editar') _abrirFormulario(context, habitacion: h);
                            if (v == 'baja') {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Dar de baja'),
                                  content: Text('¿Retirar "${h.nombre}"? El histórico de estadías se conserva.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                                    FilledButton(
                                      onPressed: () {
                                        context.read<HabitacionesProvider>().desactivar(h.id!);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Dar de baja'),
                                    ),
                                  ],
                                ),
                              );
                            }
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

class _FormularioHabitacion extends StatefulWidget {
  final Habitacion? habitacion;
  const _FormularioHabitacion({this.habitacion});

  @override
  State<_FormularioHabitacion> createState() => _FormularioHabitacionState();
}

class _FormularioHabitacionState extends State<_FormularioHabitacion> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _capacidad;
  late final TextEditingController _precio;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.habitacion?.nombre ?? '');
    _capacidad = TextEditingController(text: widget.habitacion?.capacidadMaxima.toString() ?? '');
    _precio = TextEditingController(text: widget.habitacion?.precioBaseNoche.toString() ?? '');
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<HabitacionesProvider>();
    final habitacion = Habitacion(
      id: widget.habitacion?.id,
      nombre: _nombre.text.trim(),
      capacidadMaxima: int.parse(_capacidad.text),
      precioBaseNoche: double.parse(_precio.text),
    );
    if (widget.habitacion == null) {
      await prov.crear(habitacion);
    } else {
      await prov.actualizar(habitacion);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.habitacion == null ? 'Nueva habitación' : 'Editar habitación'),
      content: Form(
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
              controller: _capacidad,
              decoration: const InputDecoration(labelText: 'Capacidad máxima'),
              keyboardType: TextInputType.number,
              validator: (v) => (int.tryParse(v ?? '') == null) ? 'Número inválido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precio,
              decoration: const InputDecoration(labelText: 'Precio base por noche'),
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