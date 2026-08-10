import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'rooms_screen.dart';
import 'reservations_screen.dart';
import 'finances_screen.dart';
import 'more_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    RoomsScreen(),
    ReservationsScreen(),
    FinancesScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.bed_rounded), label: 'Habitaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note_rounded), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money_rounded), label: 'Finanzas'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: 'Más'),
        ],
      ),
    );
  }
}
