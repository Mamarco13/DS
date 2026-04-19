import 'package:ejercicio1/factoria_operacion.dart';
import 'package:ejercicio1/models/operacion_financiera.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Financiera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController capitalCtrl = TextEditingController();
  final TextEditingController interesCtrl = TextEditingController();
  final TextEditingController tiempoCtrl = TextEditingController();

  String tipoOperacion = "interes simple";
  double? resultado;

  void calcular() {
    if (_formKey.currentState!.validate()) {
      try {
        double C = double.parse(capitalCtrl.text.replaceAll(',', '.'));
        double i = double.parse(interesCtrl.text.replaceAll(',', '.'));
        double t = double.parse(tiempoCtrl.text.replaceAll(',', '.'));

        OperacionFinanciera op =
            FactoriaOperacion.crearOperacion(tipoOperacion, C, i, t);

        setState(() {
          resultado = op.calcular();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Calculadora Financiera"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              _campo(capitalCtrl, "Capital (€)", "ej: 1000"),
              const SizedBox(height: 12),
              _campo(interesCtrl, "Interés (ej: 0.05)", "ej: 0.05"),
              const SizedBox(height: 12),
              _campo(tiempoCtrl, "Tiempo (años)", "ej: 12"),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: tipoOperacion,
                decoration: InputDecoration(
                  labelText: "Tipo de operación",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                      value: "interes simple",
                      child: Text("Interés Simple")),
                  DropdownMenuItem(
                      value: "interes compuesto",
                      child: Text("Interés Compuesto")),
                  DropdownMenuItem(
                      value: "amortizacion",
                      child: Text("Amortización")),
                ],
                onChanged: (value) => setState(() {
                  tipoOperacion = value!;
                  resultado = null;
                }),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: calcular,
                icon: const Icon(Icons.calculate),
                label: const Text("Calcular"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (resultado != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Resultado",
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${resultado!.toStringAsFixed(2)} €",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String label, String hint) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Campo obligatorio";
        if (double.tryParse(value.replaceAll(',', '.')) == null) {
          return "Introduce un número válido";
        }
        return null;
      },
    );
  }
}