import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/estadia.dart';
import '../providers/estadias_provider.dart';
import '../providers/habitaciones_provider.dart';
import '../services/calculo_ganancia_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final estadiasProv = context.watch<EstadiasProvider>();
    final numHabitaciones = context.watch<HabitacionesProvider>().habitaciones.length;
    final mesLabel = DateFormat.yMMMM('es').format(estadiasProv.mesActual);
    final DesgloseGanancia? desglose = estadiasProv.desglose;
    final formatoMoneda = NumberFormat.currency(locale: 'es', symbol: '', decimalDigits: 2);
    final formatoFecha = DateFormat('dd/MM');

    return RefreshIndicator(
      onRefresh: () => estadiasProv.cargarMes(estadiasProv.mesActual, numeroHabitaciones: numHabitaciones),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => estadiasProv.mesAnterior(numeroHabitaciones: numHabitaciones),
              ),
              Text(
                mesLabel[0].toUpperCase() + mesLabel.substring(1),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => estadiasProv.mesSiguiente(numeroHabitaciones: numHabitaciones),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (estadiasProv.cargando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _TarjetaGanancia(desglose: desglose, formato: formatoMoneda),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _TarjetaMetrica(
                  titulo: 'Ingreso bruto',
                  valor: formatoMoneda.format(desglose?.ingresoBruto ?? 0),
                  icono: Icons.trending_up,
                ),
                _TarjetaMetrica(
                  titulo: 'Costo insumos',
                  valor: formatoMoneda.format(desglose?.costoInsumos ?? 0),
                  icono: Icons.inventory_2_outlined,
                ),
                _TarjetaMetrica(
                  titulo: 'Costos fijos',
                  valor: formatoMoneda.format(desglose?.costoFijoProrrateado ?? 0),
                  icono: Icons.request_quote_outlined,
                ),
                _TarjetaMetrica(
                  titulo: 'Ocupación',
                  valor: '${estadiasProv.ocupacionPorcentaje.toStringAsFixed(1)}%',
                  icono: Icons.hotel_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Estadías del mes (${estadiasProv.estadias.length})', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (estadiasProv.estadias.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No hay estadías registradas este mes.'),
              )
            else
              ...estadiasProv.estadias.take(5).map(
                    (e) => Card(
                      child: ListTile(
                        title: Text('${formatoFecha.format(e.fechaEntrada)} → ${formatoFecha.format(e.fechaSalida)}'),
                        subtitle: Text('${e.numeroHuespedes} huésped(es) · ${e.estadoEstadia.etiqueta}'),
                        trailing: Text(formatoMoneda.format(e.precioCobrado)),
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaGanancia extends StatelessWidget {
  final DesgloseGanancia? desglose;
  final NumberFormat formato;

  const _TarjetaGanancia({required this.desglose, required this.formato});

  @override
  Widget build(BuildContext context) {
    final ganancia = desglose?.gananciaReal ?? 0.0;
    final margen = desglose?.margenRealPorcentaje ?? 0.0;
    final color = ganancia >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ganancia neta del mes', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              formato.format(ganancia),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Margen: ${margen.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;

  const _TarjetaMetrica({required this.titulo, required this.valor, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 20, color: Theme.of(context).colorScheme.primary),
            const Spacer(),
            Text(valor, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(titulo, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}