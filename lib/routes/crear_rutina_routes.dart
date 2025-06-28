import 'package:flutter/material.dart';
import 'package:healthu/screens/crear%20rutina/crear_rutina_screen.dart';

class CrearRutinaRoutes {
  static const String crearRutina = '/crear-rutina';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case crearRutina:
        return MaterialPageRoute(builder: (_) => const CrearRutinaScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}