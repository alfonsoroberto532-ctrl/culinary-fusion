import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'providers/configuracion_provider.dart';
import 'providers/costos_fijos_provider.dart';
import 'providers/estadias_provider.dart';
import 'providers/habitaciones_provider.dart';
import 'providers/insumos_provider.dart';
import 'providers/license_provider.dart';
import 'screens/activacion_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  Intl.defaultLocale = 'es';
  runApp(const HostalApp());
}

class HostalApp extends StatelessWidget {
  const HostalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LicenseProvider()..verificar()),
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => HabitacionesProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => InsumosProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => CostosFijosProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => EstadiasProvider()..cargarMes(DateTime.now())),
      ],
      child: MaterialApp(
        title: 'VaraNova Hostal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final license = context.watch<LicenseProvider>();
    if (license.verificando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return license.activa ? const HomeScreen() : const ActivacionScreen();
  }
}