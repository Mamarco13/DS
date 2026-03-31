import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gestor_suscripciones.dart';
import '../suscripcion.dart';

class PantallaSuscripciones extends StatelessWidget {
  const PantallaSuscripciones({super.key});

  @override
  Widget build(BuildContext context) {
    final gestor = context.watch<GestorSuscripciones>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Suscripciones"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // 💰 TOTAL
          Text(
            "Total: ${gestor.totalMensual.toStringAsFixed(2)} €",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // 📋 LISTA
          Expanded(
            child: gestor.subs.isEmpty
                ? const Center(child: Text("No hay suscripciones"))
                : ListView.builder(
                    itemCount: gestor.subs.length,
                    itemBuilder: (_, i) {
                      final s = gestor.subs[i];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(s.descripcion),
                          subtitle: Text("${s.precioMensual} €"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => gestor.eliminar(s),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ➕ BOTÓN AÑADIR
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogo(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🧾 DIÁLOGO PARA AÑADIR
  void _mostrarDialogo(BuildContext context) {
    final descripcionController = TextEditingController();
    final precioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nueva suscripción"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descripcionController,
                decoration:
                    const InputDecoration(labelText: "Descripción"),
              ),
              TextField(
                controller: precioController,
                decoration:
                    const InputDecoration(labelText: "Precio mensual"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Agregar"),
              onPressed: () {
                final descripcion = descripcionController.text;
                final precio =
                    double.tryParse(precioController.text) ?? 0;

                if (descripcion.isEmpty || precio <= 0) return;

                final gestor = context.read<GestorSuscripciones>();

                gestor.agregar(
                  Suscripcion(
                    descripcion: descripcion,
                    precioMensual: precio,
                  ),
                );

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}