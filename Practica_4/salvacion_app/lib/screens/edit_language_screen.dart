import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../src/api/api_client.dart';
import '../src/api/espectrograma.dart';
import '../src/api/fft.dart';
import '../src/widgets/language_selector.dart';
import 'enviar_sonido.dart';
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

  Future<void> _editarPalabra(Map<String, dynamic> palabra) async {
    final TextEditingController textoController = TextEditingController(text: palabra['texto']);
    
    TipoPalabra tipoSeleccionado = TipoPalabra.values.firstWhere(
      (e) => e.name == palabra['tipo'],
      orElse: () => TipoPalabra.otro,
    );

    final AudioRecorder recorder = AudioRecorder();
    Espectrograma? nuevoEspectrograma;
    bool grabando = false;
    bool guardando = false;

    Future<String> getRutaAudio() async {
      final dir = await getTemporaryDirectory();
      final time = DateTime.now().millisecondsSinceEpoch;
      return '${dir.path}/audio_edit_$time.wav';
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> toggleGrabacion() async {
              try {
                if (grabando) {
                  final path = await recorder.stop();
                  if (path != null) {
                    final frames = await buildSpectrogram(path);
                    setStateDialog(() {
                      nuevoEspectrograma = Espectrograma(frames: frames).normalizar();
                      grabando = false;
                    });
                  }
                  return;
                }

                final permiso = await recorder.hasPermission();
                if (!permiso) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sin permisos de micrófono')),
                    );
                  }
                  return;
                }

                final path = await getRutaAudio();
                await recorder.start(
                  const RecordConfig(
                    encoder: AudioEncoder.wav,
                    sampleRate: 44100,
                    numChannels: 1,
                  ),
                  path: path,
                );

                setStateDialog(() {
                  grabando = true;
                });
              } catch (e) {
                debugPrint('Error grabando audio: $e');
              }
            }

            Future<void> guardarCambios() async {
              setStateDialog(() {
                guardando = true;
              });

              double? duracion;
              if (nuevoEspectrograma != null) {
                duracion = nuevoEspectrograma!.numeroFrames / 100.0;
              }

              final exito = await _apiClient.actualizarPalabra(
                palabra['id'],
                textoController.text.trim(),
                tipoSeleccionado.name,
                duracion,
                nuevoEspectrograma,
              );

              setStateDialog(() {
                guardando = false;
              });

              if (exito) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Palabra actualizada')),
                  );
                }
                _cargarPalabras();
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al actualizar')),
                  );
                }
              }
            }

            return AlertDialog(
              title: const Text('Editar Palabra'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textoController,
                      decoration: const InputDecoration(
                        labelText: 'Texto',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TipoPalabra>(
                      value: tipoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de palabra',
                      ),
                      items: TipoPalabra.values
                          .map((tipo) => DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo.label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            tipoSeleccionado = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: toggleGrabacion,
                      child: Text(grabando ? 'Detener grabación' : 'Grabar nuevo audio'),
                    ),
                    if (nuevoEspectrograma != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Nuevo espectrograma listo', style: TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: guardando ? null : guardarCambios,
                  child: guardando ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    recorder.dispose();
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
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _editarPalabra(palabra),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _eliminarPalabra(palabra['id']),
                                        ),
                                      ],
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
