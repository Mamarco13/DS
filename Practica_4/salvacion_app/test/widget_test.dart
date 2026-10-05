import 'package:flutter_test/flutter_test.dart';
import 'package:salvacion_app/main.dart';

void main() {
  testWidgets('App arranca correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MiApp());
    expect(find.text('Mis lenguajes'), findsOneWidget);
  });
}
