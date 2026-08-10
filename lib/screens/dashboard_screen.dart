import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/room.dart';
import '../models/reservation.dart';
import '../repositories/room_repository.dart';
import '../repositories/reservation_repository.dart';
import '../repositories/finance_repository.dart';
import '../repositories/supply_repository.dart';
import '../repositories/operations_repository.dart';
import '../models/operations.dart';
import '../widgets/stat_card.dart';
import 'reservation_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _roomRepo = RoomRepository();
  final _reservationRepo = ReservationRepository();
  final _financeRepo = FinanceRepository();
  final _supplyRepo = SupplyRepository();
  final _opsRepo = OperationsRepository();

  bool _loading = true;
  Map<String, int> _roomCounts = {};
  FinancialSummary _summary = FinancialSummary();
  List<Reservation> _arrivals = [];
  List<Reservation> _departures = [];
  int _lowStockCount = 0;
  int _pendingMaintenanceCount = 0;
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final counts = await _roomRepo.countByStatus();
    final summary = await _financeRepo.getSummary();
    final arrivals = await _reservationRepo.arrivalsToday();
    final departures = await _reservationRepo.departuresToday();
    final lowStock = await _supplyRepo.getLowStock();
    final maintenance = await _opsRepo.getMaintenanceRecords(status: MaintenanceStatus.pending);
    if (!mounted) return;
    setState(() {
      _roomCounts = counts;
      _summary = summary;
      _arrivals = arrivals;
      _departures = departures;
      _lowStockCount = lowStock.length;
      _pendingMaintenanceCount = maintenance.length;
      _loading = false;
    });
  }

  int get _totalRooms => _roomCounts.values.fold(0, (a, b) => a + b);
  int get _occupied => _roomCounts[RoomStatus.occupied] ?? 0;
  double get _occupancyPercent => _totalRooms == 0 ? 0 : (_occupied / _totalRooms) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VaraNova Hostal')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _occupancyCard(),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      StatCard(
                        label: 'Cobrado Hoy',
                        value: _currency.format(_summary.collectedToday),
                        icon: Icons.payments_rounded,
                        color: AppColors.emeraldTertiary,
                      ),
                      StatCard(
                        label: 'Por Cobrar',
                        value: _currency.format(_summary.pendingToCollect),
                        icon: Icons.hourglass_bottom_rounded,
                        color: AppColors.amberSecondary,
                      ),
                      StatCard(
                        label: 'Gastos Hoy',
                        value: _currency.format(_summary.expensesToday),
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.statusOccupied,
                      ),
                      StatCard(
                        label: 'Ganancia Hoy',
                        value: _currency.format(_summary.estimatedProfitToday),
                        icon: Icons.trending_up_rounded,
                        color: AppColors.tealPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _alertsSection(),
                  const SizedBox(height: 20),
                  _roomStatusSection(),
                  const SizedBox(height: 20),
                  if (_arrivals.isNotEmpty) _arrivalsDeparturesSection('Llegadas de Hoy', _arrivals, Icons.login_rounded, AppColors.statusReserved),
                  if (_departures.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _arrivalsDeparturesSection('Salidas de Hoy', _departures, Icons.logout_rounded, AppColors.amberSecondary),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  Widget _occupancyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.tealPrimary, Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ocupación Actual', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  '${_occupancyPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
                ),
                Text('$_occupied de $_totalRooms habitaciones ocupadas',
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
              ],
            ),
          ),
          const Icon(Icons.villa_rounded, color: Colors.white, size: 46),
        ],
      ),
    );
  }

  Widget _alertsSection() {
    final alerts = <Widget>[];
    if (_lowStockCount > 0) {
      alerts.add(_alertTile(
        icon: Icons.inventory_2_rounded,
        color: AppColors.alertWarning,
        title: '$_lowStockCount suministro(s) con stock bajo',
        subtitle: 'Revisa la sección de Suministros',
      ));
    }
    if (_pendingMaintenanceCount > 0) {
      alerts.add(_alertTile(
        icon: Icons.build_rounded,
        color: AppColors.alertCritical,
        title: '$_pendingMaintenanceCount incidencia(s) de mantenimiento pendiente(s)',
        subtitle: 'Revisa Operaciones',
      ));
    }
    if ((_roomCounts[RoomStatus.cleaningPending] ?? 0) > 0) {
      alerts.add(_alertTile(
        icon: Icons.cleaning_services_rounded,
        color: AppColors.statusCleaning,
        title: '${_roomCounts[RoomStatus.cleaningPending]} habitación(es) pendiente(s) de limpieza',
        subtitle: 'Revisa Operaciones',
      ));
    }
    if (alerts.isEmpty) {
      return _alertTile(
        icon: Icons.check_circle_rounded,
        color: AppColors.alertSuccess,
        title: 'Todo en orden',
        subtitle: 'No hay alertas pendientes en este momento',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alertas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 8),
        ...alerts.map((a) => Padding(padding: const EdgeInsets.only(bottom: 8), child: a)),
      ],
    );
  }

  Widget _alertTile({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.slateOnSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomStatusSection() {
    final items = [
      (RoomStatus.available, 'Disponibles', AppColors.statusAvailable, Icons.check_circle_rounded),
      (RoomStatus.reserved, 'Reservadas', AppColors.statusReserved, Icons.event_available_rounded),
      (RoomStatus.occupied, 'Ocupadas', AppColors.statusOccupied, Icons.person_rounded),
      (RoomStatus.cleaningPending, 'Por Limpiar', AppColors.statusCleaning, Icons.cleaning_services_rounded),
      (RoomStatus.maintenance, 'Mantenimiento', AppColors.statusMaintenance, Icons.build_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estado de Habitaciones', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 10),
        ...items.map((item) {
          final count = _roomCounts[item.$1] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(item.$4, size: 18, color: item.$3),
                const SizedBox(width: 10),
                Expanded(child: Text(item.$2, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                Text('$count', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: item.$3)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _arrivalsDeparturesSection(String title, List<Reservation> list, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 8),
        ...list.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(icon, color: color),
                title: Text('Reserva #${r.id}'),
                subtitle: Text('${r.nights} noche(s) · ${_currency.format(r.totalPrice)}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ReservationDetailScreen(reservationId: r.id!),
                  ));
                  _load();
                },
              ),
            )),
      ],
    );
  }
}
