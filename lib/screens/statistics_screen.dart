import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/room.dart';
import '../repositories/finance_repository.dart';
import '../repositories/room_repository.dart';
import '../repositories/reservation_repository.dart';
import '../widgets/stat_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _financeRepo = FinanceRepository();
  final _roomRepo = RoomRepository();
  final _reservationRepo = ReservationRepository();
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  final _dayFmt = DateFormat('dd/MM');

  bool _loading = true;
  int _rangeDays = 7;
  List<DailyFinance> _series = [];
  List<CategoryTotal> _categoryTotals = [];
  Map<String, int> _roomCounts = {};
  FinancialSummary _summary = FinancialSummary();
  int _totalReservations = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final series = await _financeRepo.getDailySeries(days: _rangeDays);
    final categories = await _financeRepo.getExpensesByCategory();
    final roomCounts = await _roomRepo.countByStatus();
    final summary = await _financeRepo.getSummary();
    final reservations = await _reservationRepo.getAll();
    if (!mounted) return;
    setState(() {
      _series = series;
      _categoryTotals = categories;
      _roomCounts = roomCounts;
      _summary = summary;
      _totalReservations = reservations.length;
      _loading = false;
    });
  }

  double get _maxSeriesValue {
    double max = 0;
    for (final d in _series) {
      if (d.income > max) max = d.income;
      if (d.expense > max) max = d.expense;
    }
    return max == 0 ? 100 : max * 1.25;
  }

  int get _totalRooms => _roomCounts.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                children: [
                  _rangeSelector(),
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
                        label: 'Ingresos del mes',
                        value: _currency.format(_summary.totalIncomePeriod),
                        icon: Icons.trending_up_rounded,
                        color: AppColors.emeraldTertiary,
                      ),
                      StatCard(
                        label: 'Gastos del mes',
                        value: _currency.format(_summary.totalExpensesPeriod),
                        icon: Icons.trending_down_rounded,
                        color: AppColors.alertCritical,
                      ),
                      StatCard(
                        label: 'Ganancia Neta',
                        value: _currency.format(_summary.netProfitPeriod),
                        icon: Icons.savings_rounded,
                        color: AppColors.tealPrimary,
                      ),
                      StatCard(
                        label: 'Reservas Totales',
                        value: '$_totalReservations',
                        icon: Icons.event_note_rounded,
                        color: AppColors.amberSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Ingresos vs Gastos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Últimos $_rangeDays días', style: const TextStyle(fontSize: 12, color: AppColors.slateOnSurfaceVariant)),
                  const SizedBox(height: 14),
                  _incomeExpenseChart(),
                  const SizedBox(height: 8),
                  _legendRow(),
                  const SizedBox(height: 24),
                  const Text('Ocupación por Estado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 14),
                  _occupancyPieChart(),
                  const SizedBox(height: 24),
                  const Text('Gastos por Categoría', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Este mes', style: TextStyle(fontSize: 12, color: AppColors.slateOnSurfaceVariant)),
                  const SizedBox(height: 14),
                  _categoryTotals.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('Sin gastos registrados este mes',
                              style: TextStyle(color: AppColors.slateOnSurfaceVariant, fontSize: 13)),
                        )
                      : _categoryBars(),
                ],
              ),
            ),
    );
  }

  Widget _rangeSelector() {
    return Row(
      children: [
        _rangeChip(7, '7 días'),
        const SizedBox(width: 8),
        _rangeChip(14, '14 días'),
        const SizedBox(width: 8),
        _rangeChip(30, '30 días'),
      ],
    );
  }

  Widget _rangeChip(int days, String label) {
    final selected = _rangeDays == days;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _rangeDays = days);
        _load();
      },
      selectedColor: AppColors.tealPrimaryContainer,
      labelStyle: TextStyle(
        color: selected ? AppColors.tealPrimary : AppColors.slateOnSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _incomeExpenseChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slateSurfaceVariant),
      ),
      child: _series.isEmpty
          ? const Center(child: Text('Sin datos'))
          : BarChart(
              BarChartData(
                maxY: _maxSeriesValue,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxSeriesValue / 4,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.slateSurfaceVariant, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _maxSeriesValue / 4,
                      getTitlesWidget: (v, _) => Text(
                        _currency.format(v),
                        style: const TextStyle(fontSize: 9.5, color: AppColors.slateOnSurfaceVariant),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= _series.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _dayFmt.format(_series[i].day),
                            style: const TextStyle(fontSize: 10, color: AppColors.slateOnSurfaceVariant),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(_series.length, (i) {
                  final d = _series[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(toY: d.income, color: AppColors.emeraldTertiary, width: 7, borderRadius: BorderRadius.circular(3)),
                      BarChartRodData(toY: d.expense, color: AppColors.alertCritical, width: 7, borderRadius: BorderRadius.circular(3)),
                    ],
                    barsSpace: 4,
                  );
                }),
              ),
            ),
    );
  }

  Widget _legendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(AppColors.emeraldTertiary, 'Ingresos'),
        const SizedBox(width: 20),
        _legendDot(AppColors.alertCritical, 'Gastos'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slateOnSurfaceVariant)),
      ],
    );
  }

  Widget _occupancyPieChart() {
    final items = [
      (RoomStatus.available, 'Disponibles', AppColors.statusAvailable),
      (RoomStatus.reserved, 'Reservadas', AppColors.statusReserved),
      (RoomStatus.occupied, 'Ocupadas', AppColors.statusOccupied),
      (RoomStatus.cleaningPending, 'Por Limpiar', AppColors.statusCleaning.withValues(alpha: 0.75)),
      (RoomStatus.cleaning, 'En Limpieza', AppColors.statusCleaning),
      (RoomStatus.maintenance, 'Mantenimiento', AppColors.statusMaintenance),
    ];
    final nonZero = items.where((i) => (_roomCounts[i.$1] ?? 0) > 0).toList();

    if (_totalRooms == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Sin habitaciones registradas',
            style: TextStyle(color: AppColors.slateOnSurfaceVariant, fontSize: 13)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slateSurfaceVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 32,
                sections: nonZero.map((i) {
                  final count = _roomCounts[i.$1] ?? 0;
                  return PieChartSectionData(
                    value: count.toDouble(),
                    color: i.$3,
                    title: '$count',
                    radius: 32,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: nonZero.map((i) {
                final count = _roomCounts[i.$1] ?? 0;
                final pct = (_totalRooms == 0) ? 0 : (count / _totalRooms) * 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(width: 9, height: 9, decoration: BoxDecoration(color: i.$3, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(i.$2, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                      Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: AppColors.slateOnSurfaceVariant)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBars() {
    final maxTotal = _categoryTotals.map((c) => c.total).fold(0.0, (a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slateSurfaceVariant),
      ),
      child: Column(
        children: _categoryTotals.take(8).map((c) {
          final fraction = maxTotal == 0 ? 0.0 : (c.total / maxTotal);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(c.category, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                    Text(_currency.format(c.total), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: fraction.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.slateSurfaceVariant,
                    valueColor: const AlwaysStoppedAnimation(AppColors.amberSecondary),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
