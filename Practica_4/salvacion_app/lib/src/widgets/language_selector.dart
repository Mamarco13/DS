import 'package:flutter/material.dart';
import '../api/api_client.dart';

class LanguageSelector extends StatefulWidget {
  final TextEditingController controller;

  const LanguageSelector({super.key, required this.controller});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final RailsApiClient _apiClient = RailsApiClient();
  List<Map<String, dynamic>> _lenguajes = [];
  bool _isLoading = true;
  String? _selectedValue;
  bool _isCreatingNew = false;
  final TextEditingController _newLanguageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLenguajes();
  }

  Future<void> _loadLenguajes() async {
    final lenguajes = await _apiClient.obtenerLenguajes();
    if (mounted) {
      setState(() {
        _lenguajes = lenguajes;
        _isLoading = false;
        
        // Select the first language if available, or if controller has a value, select it
        if (widget.controller.text.isNotEmpty && lenguajes.any((l) => l['nombre'] == widget.controller.text)) {
          _selectedValue = widget.controller.text;
        } else if (lenguajes.isNotEmpty) {
          _selectedValue = lenguajes.first['nombre'];
          widget.controller.text = _selectedValue!;
        } else {
          // If no languages exist, default to creating new
          _isCreatingNew = true;
          widget.controller.text = '';
        }
      });
    }
  }

  @override
  void dispose() {
    _newLanguageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isCreatingNew) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _newLanguageController,
              decoration: const InputDecoration(
                labelText: 'Nuevo Lenguaje',
                hintText: 'Nombre del lenguaje',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                widget.controller.text = val;
              },
            ),
          ),
          if (_lenguajes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isCreatingNew = false;
                  widget.controller.text = _selectedValue ?? '';
                });
              },
            ),
        ],
      );
    }

    // Comprobamos si el valor seleccionado existe en la lista de lenguajes
    // si no existe lo ponemos a nulo para evitar error del DropdownButton
    if (_selectedValue != null && !_lenguajes.any((l) => l['nombre'] == _selectedValue)) {
      _selectedValue = null;
    }

    return DropdownButtonFormField<String>(
      value: _selectedValue,
      decoration: const InputDecoration(
        labelText: 'Lenguaje de destino',
        border: OutlineInputBorder(),
      ),
      items: [
        ..._lenguajes.map((l) {
          return DropdownMenuItem<String>(
            value: l['nombre'],
            child: Text(l['nombre']),
          );
        }),
        const DropdownMenuItem<String>(
          value: '__CREAR_NUEVO__',
          child: Text('Crear nuevo...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        )
      ],
      onChanged: (val) {
        if (val == '__CREAR_NUEVO__') {
          setState(() {
            _isCreatingNew = true;
            _newLanguageController.text = '';
            widget.controller.text = '';
          });
        } else {
          setState(() {
            _selectedValue = val;
            widget.controller.text = val ?? '';
          });
        }
      },
    );
  }
}
