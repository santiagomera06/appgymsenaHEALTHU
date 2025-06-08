import 'package:flutter/material.dart';
import 'package:healthu/screens/ejercicios_y_desafios_screen.dart';
import 'package:healthu/screens/ejercicios_principiante_screen.dart';



class DesafiosRoutes {
  static const String desafios = '/desafios';
  static const String ejerciciosPrincipiante = '/ejercicios_principiante';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case desafios:
        return MaterialPageRoute(
          builder: (_) => const EjerciciosYDesafiosScreen(),
        );

      case ejerciciosPrincipiante:
        final args = settings.arguments as Map<String, String>;
        final nivel = args['nivel'] ?? 'principiante';
        final enfoque = args['enfoque'] ?? 'general';

        return MaterialPageRoute(
          builder: (_) => EjerciciosPrincipianteScreen(
            nivel: nivel,
            enfoque: enfoque,
          ),
        );

      default:
        return null;
    }
  }
}
