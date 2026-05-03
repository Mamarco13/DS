import 'package:flutter_test/flutter_test.dart';
import 'package:practica_3/PoliticaHotel/PoliticaHotel.dart';
import 'package:practica_3/PoliticaVuelo/PoliticaVuelo.dart';

import 'package:practica_3/Vuelo.dart';
import 'package:practica_3/Hotel.dart';
import 'package:practica_3/Paquete.dart';

import 'package:practica_3/PoliticaVuelo/LowCost.dart';
import 'package:practica_3/PoliticaVuelo/Business.dart';

import 'package:practica_3/PoliticaHotel/SoloAlojamiento.dart';
import 'package:practica_3/PoliticaHotel/TodoIncluido.dart';

// Clase auxiliar para el test Vuelo delega cálculo a su política
class PoliticaVueloFake implements PoliticaVuelo {
  @override
  double calcular(double base) => 123456789;
}

// Clase auxiliar para test Hotel devuelve precio según su política
class PoliticaHotelFake implements PoliticaHotel {
  @override
  double calcular(double precioNoche, int noche) => 123456789;
}

void main() {

  // ================================
  // GRUPO 1: POLÍTICAS DE TARIFACIÓN
  // ================================
  group('Políticas de Tarifación',(){

    test('TarifaLowCost añade recargo fijo', () {
      final politica = TarifaLowCost();

      final resultado = politica.calcular(100);

      // Recargo = 20€. Resultado esperado: 100 + 20
      expect(resultado, 120);
    });

    test('TarifaBusiness aplica multiplicador', () {
      final politica = TarifaBusiness();

      final resultado = politica.calcular(100);

      // Multiplicador: 1'8. Resultado esperado: 100 * 1'8
      expect(resultado, 180);
    });

    test('SoloAlojamiento calcula precio correcto', () {
      final politica = SoloAlojamiento();

      final resultado = politica.calcular(50, 3);

      // Ejemplo: 50€ 3 noches. Resultado esperado: 50€ * 3
      expect(resultado, 150);
    });

    test('TodoIncluido añade suplemento diario', () {
      final politica = TodoIncluido();

      final resultado = politica.calcular(50, 2);

      // Ejemplo: 50€ noche, 2 noche con suplemento.
      // Suplemento = 50€. Resultado esperado: (50 + 50) * 2
      expect(resultado, 200);
    });
  });

  // =====================================
  // GRUPO 2: SERVICIOS INDIVIDUALES (HOJAS)
  // =====================================
  group('Servicios Individuales', () {

    test('Vuelo lanza excepción si precio base es negativo', () {
      expect(
            () => Vuelo(id: 'V1',
          precioBase: -100,
          politica: TarifaLowCost(),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Hotel no permite noches <= 0', () {
      expect(
            () => Hotel(
          nombre: 'Hotel Test',
          precioNoche: 50,
          noches: 0,
          politica: SoloAlojamiento(),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Vuelo delega cálculo a su política', () {
      final vuelo = Vuelo(
        id: 'V1',
        precioBase: 100,
        politica: PoliticaVueloFake(),
      );

      final precio = vuelo.getPrecio();

      expect(precio, 123456789);
    });

    test('Hotel devuelve precio según su política', () {
      final hotel = Hotel(
        nombre: 'Hotel Test',
        precioNoche: 50,
        noches: 2,
        politica: PoliticaHotelFake(),
      );

      final precio = hotel.getPrecio();

      expect(precio, 123456789);
    });
  });

  // =====================================
  // GRUPO 3: AGRUPACIÓN DE PAQUETES
  // =====================================
  group('Agrupación de Paquetes', () {

    test('Paquete vacío devuelve 0', () {
      final paquete = Paquete(nombre: 'Vacío');

      expect(paquete.getPrecio(), 0);
    });

    test('Paquete suma servicios correctamente', () {
      final paquete = Paquete(nombre: 'Test');

      final vuelo = Vuelo(
        id: 'V1',
        precioBase: 100,
        politica: TarifaLowCost(), // 120
      );

      final hotel = Hotel(
        nombre: 'Hotel',
        precioNoche: 50,
        noches: 2,
        politica: SoloAlojamiento(), // 100
      );

      paquete.agregarServicio(vuelo);
      paquete.agregarServicio(hotel);

      // Resultado esperado 120 + 100
      expect(paquete.getPrecio(), 220);
    });

    test('Paquetes anidados suman correctamente', () {
      final paqueteRaiz = Paquete(nombre: 'Raiz');
      final subPaquete = Paquete(nombre: 'Sub');

      final vuelo1 = Vuelo(
        id: 'V1',
        precioBase: 100,
        politica: TarifaLowCost(), // 120
      );

      final vuelo2 = Vuelo(
        id: 'V2',
        precioBase: 200,
        politica: TarifaLowCost(), //220
      );

      subPaquete.agregarServicio(vuelo1);
      paqueteRaiz.agregarServicio(vuelo2);
      paqueteRaiz.agregarServicio(subPaquete);

      // Resultado esperado: 120 + 220
      expect(paqueteRaiz.getPrecio(), 340);
    });

    test('Cambio de política actualiza precio total', () {
      final paquete = Paquete(nombre: 'Test');

      final vuelo = Vuelo(
        id: 'V1',
        precioBase: 100,
        politica: TarifaBusiness(), // 180
      );

      paquete.agregarServicio(vuelo);

      expect(paquete.getPrecio(), 180);

      // Cambiamos política
      final vueloNuevo = Vuelo(
        id: 'V1',
        precioBase: 100,
        politica: TarifaLowCost(), // 120
      );

      paquete.eliminarServicio(vuelo);
      paquete.agregarServicio(vueloNuevo);

      expect(paquete.getPrecio(), 120);
    });
  });
}