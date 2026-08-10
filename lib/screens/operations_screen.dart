import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/room.dart';
import '../models/operations.dart';
import '../repositories/room_repository.dart';
import '../repositories/operations_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

class OperationsScreen extends StatefulWidget {
  const OperationsScreen({super.key});

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _roomRepo = RoomRepository();
  final _opsRepo = OperationsRepository();
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  bool _loading = true;
  List<Room> _rooms = [];
  List<CleaningRecord> _cleaningRecords = [];
  List<MaintenanceRecord> _maintenanceRecords = [];
  String? _maintenanceStatusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rooms = await _roomRepo.getAll();
    final cleaning = await _opsRepo.getCleaningRecords();
    final maintenance = await _opsRepo.getMaintenanceRecords(status: _maintenanceStatusFilter);
    if (!mounted) return;
    setState(() {
      _rooms = rooms;
      _cleaningRecords = cleaning;
      _maintenanceRecords = maintenance;
      _loading = false;
    });
  }

  String _roomName(int id) {
    for (final r in _rooms) {
      if (r.id == id) return r.name;
    }
    return 'Habitación #$id';
  }

  List<Room> get _pendingCleaningRooms => _rooms
      .where((r) => r.status == RoomStatus.cleaningPending || r.status == RoomStatus.cleaning)
      .toList();

  Future<void> _startCleaning(Room room) async {
    await _opsRepo.startCleaning(room.id!);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Limpieza iniciada en ${room.name}')));
    }
    _load();
  }

  Future<void> _completeCleaning(Room room) async {
    CleaningRecord? inProgress;
    for (final c in _cleaningRecords) {
      if (c.roomId == room.id && c.status == CleaningStatus.inProgress) {
        inProgress = c;
        break;
      }
    }
    if (inProgress != null) {
      await _opsRepo.completeCleaning(inProgress.id!, room.id!);
    } else {
      await _opsRepo.quickCompleteCleaning(room.id!);
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${room.name} lista y disponible')));
    }
    _load();
  }

  Future<void> _setInRepair(MaintenanceRecord record) async {
    await _opsRepo.updateMaintenanceRecord(record.copyWith(status: MaintenanceStatus.inRepair));
    _load();
  }

  Future<void> _resolveMaintenance(MaintenanceRecord record) async {
    final costCtrl =
        TextEditingController(text: record.cost > 0 ? record.cost.toStringAsFixed(2) : '');
    final techCtrl = TextEditingController(text: record.technician ?? '');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolver Incidencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: techCtrl,
              decoration: const InputDecoration(labelText: 'Técnico (opcional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Costo de reparación'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Resolver')),
        ],
      ),
    );
    if (confirm == true) {
      await _opsRepo.resolveMaintenance(
        record.id!,
        record.roomId,
        cost: double.tryParse(costCtrl.text.replaceAll(',', '.')) ?? 0,
        technician: techCtrl.text.trim().isEmpty ? null : techCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Incidencia resuelta')));
      }
      _load();
    }
  }

  Future<void> _openIncidentForm() async {
    final saved = await showMaintenanceFormSheet(context, rooms: _rooms);
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final isMaintenanceTab = _tabController.index == 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operaciones'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Limpieza'),
            Tab(text: 'Mantenimiento'),
          ],
        ),
      ),
      floatingActionButton: isMaintenanceTab
          ? FloatingActionButton.extended(
              onPressed: _openIncidentForm,
              icon: const Icon(Icons.report_problem_rounded),
              label: const Text('Reportar'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _cleaningTab(),
                _maintenanceTab(),
              ],
            ),
    );
  }

  // ---- Tab: Limpieza ----

  Widget _cleaningTab() {
    final pending = _pendingCleaningRooms;
    final history = _cleaningRecords.take(15).toList();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
        children: [
          const Text('Pendientes de Limpieza', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          if (pending.isEmpty)
            const EmptyState(
              icon: Icons.cleaning_services_rounded,
              title: 'Todo limpio',
              message: 'No hay habitaciones pendientes de limpieza en este momento',
            )
          else
            ...pending.map(_pendingCleaningCard),
          const SizedBox(height: 24),
          const Text('Historial Reciente', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Sin registros de limpieza todavía',
                  style: TextStyle(color: AppColors.slateOnSurfaceVariant, fontSize: 13)),
            )
          else
            ...history.map(_cleaningHistoryTile),
        ],
      ),
    );
  }

  Widget _pendingCleaningCard(Room room) {
    final inProgress = room.status == RoomStatus.cleaning;
    final color = AppColors.statusCleaning;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.cleaning_services_rounded, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                  Text(inProgress ? 'Limpieza en curso' : 'Esperando limpieza',
                      style: const TextStyle(fontSize: 12, color: AppColors.slateOnSurfaceVariant)),
                ],
              ),
            ),
            if (inProgress)
              FilledButton(
                onPressed: () => _completeCleaning(room),
                child: const Text('Completar'),
              )
            else
              OutlinedButton(
                onPressed: () => _startCleaning(room),
                style: OutlinedButton.styleFrom(foregroundColor: color),
                child: const Text('Iniciar'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cleaningHistoryTile(CleaningRecord record) {
    final completed = record.status == CleaningStatus.completed;
    final color = completed ? AppColors.alertSuccess : AppColors.statusCleaning;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(completed ? Icons.check_circle_rounded : Icons.hourglass_bottom_rounded, color: color),
        title: Text(_roomName(record.roomId), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        subtitle: Text(_dateFmt.format(DateTime.fromMillisecondsSinceEpoch(record.date)),
            style: const TextStyle(fontSize: 11.5)),
        trailing: StatusBadge(
          label: completed ? 'Completada' : 'En Curso',
          color: color,
        ),
      ),
    );
  }

  // ---- Tab: Mantenimiento ----

  Widget _maintenanceTab() {
    return RefreshIndicator(
      onRefresh: _load,
      child: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                _maintenanceFilterChip(null, 'Todos'),
                _maintenanceFilterChip(MaintenanceStatus.pending, 'Pendiente'),
                _maintenanceFilterChip(MaintenanceStatus.inRepair, 'En Reparación'),
                _maintenanceFilterChip(MaintenanceStatus.resolved, 'Resuelto'),
              ],
            ),
          ),
          Expanded(
            child: _maintenanceRecords.isEmpty
                ? const EmptyState(
                    icon: Icons.build_rounded,
                    title: 'Sin incidencias',
                    message: 'Reporta una incidencia de mantenimiento con el botón "Reportar"',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: _maintenanceRecords.length,
                    itemBuilder: (_, i) => _maintenanceCard(_maintenanceRecords[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _maintenanceFilterChip(String? status, String label) {
    final selected = _maintenanceStatusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _maintenanceStatusFilter = status);
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

  Widget _maintenanceCard(MaintenanceRecord record) {
    final priorityColor = switch (record.priority) {
      MaintenancePriority.critical => AppColors.alertCritical,
      MaintenancePriority.high => AppColors.statusMaintenance,
      MaintenancePriority.low => AppColors.slateOnSurfaceVariant,
      _ => AppColors.amberSecondary,
    };
    final statusColor = switch (record.status) {
      MaintenanceStatus.resolved => AppColors.alertSuccess,
      MaintenanceStatus.inRepair => AppColors.tealPrimary,
      _ => AppColors.alertWarning,
    };
    final resolved = record.status == MaintenanceStatus.resolved;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.build_rounded, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_roomName(record.roomId), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                      Text(_dateFmt.format(DateTime.fromMillisecondsSinceEpoch(record.reportedDate)),
                          style: const TextStyle(fontSize: 11.5, color: AppColors.slateOnSurfaceVariant)),
                    ],
                  ),
                ),
                StatusBadge(label: MaintenancePriority.label(record.priority), color: priorityColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(record.issue, style: const TextStyle(fontSize: 13.5)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(label: MaintenanceStatus.label(record.status), color: statusColor),
                if (resolved && record.cost > 0)
                  Text(_currency.format(record.cost),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
            if (!resolved) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (record.status == MaintenanceStatus.pending)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _setInRepair(record),
                        child: const Text('En Reparación'),
                      ),
                    ),
                  if (record.status == MaintenanceStatus.pending) const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _resolveMaintenance(record),
                      child: const Text('Resolver'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---- Formulario para reportar una incidencia de mantenimiento ----

Future<bool?> showMaintenanceFormSheet(BuildContext context, {required List<Room> rooms}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MaintenanceFormSheet(rooms: rooms),
  );
}

class _MaintenanceFormSheet extends StatefulWidget {
  final List<Room> rooms;
  const _MaintenanceFormSheet({required this.rooms});

  @override
  State<_MaintenanceFormSheet> createState() => _MaintenanceFormSheetState();
}

class _MaintenanceFormSheetState extends State<_MaintenanceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _repo = OperationsRepository();

  late final TextEditingController _issueCtrl;
  late final TextEditingController _technicianCtrl;
  late final TextEditingController _notesCtrl;
  int? _roomId;
  String _priority = MaintenancePriority.medium;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _issueCtrl = TextEditingController();
    _technicianCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    _roomId = widget.rooms.isNotEmpty ? widget.rooms.first.id : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _roomId == null) return;
    setState(() => _saving = true);
    final record = MaintenanceRecord(
      roomId: _roomId!,
      issue: _issueCtrl.text.trim(),
      priority: _priority,
      technician: _technicianCtrl.text.trim().isEmpty ? null : _technicianCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );
    await _repo.reportIssue(record);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Form(
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
                const Text('Reportar Incidencia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _roomId,
                  decoration: const InputDecoration(labelText: 'Habitación'),
                  items: widget.rooms
                      .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _roomId = v),
                  validator: (v) => v == null ? 'Selecciona una habitación' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _issueCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción del problema'),
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                Text('Prioridad', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    MaintenancePriority.low,
                    MaintenancePriority.medium,
                    MaintenancePriority.high,
                    MaintenancePriority.critical,
                  ].map((p) {
                    final selected = _priority == p;
                    return ChoiceChip(
                      label: Text(MaintenancePriority.label(p)),
                      selected: selected,
                      onSelected: (_) => setState(() => _priority = p),
                      selectedColor: AppColors.tealPrimaryContainer,
                      labelStyle: TextStyle(
                        color: selected ? AppColors.tealPrimary : AppColors.slateOnSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _technicianCtrl,
                  decoration: const InputDecoration(labelText: 'Técnico asignado (opcional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notas'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Reportar Incidencia'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
