import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/reservation.dart';
import '../repositories/reservation_repository.dart';
import '../widgets/status_badge.dart';
import '../widgets/empty_state.dart';
import 'reservation_form_sheet.dart';
import 'reservation_detail_screen.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final _repo = ReservationRepository();
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final _dateFmt = DateFormat('dd/MM/yyyy');

  List<ReservationWithDetails> _reservations = [];
  bool _loading = true;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _repo.getAllWithDetails(status: _statusFilter);
    if (!mounted) return;
    setState(() {
      _reservations = data;
      _loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return AppColors.statusReserved;
      case ReservationStatus.checkedIn:
        return AppColors.statusOccupied;
      case ReservationStatus.checkedOut:
        return AppColors.slateOnSurfaceVariant;
      case ReservationStatus.cancelled:
        return AppColors.alertCritical;
      default:
        return AppColors.slateOnSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await showReservationFormSheet(context);
          if (saved == true) _load();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(
                    height: 46,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      children: [
                        _filterChip(null, 'Todas'),
                        _filterChip(ReservationStatus.confirmed, 'Confirmadas'),
                        _filterChip(ReservationStatus.checkedIn, 'En Curso'),
                        _filterChip(ReservationStatus.checkedOut, 'Finalizadas'),
                        _filterChip(ReservationStatus.cancelled, 'Canceladas'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _reservations.isEmpty
                        ? const EmptyState(
                            icon: Icons.event_note_rounded,
                            title: 'Sin reservas',
                            message: 'Crea tu primera reserva con el botón +',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                            itemCount: _reservations.length,
                            itemBuilder: (_, i) => _reservationCard(_reservations[i]),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _filterChip(String? status, String label) {
    final selected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _statusFilter = status);
          _load();
        },
        selectedColor: AppColors.tealPrimaryContainer,
        labelStyle: TextStyle(
          color: selected ? AppColors.tealPrimary : AppColors.slateOnSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _reservationCard(ReservationWithDetails rwd) {
    final color = _statusColor(rwd.reservation.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => ReservationDetailScreen(reservationId: rwd.reservation.id!),
          ));
          _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(rwd.guest.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                  StatusBadge(label: ReservationStatus.label(rwd.reservation.status), color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(rwd.room.name, style: const TextStyle(fontSize: 12.5, color: AppColors.slateOnSurfaceVariant)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.slateOnSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${_dateFmt.format(DateTime.fromMillisecondsSinceEpoch(rwd.reservation.checkInDate))} → ${_dateFmt.format(DateTime.fromMillisecondsSinceEpoch(rwd.reservation.checkOutDate))}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${rwd.nights} noche(s) · ${_currency.format(rwd.reservation.totalPrice)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  if (rwd.pendingBalance > 0)
                    Text('Pendiente: ${_currency.format(rwd.pendingBalance)}',
                        style: const TextStyle(color: AppColors.amberSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
