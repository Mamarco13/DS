import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salvacion_app/main.dart';

void main() {
  group('HomeScreen – smoke test', () {
    testWidgets('Renderiza los tres botones de navegación', (WidgetTester tester) async {
      await tester.pumpWidget(const MiApp());

      expect(find.text('Añadir Palabra (CRUD)'), findsOneWidget);
      expect(find.text('Traductor Universal'), findsOneWidget);
      expect(find.text('Editar / Eliminar Lenguaje'), findsOneWidget);
    });

    testWidgets('La AppBar muestra el título "Inicio"', (WidgetTester tester) async {
      await tester.pumpWidget(const MiApp());

      expect(find.text('Inicio'), findsOneWidget);
    });

    testWidgets('Contiene exactamente tres ElevatedButton', (WidgetTester tester) async {
      await tester.pumpWidget(const MiApp());

      expect(find.byType(ElevatedButton), findsNWidgets(3));
    });
  });
}
