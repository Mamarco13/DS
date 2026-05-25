import 'package:flutter/material.dart';
import '../src/api/rails_service.dart';
import 'enviar_sonido.dart';

class LenguajesScreen extends StatefulWidget {
  const LenguajesScreen({super.key});

  @override
  State<LenguajesScreen> createState() => _LenguajesScreenState();
}

class _LenguajesScreenState extends State<LenguajesScreen> {
  List<Map<String, dynamic>> _lenguajes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarLenguajes();
  }

  Future<void> _cargarLenguajes() async {
    try {
      final data = await RailsService.getLenguajes();
      setState(() {
        _lenguajes = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      debugPrint('Error cargando lenguajes: $e');
    }
  }

  Future<void> _crearLenguaje() async {
    final controller = TextEditingController();
    final nombre = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo lenguaje'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (nombre == null || nombre.isEmpty) return;

    await RailsService.crearLenguaje(nombre);
    _cargarLenguajes();
  }

  Future<void> _eliminarLenguaje(int id) async {
    await RailsService.eliminarLenguaje(id);
    _cargarLenguajes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis lenguajes')),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearLenguaje,
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _lenguajes.isEmpty
              ? const Center(child: Text('No hay lenguajes. Crea uno.'))
              : ListView.builder(
                  itemCount: _lenguajes.length,
                  itemBuilder: (ctx, i) {
                    final l = _lenguajes[i];
                    return ListTile(
                      title: Text(l['nombre']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarLenguaje(l['id']),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrepararAudioRailsScreen(
                            lenguajeId: l['id'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
