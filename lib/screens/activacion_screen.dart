import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/license_provider.dart';

class ActivacionScreen extends StatefulWidget {
  const ActivacionScreen({super.key});

  @override
  State<ActivacionScreen> createState() => _ActivacionScreenState();
}

class _ActivacionScreenState extends State<ActivacionScreen> {
  final _controller = TextEditingController();
  bool _validando = false;
  String? _error;

  Future<void> _activar() async {
    setState(() {
      _validando = true;
      _error = null;
    });
    final ok = await context.read<LicenseProvider>().activar(_controller.text);
    if (!mounted) return;
    setState(() => _validando = false);
    if (!ok) {
      setState(() => _error = 'Licencia inválida o expirada. Verifica el código e inténtalo de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final license = context.watch<LicenseProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.villa_outlined, size: 56),
                  const SizedBox(height: 16),
                  Text('VaraNova Hostal', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Activa tu licencia para continuar', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Código de dispositivo', style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 6),
                          SelectableText(
                            license.codigoDispositivo.isEmpty ? '...' : license.codigoDispositivo,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Envía este código al proveedor para recibir tu licencia.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Código de licencia',
                      hintText: 'XX-XXXXXX-XXXXXXXXXX',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _validando ? null : _activar,
                      child: _validando
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Activar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}