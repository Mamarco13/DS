import 'package:flutter/material.dart';
import 'Paquete.dart';
import 'Vuelo.dart';
import 'Hotel.dart';
import 'PoliticaVuelo/LowCost.dart';
import 'PoliticaVuelo/Business.dart';
import 'PoliticaHotel/SoloAlojamiento.dart';
import 'PoliticaHotel/TodoIncluido.dart';
import 'ServicioTuristico.dart';
import 'PoliticaVuelo/PoliticaVuelo.dart';
import 'PoliticaHotel/PoliticaHotel.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservas Turísticas',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PaquetePage(),
    );
  }
}

// ─── Pantalla principal ───────────────────────────────────────────────────────

class PaquetePage extends StatefulWidget {
  final Paquete? paquete;
  final bool esNuevo;
  const PaquetePage({super.key, this.paquete, this.esNuevo = false});

  @override
  State<PaquetePage> createState() => _PaquetePageState();
}

class _PaquetePageState extends State<PaquetePage> {
  late final Paquete _paquete;

  @override
  void initState() {
    super.initState();
    _paquete = widget.paquete ?? Paquete(nombre: 'Mi paquete vacacional');
  }

  bool get _esSubPaquete => widget.paquete != null;

  void _verPaquete(Paquete p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaquetePage(paquete: p)),
    );
    if (mounted) setState(() {});
  }

  void _abrirFormularioVuelo() async {
    final vuelo = await Navigator.push<Vuelo>(
      context,
      MaterialPageRoute(builder: (_) => const FormVueloPage()),
    );
    if (vuelo != null) setState(() => _paquete.agregarServicio(vuelo));
  }

  void _abrirFormularioHotel() async {
    final hotel = await Navigator.push<Hotel>(
      context,
      MaterialPageRoute(builder: (_) => const FormHotelPage()),
    );
    if (hotel != null) setState(() => _paquete.agregarServicio(hotel));
  }

  void _abrirFormularioPaquete() async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Nuevo paquete'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre del paquete',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (nombre == null || nombre.isEmpty || !mounted) return;

    final subPaquete = Paquete(nombre: nombre);
    final resultado = await Navigator.push<Paquete>(
      context,
      MaterialPageRoute(builder: (_) => PaquetePage(paquete: subPaquete, esNuevo: true)),
    );
    if (resultado != null && mounted) setState(() => _paquete.agregarServicio(resultado));
  }

  void _eliminar(ServicioTuristico s) {
    setState(() => _paquete.eliminarServicio(s));
  }

  void _guardar() {
    if (_paquete.servicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade al menos un servicio antes de guardar')),
      );
      return;
    }
    if (widget.esNuevo) {
      Navigator.pop(context, _paquete);
    } else if (_esSubPaquete) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Paquete "${_paquete.nombre}" guardado — '
            '${_paquete.servicios.length} servicio(s) — '
            '${_paquete.getPrecio().toStringAsFixed(2)}€',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicios = _paquete.servicios;

    return Scaffold(
      appBar: AppBar(title: Text(_paquete.nombre)),
      body: Column(
        children: [
          Expanded(
            child: servicios.isEmpty
                ? const Center(child: Text('No hay servicios añadidos'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: servicios.length,
                    itemBuilder: (_, i) => _ServicioTile(
                      servicio: servicios[i],
                      onEliminar: () => _eliminar(servicios[i]),
                      onTap: servicios[i] is Paquete
                          ? () => _verPaquete(servicios[i] as Paquete)
                          : null,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: const Text('Guardar paquete'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          _TotalBar(total: _paquete.getPrecio()),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'vuelo',
            onPressed: _abrirFormularioVuelo,
            icon: const Icon(Icons.flight),
            label: const Text('Añadir vuelo'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'hotel',
            onPressed: _abrirFormularioHotel,
            icon: const Icon(Icons.hotel),
            label: const Text('Añadir hotel'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'paquete',
            onPressed: _abrirFormularioPaquete,
            icon: const Icon(Icons.luggage),
            label: const Text('Añadir paquete'),
          ),
        ],
      ),
    );
  }
}

// ─── Tile de servicio ─────────────────────────────────────────────────────────

class _ServicioTile extends StatelessWidget {
  final ServicioTuristico servicio;
  final VoidCallback onEliminar;
  final VoidCallback? onTap;

  const _ServicioTile({required this.servicio, required this.onEliminar, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String titulo;
    final String subtitulo;
    final IconData icono;

    if (servicio is Paquete) {
      final p = servicio as Paquete;
      titulo = 'Paquete: ${p.nombre}';
      subtitulo = '${p.servicios.length} servicio(s)';
      icono = Icons.luggage;
    } else if (servicio is Vuelo) {
      final v = servicio as Vuelo;
      titulo = 'Vuelo ${v.id}';
      subtitulo = 'Tarifa: ${v.politica.runtimeType.toString()}';
      icono = Icons.flight;
    } else {
      final h = servicio as Hotel;
      titulo = 'Hotel ${h.nombre}';
      subtitulo = 'Régimen: ${h.politica.runtimeType.toString()}';
      icono = Icons.hotel;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${servicio.getPrecio().toStringAsFixed(2)}€',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onEliminar,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Barra de total ───────────────────────────────────────────────────────────

class _TotalBar extends StatelessWidget {
  final double total;
  const _TotalBar({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total paquete',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text('${total.toStringAsFixed(2)}€',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─── Formulario Vuelo ─────────────────────────────────────────────────────────

class FormVueloPage extends StatefulWidget {
  const FormVueloPage({super.key});

  @override
  State<FormVueloPage> createState() => _FormVueloPageState();
}

class _FormVueloPageState extends State<FormVueloPage> {
  final _idCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  String _politicaId = 'lowcost';

  PoliticaVuelo get _politica =>
      _politicaId == 'business' ? TarifaBusiness() : TarifaLowCost();

  void _guardar() {
    final id = _idCtrl.text.trim();
    final precio = double.tryParse(_precioCtrl.text.trim());
    if (id.isEmpty || precio == null) return;

    Navigator.pop(
      context,
      Vuelo(id: id, precioBase: precio, politica: _politica),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo vuelo')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _idCtrl,
              decoration: const InputDecoration(
                labelText: 'Código de vuelo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _precioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio base (€)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _politicaId,
              decoration: const InputDecoration(
                labelText: 'Tarifa',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'lowcost', child: Text('Low Cost (+20€ recargo)')),
                DropdownMenuItem(value: 'business', child: Text('Business (×1.8)')),
              ],
              onChanged: (p) => setState(() => _politicaId = p!),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.add),
              label: const Text('Añadir vuelo'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Formulario Hotel ─────────────────────────────────────────────────────────

class FormHotelPage extends StatefulWidget {
  const FormHotelPage({super.key});

  @override
  State<FormHotelPage> createState() => _FormHotelPageState();
}

class _FormHotelPageState extends State<FormHotelPage> {
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _nochesCtrl = TextEditingController();
  String _politicaId = 'solo';

  PoliticaHotel get _politica =>
      _politicaId == 'todo' ? TodoIncluido() : SoloAlojamiento();

  void _guardar() {
    final nombre = _nombreCtrl.text.trim();
    final precio = double.tryParse(_precioCtrl.text.trim());
    final noches = int.tryParse(_nochesCtrl.text.trim());
    if (nombre.isEmpty || precio == null || noches == null) return;

    Navigator.pop(
      context,
      Hotel(nombre: nombre, precioNoche: precio, noches: noches, politica: _politica),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo hotel')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del hotel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _precioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio por noche (€)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nochesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de noches',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _politicaId,
              decoration: const InputDecoration(
                labelText: 'Régimen',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'solo', child: Text('Solo alojamiento')),
                DropdownMenuItem(value: 'todo', child: Text('Todo incluido (+50€/noche)')),
              ],
              onChanged: (p) => setState(() => _politicaId = p!),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.add),
              label: const Text('Añadir hotel'),
            ),
          ],
        ),
      ),
    );
  }
}
