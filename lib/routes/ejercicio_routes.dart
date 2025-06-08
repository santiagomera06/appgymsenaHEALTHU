import 'package:flutter/material.dart';
import 'package:healthu/screens/seleccionar_nivel_screen.dart';

class EjercicioRoutes {
  static const seleccionarNivel = '/seleccionar-nivel';
  static const ejerciciosPrincipiante = '/ejercicios-principiante';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case seleccionarNivel:
        return MaterialPageRoute(
          builder: (_) => const SeleccionarNivelScreen(),
        );
      default:
        return null;
    }
  }
}
