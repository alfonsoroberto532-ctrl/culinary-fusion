import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/room.dart';
import '../models/guest.dart';
import '../models/reservation.dart';
import '../repositories/room_repository.dart';
import '../repositories/guest_repository.dart';
import '../repositories/reservation_repository.dart';

Future<bool?> showReservationFormSheet(BuildContext context, {int? preselectedRoomId}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReservationFormSheet(preselectedRoomId: preselectedRoomId),
  );
}

class _ReservationFormSheet extends StatefulWidget {
  final int? preselectedRoomId;
  const _ReservationFormSheet({this.preselectedRoomId});

  @override
  State<_ReservationFormSheet> createState() => _ReservationFormSheetState();
}

class _ReservationFormSheetState extends State<_ReservationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _roomRepo = RoomRepository();
  final _guestRepo = GuestRepository();
  final _reservationRepo = ReservationRepository();
  final _dateFmt = DateFormat('dd/MM/yyyy');

  List<Room> _rooms = [];
  List<Guest> _guests = [];
  Room? _selectedRoom;
  Guest? _selectedGuest;

  final _newGuestNameCtrl = TextEditingController();
  final _newGuestPhoneCtrl = TextEditingController();
  bool _creatingNewGuest = false;

  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 1));
  final _guestCountCtrl = TextEditingController(text: '1');
  final _advanceCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _roomAvailable = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rooms = await _roomRepo.getAll();
    final guests = await _guestRepo.getAll();
    if (!mounted) return;
    setState(() {
      _rooms = rooms;
      _guests = guests;
      if (widget.preselectedRoomId != null) {
        _selectedRoom = rooms.where((r) => r.id == widget.preselectedRoomId).firstOrNull;
      }
      _loading = false;
    });
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    if (_selectedRoom == null) return;
    final available = await _reservationRepo.isRoomAvailable(
      roomId: _selectedRoom!.id!,
      checkIn: _checkIn.millisecondsSinceEpoch,
      checkOut: _checkOut.millisecondsSinceEpoch,
    );
    if (mounted) setState(() => _roomAvailable = available);
  }

  int get _nights {
    final d = _checkOut.difference(_checkIn).inDays;
    return d > 0 ? d : 1;
  }

  double get _totalPrice => (_selectedRoom?.pricePerNight ?? 0) * _nights;

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn ? _checkIn : _checkOut;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (!_checkOut.isAfter(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
    _checkAvailability();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una habitación')));
      return;
    }
    if (!_creatingNewGuest && _selectedGuest == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona o crea un huésped')));
      return;
    }
    if (!_roomAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La habitación no está disponible en esas fechas')));
      return;
    }

    setState(() => _saving = true);

    int guestId;
    if (_creatingNewGuest) {
      guestId = await _guestRepo.insert(Guest(
        name: _newGuestNameCtrl.text.trim(),
        phone: _newGuestPhoneCtrl.text.trim(),
      ));
    } else {
      guestId = _selectedGuest!.id!;
    }

    final reservation = Reservation(
      guestId: guestId,
      roomId: _selectedRoom!.id!,
      checkInDate: _checkIn.millisecondsSinceEpoch,
      checkOutDate: _checkOut.millisecondsSinceEpoch,
      guestCount: int.tryParse(_guestCountCtrl.text) ?? 1,
      pricePerNight: _selectedRoom!.pricePerNight,
      totalPrice: _totalPrice,
      advancePayment: double.tryParse(_advanceCtrl.text) ?? 0,
      currency: _selectedRoom!.currency,
      notes: _notesCtrl.text.trim(),
    );
    final id = await _reservationRepo.insert(reservation);

    final advance = double.tryParse(_advanceCtrl.text) ?? 0;
    if (advance > 0) {
      await _reservationRepo.addPayment(Payment(
        reservationId: id,
        amount: advance,
        currency: _selectedRoom!.currency,
        paymentType: 'Adelanto',
      ));
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: _loading
            ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            : Form(
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
                      const Text('Nueva Reserva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Room>(
                        initialValue: _selectedRoom,
                        decoration: const InputDecoration(labelText: 'Habitación'),
                        items: _rooms
                            .map((r) => DropdownMenuItem(value: r, child: Text('${r.name} · \$${r.pricePerNight.toStringAsFixed(0)}/noche')))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedRoom = v);
                          _checkAvailability();
                        },
                        validator: (v) => v == null ? 'Requerido' : null,
                      ),
                      if (_selectedRoom != null && !_roomAvailable)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text('⚠️ Esta habitación ya tiene una reserva en esas fechas',
                              style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: Text('Huésped', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade700))),
                          TextButton(
                            onPressed: () => setState(() => _creatingNewGuest = !_creatingNewGuest),
                            child: Text(_creatingNewGuest ? 'Elegir existente' : 'Nuevo huésped'),
                          ),
                        ],
                      ),
                      if (_creatingNewGuest) ...[
                        TextFormField(
                          controller: _newGuestNameCtrl,
                          decoration: const InputDecoration(labelText: 'Nombre del huésped'),
                          validator: (v) => (_creatingNewGuest && (v == null || v.trim().isEmpty)) ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _newGuestPhoneCtrl,
                          decoration: const InputDecoration(labelText: 'Teléfono'),
                        ),
                      ] else
                        DropdownButtonFormField<Guest>(
                          initialValue: _selectedGuest,
                          decoration: const InputDecoration(labelText: 'Seleccionar huésped'),
                          items: _guests.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                          onChanged: (v) => setState(() => _selectedGuest = v),
                        ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _dateField('Check-In', _checkIn, () => _pickDate(isCheckIn: true)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dateField('Check-Out', _checkOut, () => _pickDate(isCheckIn: false)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _guestCountCtrl,
                              decoration: const InputDecoration(labelText: 'Nº Huéspedes'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _advanceCtrl,
                              decoration: const InputDecoration(labelText: 'Adelanto'),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(labelText: 'Notas'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$_nights noche(s)', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('\$${_totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Crear Reserva'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _dateField(String label, DateTime value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(_dateFmt.format(value)),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
