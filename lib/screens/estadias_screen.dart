import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/estadia.dart';
import '../providers/configuracion_provider.dart';
import '../providers/estadias_provider.dart';
import '../providers/habitaciones_provider.dart';

class EstadiasScreen extends StatelessWidget {
  const EstadiasScreen({super.key});

  void _abrirFormulario(BuildContext context, {Estadia? estadia}) {
    showDialog(context: context, builder: (_) => _FormularioEstadia(estadia: estadia));
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EstadiasProvider>();
    final habitaciones = context.watch<HabitacionesProvider>().habitaciones;
    final nombrePorHabitacion = {for (final h in habitaciones) h.id: h.nombre};
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final formatoMoneda = NumberFormat.currency(locale: 'es', symbol: '', decimalDigits: 2);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: habitaciones.isEmpty
            ? () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Primero agrega al menos una habitación.')))
            : () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva estadía'),
      ),
      body: prov.cargando
          ? const Center(child: CircularProgressIndicator())
          : prov.estadias.isEmpty
              ? const Center(child: Text('No hay estadías registradas este mes.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: prov.estadias.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final e = prov.estadias[i];
                    final cancelada = e.estadoEstadia == EstadoEstadia.cancelada;
                    return Card(
                      child: ListTile(
                        title: Text(nombrePorHabitacion[e.habitacionId] ?? 'Habitación eliminada'),
                        subtitle: Text(
                          '${formatoFecha.format(e.fechaEntrada)} → ${formatoFecha.format(e.fechaSalida)}'
                          ' · ${e.numeroHuespedes} huésped(es) · ${e.estadoPago.etiqueta}',
                        ),
                        leading: Chip(
                          label: Text(e.estadoEstadia.etiqueta, style: const TextStyle(fontSize: 11)),
                          backgroundColor: cancelada ? Colors.grey.shade300 : Theme.of(context).colorScheme.primaryContainer,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${formatoMoneda.format(e.precioCobrado)} ${e.monedaCobro.name.toUpperCase()}'),
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'editar') _abrirFormulario(context, estadia: e);
                                if (v == 'cancelar') context.read<EstadiasProvider>().cancelar(e);
                                if (v == 'eliminar') context.read<EstadiasProvider>().eliminar(e.id!);
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'editar', child: Text('Editar')),
                                if (!cancelada) const PopupMenuItem(value: 'cancelar', child: Text('Cancelar')),
                                const PopupMenuItem(value: 'eliminar', child: Text('Eliminar definitivamente')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _FormularioEstadia extends StatefulWidget {
  final Estadia? estadia;
  const _FormularioEstadia({this.estadia});

  @override
  State<_FormularioEstadia> createState() => _FormularioEstadiaState();
}

class _FormularioEstadiaState extends State<_FormularioEstadia> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _huespedes;
  late final TextEditingController _precio;
  late final TextEditingController _notas;

  int? _habitacionId;
  DateTime _entrada = DateTime.now();
  DateTime _salida = DateTime.now().add(const Duration(days: 1));
  Nacionalidad _nacionalidad = Nacionalidad.nacional;
  Moneda _moneda = Moneda.cup;
  EstadoPago _estadoPago = EstadoPago.pendiente;
  EstadoEstadia _estadoEstadia = EstadoEstadia.activa;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.estadia;
    _habitacionId = e?.habitacionId;
    _entrada = e?.fechaEntrada ?? DateTime.now();
    _salida = e?.fechaSalida ?? DateTime.now().add(const Duration(days: 1));
    _nacionalidad = e?.nacionalidad ?? Nacionalidad.nacional;
    _moneda = e?.monedaCobro ?? Moneda.cup;
    _estadoPago = e?.estadoPago ?? EstadoPago.pendiente;
    _estadoEstadia = e?.estadoEstadia ?? EstadoEstadia.activa;
    _huespedes = TextEditingController(text: e?.numeroHuespedes.toString() ?? '1');
    _precio = TextEditingController(text: e?.precioCobrado.toString() ?? '');
    _notas = TextEditingController(text: e?.notas ?? '');
  }

  Future<void> _elegirFecha({required bool esEntrada}) async {
    final inicial = esEntrada ? _entrada : _salida;
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (seleccionada == null) return;
    setState(() {
      if (esEntrada) {
        _entrada = seleccionada;
        if (!_salida.isAfter(_entrada)) _salida = _entrada.add(const Duration(days: 1));
      } else {
        _salida = seleccionada;
      }
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_habitacionId == null) {
      setState(() => _error = 'Selecciona una habitación.');
      return;
    }
    if (!_salida.isAfter(_entrada)) {
      setState(() => _error = 'La fecha de salida debe ser posterior a la entrada.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    final config = context.read<ConfiguracionProvider>().configuracion;
    double? tasaUsada;
    if (_moneda == Moneda.usd) tasaUsada = config.tasaCambioUsdACup;
    if (_moneda == Moneda.eur) tasaUsada = config.tasaCambioEurACup;

    final estadia = Estadia(
      id: widget.estadia?.id,
      habitacionId: _habitacionId!,
      fechaEntrada: _entrada,
      fechaSalida: _salida,
      numeroHuespedes: int.parse(_huespedes.text),
      nacionalidad: _nacionalidad,
      precioCobrado: double.parse(_precio.text),
      monedaCobro: _moneda,
      tasaCambioUsada: widget.estadia?.tasaCambioUsada ?? tasaUsada,
      estadoPago: _estadoPago,
      estadoEstadia: _estadoEstadia,
      notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
    );

    try {
      final prov = context.read<EstadiasProvider>();
      if (widget.estadia == null) {
        await prov.crear(estadia);
      } else {
        await prov.actualizar(estadia);
      }
      if (mounted) Navigator.pop(context);
    } catch (ex) {
      setState(() {
        _guardando = false;
        _error = ex.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitaciones = context.watch<HabitacionesProvider>().habitaciones;
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return AlertDialog(
      title: Text(widget.estadia == null ? 'Nueva estadía' : 'Editar estadía'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _habitacionId,
                decoration: const InputDecoration(labelText: 'Habitación'),
                items: [for (final h in habitaciones) DropdownMenuItem(value: h.id, child: Text(h.nombre))],
                onChanged: (v) => setState(() => _habitacionId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _elegirFecha(esEntrada: true),
                      child: Text('Entrada: ${formatoFecha.format(_entrada)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _elegirFecha(esEntrada: false),
                      child: Text('Salida: ${formatoFecha.format(_salida)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _huespedes,
                decoration: const InputDecoration(labelText: 'Número de huéspedes'),
                keyboardType: TextInputType.number,
                validator: (v) => (int.tryParse(v ?? '') == null) ? 'Número inválido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Nacionalidad>(
                initialValue: _nacionalidad,
                decoration: const InputDecoration(labelText: 'Nacionalidad'),
                items: const [
                  DropdownMenuItem(value: Nacionalidad.nacional, child: Text('Nacional')),
                  DropdownMenuItem(value: Nacionalidad.extranjero, child: Text('Extranjero')),
                ],
                onChanged: (v) => setState(() => _nacionalidad = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _precio,
                      decoration: const InputDecoration(labelText: 'Precio cobrado'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (double.tryParse(v ?? '') == null) ? 'Número inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<Moneda>(
                      initialValue: _moneda,
                      decoration: const InputDecoration(labelText: 'Moneda'),
                      items: const [
                        DropdownMenuItem(value: Moneda.cup, child: Text('CUP')),
                        DropdownMenuItem(value: Moneda.usd, child: Text('USD')),
                        DropdownMenuItem(value: Moneda.eur, child: Text('EUR')),
                      ],
                      onChanged: (v) => setState(() => _moneda = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EstadoPago>(
                initialValue: _estadoPago,
                decoration: const InputDecoration(labelText: 'Estado de pago'),
                items: EstadoPago.values.map((e) => DropdownMenuItem(value: e, child: Text(e.etiqueta))).toList(),
                onChanged: (v) => setState(() => _estadoPago = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EstadoEstadia>(
                initialValue: _estadoEstadia,
                decoration: const InputDecoration(labelText: 'Estado de la estadía'),
                items: EstadoEstadia.values.map((e) => DropdownMenuItem(value: e, child: Text(e.etiqueta))).toList(),
                onChanged: (v) => setState(() => _estadoEstadia = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notas,
                decoration: const InputDecoration(labelText: 'Notas (opcional)'),
                maxLines: 2,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}