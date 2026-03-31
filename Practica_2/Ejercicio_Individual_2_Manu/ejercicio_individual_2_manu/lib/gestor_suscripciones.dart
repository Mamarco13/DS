import 'package:flutter/material.dart';
import 'suscripcion.dart';

class GestorSuscripciones extends ChangeNotifier {
  final List<Suscripcion> _subs = [];

  List<Suscripcion> get subs => _subs;

  void agregar(Suscripcion s) {
    _subs.add(s);
    notifyListeners();
  }

  void eliminar(Suscripcion s) {
    _subs.remove(s);
    notifyListeners();
  }

  double get totalMensual {
    return _subs.fold(0, (sum, s) => sum + s.precioMensual);
  }
}