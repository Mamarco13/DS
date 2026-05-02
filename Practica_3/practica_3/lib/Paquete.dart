import 'ServicioTuristico.dart';

class Paquete implements ServicioTuristico {
  final String nombre;
  final List<ServicioTuristico> servicios = [];

  Paquete({required this.nombre});

  void agregarServicio(ServicioTuristico servicio) {
    servicios.add(servicio);
  }

  void eliminarServicio(ServicioTuristico servicio) {
    servicios.remove(servicio);
  }

  @override
  double getPrecio() =>
      servicios.fold(0.0, (total, servicio) => total + servicio.getPrecio());
}
