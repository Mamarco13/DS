import 'dart:convert';
import 'package:flutter/material.dart';
import 'interpreter/interpreter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coordinador',
      home: const CoordinadorPage(),
    );
  }
}

class CoordinadorPage extends StatefulWidget {
  const CoordinadorPage({super.key});

  @override
  State<CoordinadorPage> createState() => _CoordinadorPageState();
}

class _CoordinadorPageState extends State<CoordinadorPage> {
  final Interpreter _interpreter = Interpreter();
  final TextEditingController _jsonController = TextEditingController();

  String _resultado = '';
  String _filtrado = '';
  List<String> _unknownWords = [];
  bool _cargando = false;
  String _error = '';

  // JSON de ejemplo para pruebas
  static const String _ejemploJson = '''[
  { "palabra": "Vicente", "tipo": "pronombre", "duracion": 0.5 },
  { "palabra": "---", "tipo": "otro", "duracion": 2.5 },
  { "palabra": "---", "tipo": "otro", "duracion": 0.2 },
  { "palabra": "nosotros", "tipo": "verbo", "duracion": 2.0 },
  { "palabra": "---", "tipo": "otro", "duracion": 0.2 },
  { "palabra": "tener", "tipo": "verbo", "duracion": 0.5 },
  { "palabra": "---", "tipo": "otro", "duracion": 0.8 },
  { "palabra": "matrícula", "tipo": "sustantivo",  "duracion": 0.5 },
  { "palabra": "?", "tipo": "otro", "duracion": 0.8 }
]''';

  @override
  void initState() {
    super.initState();
    _jsonController.text = _ejemploJson;
  }

  Future<void> _traducir() async {
    setState(() {
      _cargando = true;
      _resultado = '';
      _unknownWords = [];
      _error = '';
    });

    try {
      final List<dynamic> json = jsonDecode(_jsonController.text);
      final result = await _interpreter.traducir(json);

      setState(() {
        _resultado = result.fraseNaturalizada;
        _filtrado = result.fraseFiltrada;
        _unknownWords = result.unknownWords;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coordinador — Prueba de traducción')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'JSON de entrada:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _jsonController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Pega aquí el JSON...',
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _cargando ? null : _traducir,
              child: const Text('Traducir'),
            ),
            const SizedBox(height: 12),
            if (_cargando) const Center(child: CircularProgressIndicator()),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            if (_filtrado.isNotEmpty) ...[
              const Text('Frase filtrada:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Text(_filtrado, style: const TextStyle(fontSize: 14, fontFamily: 'monospace')),
              ),
              const SizedBox(height: 12),
            ],
            if (_resultado.isNotEmpty) ...[
              const Text(
                'Resultado:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Text(
                  _resultado,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
            if (_unknownWords.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Palabras desconocidas: ${_unknownWords.join(', ')}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}