import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/configuracion.dart';
import '../providers/configuracion_provider.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usd;
  late TextEditingController _eur;
  late String _monedaBase;
  bool _inicializado = false;
  bool _guardando = false;

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfiguracionProvider>().configuracion;
    if (!_inicializado) {
      _usd = TextEditingController(text: config.tasaCambioUsdACup.toString());
      _eur = TextEditingController(text: config.tasaCambioEurACup.toString());
      _monedaBase = config.monedaBase;
      _inicializado = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tasas de cambio', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Se usan para convertir cobros en USD/EUR a la moneda base.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usd,
                      decoration: const InputDecoration(labelText: '1 USD = ... CUP'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (double.tryParse(v ?? '') == null) ? 'Número inválido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _eur,
                      decoration: const InputDecoration(labelText: '1 EUR = ... CUP'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (double.tryParse(v ?? '') == null) ? 'Número inválido' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _monedaBase,
                      decoration: const InputDecoration(labelText: 'Moneda base para reportes'),
                      items: const [
                        DropdownMenuItem(value: 'CUP', child: Text('CUP')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      ],
                      onChanged: (v) => setState(() => _monedaBase = v!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _guardando
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _guardando = true);
                      final nueva = Configuracion(
                        tasaCambioUsdACup: double.parse(_usd.text),
                        tasaCambioEurACup: double.parse(_eur.text),
                        monedaBase: _monedaBase,
                      );
                      await context.read<ConfiguracionProvider>().guardar(nueva);
                      if (mounted) {
                        setState(() => _guardando = false);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Configuración guardada.')));
                      }
                    },
              child: _guardando
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}