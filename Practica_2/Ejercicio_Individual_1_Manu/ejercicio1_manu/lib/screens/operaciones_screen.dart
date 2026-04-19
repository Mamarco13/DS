import 'package:flutter/material.dart';
import '../operaciones_factory.dart';

class OperacionesScreen extends StatefulWidget {
  const OperacionesScreen({super.key});

  @override
  State<OperacionesScreen> createState() => _OperacionesScreenState();
}

class _OperacionesScreenState extends State<OperacionesScreen> {
  final OperacionesFactory _factory = OperacionesFactory();
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _interesController = TextEditingController();
  final TextEditingController _tiempoController = TextEditingController();

  String _tipoOperacion = 'interes_simple';
  double? _resultado;
  String? _error;

  @override
  void dispose() {
    _capitalController.dispose();
    _interesController.dispose();
    _tiempoController.dispose();
    super.dispose();
  }

  void _calcular() {
    final double? capital = double.tryParse(_capitalController.text);
    final double? interes = double.tryParse(_interesController.text);
    final double? tiempo = double.tryParse(_tiempoController.text);

    if (capital == null || interes == null || tiempo == null) {
      setState(() {
        _error = 'Introduce valores numericos validos.';
        _resultado = null;
      });
      return;
    }

    try {
      final operacion = _factory.realizarOperacion(_tipoOperacion)
        ..capital = capital
        ..interes = interes
        ..tiempo = tiempo;

      setState(() {
        _resultado = operacion.operar();
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _resultado = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factory Method - Operaciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _tipoOperacion,
              decoration: const InputDecoration(
                labelText: 'Tipo de operacion',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'interes_simple',
                  child: Text('Interes simple'),
                ),
                DropdownMenuItem(
                  value: 'interes_compuesto',
                  child: Text('Interes compuesto'),
                ),
                DropdownMenuItem(
                  value: 'amortizacion_mensual',
                  child: Text('Amortizacion mensual'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _tipoOperacion = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _capitalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Capital',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _interesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Interes (%)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tiempoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Tiempo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calcular,
              child: const Text('Calcular'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_resultado != null)
              Text(
                'Resultado: ${_resultado!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}