import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/guest.dart';
import '../repositories/guest_repository.dart';
import '../widgets/empty_state.dart';
import 'guest_form_sheet.dart';

class GuestsScreen extends StatefulWidget {
  const GuestsScreen({super.key});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  final _repo = GuestRepository();
  final _searchCtrl = TextEditingController();
  List<Guest> _guests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = _searchCtrl.text.trim().isEmpty
        ? await _repo.getAll()
        : await _repo.search(_searchCtrl.text.trim());
    if (!mounted) return;
    setState(() {
      _guests = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Huéspedes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await showGuestFormSheet(context);
          if (saved == true) _load();
        },
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _load(),
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre, teléfono o documento',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _guests.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_alt_rounded,
                        title: 'Sin huéspedes',
                        message: 'Agrega tu primer huésped con el botón +',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        itemCount: _guests.length,
                        itemBuilder: (_, i) {
                          final g = _guests[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.tealPrimaryContainer,
                                child: Text(
                                  g.name.isNotEmpty ? g.name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w700),
                                ),
                              ),
                              title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text([g.phone, g.nationality].where((s) => s.isNotEmpty).join(' · ')),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () async {
                                final saved = await showGuestFormSheet(context, guest: g);
                                if (saved == true) _load();
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
