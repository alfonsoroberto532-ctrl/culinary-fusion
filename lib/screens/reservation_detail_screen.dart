import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/reservation.dart';
import '../repositories/reservation_repository.dart';
import '../widgets/status_badge.dart';

class ReservationDetailScreen extends StatefulWidget {
  final int reservationId;
  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  final _repo = ReservationRepository();
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final _dateFmt = DateFormat('dd/MM/yyyy');

  ReservationWithDetails? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _repo.getWithDetails(widget.reservationId);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Future<void> _addPayment() async {
    final ctrl = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar Pago'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, double.tryParse(ctrl.text)),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (amount == null || amount <= 0) return;
    await _repo.addPayment(Payment(
      reservationId: widget.reservationId,
      amount: amount,
      currency: _data!.reservation.currency,
      paymentType: 'Parcial',
    ));
    _load();
  }

  Future<void> _checkIn() async {
    await _repo.checkIn(widget.reservationId);
    _load();
  }

  Future<void> _checkOut() async {
    await _repo.checkOut(widget.reservationId);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out realizado. Habitación enviada a limpieza.')),
      );
    }
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text('¿Seguro que deseas cancelar esta reserva?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, Cancelar')),
        ],
      ),
    );
    if (confirm != true) return;
    await _repo.cancel(widget.reservationId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final data = _data;
    if (data == null) {
      return const Scaffold(body: Center(child: Text('Reserva no encontrada')));
    }
    final res = data.reservation;

    return Scaffold(
      appBar: AppBar(title: Text('Reserva #${res.id}')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(data.guest.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
                        StatusBadge(label: ReservationStatus.label(res.status), color: AppColors.tealPrimary),
                      ],
                    ),
                    if (data.guest.phone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(data.guest.phone, style: const TextStyle(color: AppColors.slateOnSurfaceVariant)),
                      ),
                    const Divider(height: 24),
                    _infoRow('Habitación', data.room.name),
                    _infoRow('Check-In', _dateFmt.format(DateTime.fromMillisecondsSinceEpoch(res.checkInDate))),
                    _infoRow('Check-Out', _dateFmt.format(DateTime.fromMillisecondsSinceEpoch(res.checkOutDate))),
                    _infoRow('Noches', '${data.nights}'),
                    _infoRow('Huéspedes', '${res.guestCount}'),
                    if (res.notes.isNotEmpty) _infoRow('Notas', res.notes),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumen Financiero', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 10),
                    _infoRow('Total', _currency.format(res.totalPrice)),
                    _infoRow('Pagado', _currency.format(data.totalPaid)),
                    _infoRow('Pendiente', _currency.format(data.pendingBalance),
                        valueColor: data.pendingBalance > 0 ? AppColors.amberSecondary : AppColors.emeraldTertiary),
                    if (res.status != ReservationStatus.cancelled) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _addPayment,
                          icon: const Icon(Icons.add_card_rounded, size: 18),
                          label: const Text('Registrar Pago'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (data.payments.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('Historial de Pagos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              ...data.payments.map((p) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.payments_rounded, color: AppColors.emeraldTertiary),
                      title: Text(_currency.format(p.amount)),
                      subtitle: Text('${p.paymentType} · ${_dateFmt.format(DateTime.fromMillisecondsSinceEpoch(p.date))}'),
                    ),
                  )),
            ],
            const SizedBox(height: 20),
            if (res.status == ReservationStatus.confirmed) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checkIn,
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Hacer Check-In'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _cancel,
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.alertCritical),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancelar Reserva'),
                ),
              ),
            ],
            if (res.status == ReservationStatus.checkedIn)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checkOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Hacer Check-Out'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.slateOnSurfaceVariant, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
