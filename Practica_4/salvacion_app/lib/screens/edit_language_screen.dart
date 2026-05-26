import 'package:flutter/material.dart';
import '../src/api/api_client.dart';
import '../src/widgets/language_selector.dart';

class EditLanguageScreen extends StatefulWidget {
  const EditLanguageScreen({super.key});

  @override
  State<EditLanguageScreen> createState() => _EditLanguageScreenState();
}

class _EditLanguageScreenState extends State<EditLanguageScreen> {
  final TextEditingController _lenguajeController = TextEditingController();
  final RailsApiClient _apiClient = RailsApiClient();
  
  bool _cargando = false;
  List<Map<String, dynamic>> _palabras = [];
  int? _lenguajeIdActual;

  Future<void> _cargarPalabras() async {
    final nombre = _lenguajeController.text.trim();
    if (nombre.isEmpty) return;

    setState(() {
      _cargando = true;
    });

    try {
      final id = await _apiClient.obtenerLenguajeId(nombre);
      if (id != null) {
        final palabras = await _apiClient.obtenerPalabras(id);
        if (mounted) {
          setState(() {
            _lenguajeIdActual = id;
            _palabras = palabras;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se encontró el lenguaje $nombre')),
          );
          setState(() {
            _lenguajeIdActual = null;
            _palabras = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> _eliminarPalabra(int palabraId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Palabra'),
        content: const Text('¿Estás seguro de que deseas eliminar esta palabra?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _cargando = true;
    });

    final exito = await _apiClient.eliminarPalabra(palabraId);
    if (exito) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Palabra eliminada')),
        );
      }
      _cargarPalabras();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar la palabra')),
        );
      }
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _eliminarLenguaje() async {
    if (_lenguajeIdActual == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lenguaje'),
        content: const Text('¿Estás seguro de eliminar todo el lenguaje y sus palabras? Esta acción es irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar Lenguaje'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _cargando = true;
    });

    final exito = await _apiClient.eliminarLenguaje(_lenguajeIdActual!);
    if (exito) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lenguaje eliminado exitosamente')),
        );
        Navigator.pop(context); // Volver atrás después de eliminar
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el lenguaje')),
        );
      }
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  void dispose() {
    _lenguajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Lenguaje'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LanguageSelector(controller: _lenguajeController),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargando ? null : _cargarPalabras,
              child: const Text('Cargar Palabras'),
            ),
            const SizedBox(height: 16),
            if (_cargando)
              const Center(child: CircularProgressIndicator())
            else if (_lenguajeIdActual != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Palabras en ${_lenguajeController.text}: ${_palabras.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _palabras.isEmpty
                          ? const Center(child: Text('No hay palabras registradas.'))
                          : ListView.builder(
                              itemCount: _palabras.length,
                              itemBuilder: (context, index) {
                                final palabra = _palabras[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(palabra['texto'] ?? ''),
                                    subtitle: Text('Tipo: ${palabra['tipo']} | Duración: ${palabra['duracion'] ?? 0.0} s'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _eliminarPalabra(palabra['id']),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _eliminarLenguaje,
                      child: const Text('ELIMINAR LENGUAJE'),
                    ),
                  ],
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text('Selecciona un lenguaje y pulsa "Cargar Palabras".'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
