import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/room.dart';
import '../repositories/room_repository.dart';
import '../repositories/operations_repository.dart';
import '../widgets/status_badge.dart';
import '../widgets/empty_state.dart';
import 'room_form_sheet.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final _repo = RoomRepository();
  final _opsRepo = OperationsRepository();
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  List<Room> _rooms = [];
  bool _loading = true;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rooms = await _repo.getAll();
    if (!mounted) return;
    setState(() {
      _rooms = rooms;
      _loading = false;
    });
  }

  List<Room> get _filtered =>
      _statusFilter == null ? _rooms : _rooms.where((r) => r.status == _statusFilter).toList();

  Future<void> _quickClean(Room room) async {
    await _opsRepo.quickCompleteCleaning(room.id!);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${room.name} marcada como limpia y disponible')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habitaciones')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await showRoomFormSheet(context);
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
                        _filterChip(RoomStatus.available, 'Disponibles'),
                        _filterChip(RoomStatus.reserved, 'Reservadas'),
                        _filterChip(RoomStatus.occupied, 'Ocupadas'),
                        _filterChip(RoomStatus.cleaningPending, 'Por Limpiar'),
                        _filterChip(RoomStatus.maintenance, 'Mantenimiento'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filtered.isEmpty
                        ? const EmptyState(
                            icon: Icons.bed_rounded,
                            title: 'Sin habitaciones',
                            message: 'Agrega tu primera habitación con el botón +',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _roomCard(_filtered[i]),
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
        onSelected: (_) => setState(() => _statusFilter = status),
        selectedColor: AppColors.tealPrimaryContainer,
        labelStyle: TextStyle(
          color: selected ? AppColors.tealPrimary : AppColors.slateOnSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _roomCard(Room room) {
    final color = AppColors.statusColor(room.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final saved = await showRoomFormSheet(context, room: room);
          if (saved == true) _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.bed_rounded, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(RoomType.fromCode(room.roomType).label,
                            style: const TextStyle(fontSize: 12, color: AppColors.slateOnSurfaceVariant)),
                      ],
                    ),
                  ),
                  StatusBadge(label: AppColors.statusLabel(room.status), color: color),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.people_alt_rounded, size: 15, color: AppColors.slateOnSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${room.capacity} huésp.', style: const TextStyle(fontSize: 12.5)),
                  const SizedBox(width: 16),
                  Icon(Icons.sell_rounded, size: 15, color: AppColors.slateOnSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${_currency.format(room.pricePerNight)} / noche', style: const TextStyle(fontSize: 12.5)),
                ],
              ),
              if (room.status == RoomStatus.cleaningPending) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _quickClean(room),
                    icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                    label: const Text('Marcar como Limpia'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.statusCleaning),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
