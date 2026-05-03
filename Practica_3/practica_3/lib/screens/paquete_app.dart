import 'package:flutter/material.dart';
import '../Paquete.dart';
import '../Vuelo.dart';
import '../Hotel.dart';
import '../PoliticaVuelo/LowCost.dart';
import '../PoliticaVuelo/Business.dart';
import '../PoliticaHotel/SoloAlojamiento.dart';
import '../PoliticaHotel/TodoIncluido.dart';
import '../ServicioTuristico.dart';
import '../PoliticaVuelo/PoliticaVuelo.dart';
import '../PoliticaHotel/PoliticaHotel.dart';

class PaqueteApp extends StatelessWidget {
  const PaqueteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Reservas Turísticas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      home: const PaquetePage(),
    );
  }
}

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

  Future<void> _verPaquete(Paquete paquete) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaquetePage(paquete: paquete)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _abrirFormularioVuelo() async {
    final vuelo = await Navigator.push<Vuelo>(
      context,
      MaterialPageRoute(builder: (_) => const FormVueloPage()),
    );
    if (vuelo != null && mounted) {
      setState(() => _paquete.agregarServicio(vuelo));
    }
  }

  Future<void> _abrirFormularioHotel() async {
    final hotel = await Navigator.push<Hotel>(
      context,
      MaterialPageRoute(builder: (_) => const FormHotelPage()),
    );
    if (hotel != null && mounted) {
      setState(() => _paquete.agregarServicio(hotel));
    }
  }

  Future<void> _abrirFormularioPaquete() async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Nuevo paquete'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Nombre del paquete'),
            onSubmitted: (_) => Navigator.pop(ctx, ctrl.text.trim()),
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
      MaterialPageRoute(
        builder: (_) => PaquetePage(paquete: subPaquete, esNuevo: true),
      ),
    );

    if (resultado != null && mounted) {
      setState(() => _paquete.agregarServicio(resultado));
    }
  }

  void _eliminar(ServicioTuristico servicio) {
    setState(() => _paquete.eliminarServicio(servicio));
  }

  void _guardar() {
    if (_paquete.servicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Añade al menos un servicio antes de guardar'),
        ),
      );
      return;
    }

    if (widget.esNuevo) {
      Navigator.pop(context, _paquete);
      return;
    }

    if (_esSubPaquete) {
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Paquete "${_paquete.nombre}" guardado · ${_paquete.servicios.length} servicios · ${_paquete.getPrecio().toStringAsFixed(2)}€',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicios = _paquete.servicios;
    final total = _paquete.getPrecio();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSummary(
                nombre: _paquete.nombre,
                total: total,
                servicios: servicios.length,
                esSubPaquete: _esSubPaquete,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final minWidth = constraints.maxWidth < 500
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: minWidth,
                        child: _ActionCard(
                          icon: Icons.flight,
                          title: 'Añadir vuelo',
                          subtitle: 'Configura tarifa y precio base',
                          color: const Color(0xFF2563EB),
                          onTap: _abrirFormularioVuelo,
                        ),
                      ),
                      SizedBox(
                        width: minWidth,
                        child: _ActionCard(
                          icon: Icons.hotel,
                          title: 'Añadir hotel',
                          subtitle: 'Define noches y régimen',
                          color: const Color(0xFF0F766E),
                          onTap: _abrirFormularioHotel,
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth,
                        child: _ActionCard(
                          icon: Icons.luggage,
                          title: 'Añadir paquete',
                          subtitle: 'Crea un subpaquete reutilizable',
                          color: const Color(0xFF7C3AED),
                          onTap: _abrirFormularioPaquete,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Servicios',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${servicios.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (servicios.isEmpty)
                const _EmptyState()
              else
                ListView.separated(
                  itemCount: servicios.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final servicio = servicios[index];
                    return _ServicioCard(
                      servicio: servicio,
                      onEliminar: () => _eliminar(servicio),
                      onTap: servicio is Paquete
                          ? () => _verPaquete(servicio)
                          : null,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomSummary(total: total, servicios: servicios.length),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar paquete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  final String nombre;
  final double total;
  final int servicios;
  final bool esSubPaquete;

  const _HeaderSummary({
    required this.nombre,
    required this.total,
    required this.servicios,
    required this.esSubPaquete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.travel_explore, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      esSubPaquete ? 'Subpaquete' : 'Planificador de viaje',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nombre,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricBox(label: 'Servicios', value: '$servicios'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricBox(
                  label: 'Total',
                  value: '${total.toStringAsFixed(2)}€',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.add_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicioCard extends StatelessWidget {
  final ServicioTuristico servicio;
  final VoidCallback onEliminar;
  final VoidCallback? onTap;

  const _ServicioCard({
    required this.servicio,
    required this.onEliminar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = _describeServicio(servicio);
    final titulo = info.titulo;
    final subtitulo = info.subtitulo;
    final icono = info.icono;
    final color = info.color;
    final esInteractivo = onTap != null;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icono, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${servicio.getPrecio().toStringAsFixed(2)}€',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (esInteractivo)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.chevron_right,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      IconButton(
                        onPressed: onEliminar,
                        icon: const Icon(Icons.delete_outline),
                        color: Theme.of(context).colorScheme.error,
                        tooltip: 'Eliminar',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

({String titulo, String subtitulo, IconData icono, Color color})
_describeServicio(ServicioTuristico servicio) {
  if (servicio is Paquete) {
    return (
      titulo: 'Paquete: ${servicio.nombre}',
      subtitulo: '${servicio.servicios.length} servicio(s)',
      icono: Icons.luggage,
      color: const Color(0xFF7C3AED),
    );
  }

  if (servicio is Vuelo) {
    return (
      titulo: 'Vuelo ${servicio.id}',
      subtitulo: 'Tarifa: ${servicio.politica.runtimeType.toString()}',
      icono: Icons.flight,
      color: const Color(0xFF2563EB),
    );
  }

  final hotel = servicio as Hotel;
  return (
    titulo: 'Hotel ${hotel.nombre}',
    subtitulo: 'Régimen: ${hotel.politica.runtimeType.toString()}',
    icono: Icons.hotel,
    color: const Color(0xFF0F766E),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 44,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Todavía no hay servicios',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Añade un vuelo, un hotel o un subpaquete para empezar.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final double total;

  const _PriceChip({required this.total});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('${total.toStringAsFixed(2)}€'),
      side: BorderSide.none,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BottomSummary extends StatelessWidget {
  final double total;
  final int servicios;

  const _BottomSummary({required this.total, required this.servicios});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen rápido',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '$servicios servicios',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            '${total.toStringAsFixed(2)}€',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class FormVueloPage extends StatefulWidget {
  const FormVueloPage({super.key});

  @override
  State<FormVueloPage> createState() => _FormVueloPageState();
}

class _FormVueloPageState extends State<FormVueloPage> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  String _politicaId = 'lowcost';

  @override
  void dispose() {
    _idCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  PoliticaVuelo get _politica =>
      _politicaId == 'business' ? TarifaBusiness() : TarifaLowCost();

  void _guardar() {
    final esValido = _formKey.currentState?.validate() ?? false;
    if (!esValido) return;

    try {
      final vuelo = Vuelo(
        id: _idCtrl.text.trim(),
        precioBase: double.parse(_precioCtrl.text.trim()),
        politica: _politica,
      );

      Navigator.pop(context,vuelo);
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
          ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo vuelo')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FormHeader(
                  icon: Icons.flight_takeoff,
                  title: 'Datos del vuelo',
                  subtitle: 'Completa el código, el precio base y la tarifa.',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _idCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Código de vuelo',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Introduce un código';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precioCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Precio base (€)',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null) {
                      return 'Introduce un número válido';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _guardar(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _politicaId,
                  decoration: const InputDecoration(labelText: 'Tarifa'),
                  items: const [
                    DropdownMenuItem(
                      value: 'lowcost',
                      child: Text('Low Cost (+20€ recargo)'),
                    ),
                    DropdownMenuItem(
                      value: 'business',
                      child: Text('Business (×1.8)'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _politicaId = value ?? 'lowcost'),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir vuelo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormHotelPage extends StatefulWidget {
  const FormHotelPage({super.key});

  @override
  State<FormHotelPage> createState() => _FormHotelPageState();
}

class _FormHotelPageState extends State<FormHotelPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _nochesCtrl = TextEditingController();
  String _politicaId = 'solo';

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _nochesCtrl.dispose();
    super.dispose();
  }

  PoliticaHotel get _politica =>
      _politicaId == 'todo' ? TodoIncluido() : SoloAlojamiento();

  void _guardar() {
    final esValido = _formKey.currentState?.validate() ?? false;
    if (!esValido) return;

    try {
      final hotel = Hotel(
        nombre: _nombreCtrl.text.trim(),
        precioNoche: double.parse(_precioCtrl.text.trim()),
        noches: int.parse(_nochesCtrl.text.trim()),
        politica: _politica,
      );

      Navigator.pop(context, hotel);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo hotel')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FormHeader(
                  icon: Icons.hotel,
                  title: 'Datos del hotel',
                  subtitle:
                      'Introduce nombre, precio por noche, noches y régimen.',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del hotel',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Introduce un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precioCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Precio por noche (€)',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null) {
                      return 'Introduce un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nochesCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Número de noches',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null) {
                      return 'Introduce un número entero válido';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _guardar(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _politicaId,
                  decoration: const InputDecoration(labelText: 'Régimen'),
                  items: const [
                    DropdownMenuItem(
                      value: 'solo',
                      child: Text('Solo alojamiento'),
                    ),
                    DropdownMenuItem(
                      value: 'todo',
                      child: Text('Todo incluido (+50€/noche)'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _politicaId = value ?? 'solo'),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir hotel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FormHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
