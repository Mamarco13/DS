import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<String>> cargarContrasenias() async {
  final String response =
      await rootBundle.loadString('assets/contrasenias.json');
  final data = json.decode(response);
  return List<String>.from(data['Contrasenias']);
}

Future<List<String>> cargarUsuarios() async {
  final String response =
      await rootBundle.loadString('assets/usuarios.json');
  final data = json.decode(response);
  return List<String>.from(data['emails']);
}