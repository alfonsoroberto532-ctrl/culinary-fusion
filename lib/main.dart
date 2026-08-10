import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const VaraNovaHostalApp());
}

class VaraNovaHostalApp extends StatelessWidget {
  const VaraNovaHostalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaraNova Hostal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
