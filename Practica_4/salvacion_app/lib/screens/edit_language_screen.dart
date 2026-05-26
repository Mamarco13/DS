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

  Widget _buildPanel({required String titulo, required IconData icono, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111122).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: Colors.deepPurpleAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note),
            SizedBox(width: 10),
            Text('GESTIÓN DE DATOS'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2A1A3A), Color(0xFF050510)],
            radius: 1.5,
            center: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPanel(
                titulo: "SELECCIÓN DE LENGUAJE",
                icono: Icons.language,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LanguageSelector(controller: _lenguajeController),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _cargando ? null : _cargarPalabras,
                      icon: const Icon(Icons.download),
                      label: const Text('CARGAR BASE DE DATOS', style: TextStyle(letterSpacing: 1.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
                        foregroundColor: Colors.deepPurpleAccent,
                        side: const BorderSide(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_cargando)
                const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent)))
              else if (_lenguajeIdActual != null)
                Expanded(
                  child: _buildPanel(
                    titulo: "REGISTROS ENCONTRADOS (${_palabras.length})",
                    icono: Icons.dataset,
                    child: Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _palabras.isEmpty
                                ? const Center(child: Text('NO HAY DATOS EN ESTE SECTOR.', style: TextStyle(color: Colors.white54, letterSpacing: 2)))
                                : ListView.builder(
                                    itemCount: _palabras.length,
                                    itemBuilder: (context, index) {
                                      final palabra = _palabras[index];
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ListTile(
                                          leading: const Icon(Icons.memory, color: Colors.deepPurpleAccent),
                                          title: Text(
                                            (palabra['texto'] ?? '').toString().toUpperCase(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                                          ),
                                          subtitle: Text(
                                            'Tipo: ${palabra['tipo']} | Dur: ${palabra['duracion'] ?? 0.0} s',
                                            style: const TextStyle(color: Colors.white54, fontFamily: 'monospace'),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.cyanAccent),
                                                onPressed: () => _editarPalabra(palabra),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.redAccent),
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
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.2),
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                            icon: const Icon(Icons.warning),
                            label: const Text('PURGAR LENGUAJE', style: TextStyle(letterSpacing: 2)),
                            onPressed: _eliminarLenguaje,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'SELECCIONA UN SECTOR Y EXTRAE LOS DATOS.',
                      style: TextStyle(color: Colors.white24, letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
