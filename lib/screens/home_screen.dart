import 'package:flutter/material.dart';

import 'costos_fijos_screen.dart';
import 'configuracion_screen.dart';
import 'dashboard_screen.dart';
import 'estadias_screen.dart';
import 'habitaciones_screen.dart';
import 'insumos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titulos = ['Panel', 'Estadías', 'Habitaciones', 'Insumos', 'Costos fijos', 'Configuración'];
  static const _iconos = [
    Icons.dashboard_outlined,
    Icons.event_note_outlined,
    Icons.meeting_room_outlined,
    Icons.inventory_2_outlined,
    Icons.request_quote_outlined,
    Icons.settings_outlined,
  ];
  static const _pantallas = [
    DashboardScreen(),
    EstadiasScreen(),
    HabitacionesScreen(),
    InsumosScreen(),
    CostosFijosScreen(),
    ConfiguracionScreen(),
  ];

  void _seleccionar(int i) {
    setState(() => _index = i);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_index])),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('VaraNova Hostal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),
              for (var i = 0; i < _titulos.length; i++)
                ListTile(
                  leading: Icon(_iconos[i]),
                  title: Text(_titulos[i]),
                  selected: i == _index,
                  onTap: () => _seleccionar(i),
                ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: _pantallas),
    );
  }
}