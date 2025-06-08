import 'package:flutter/material.dart';
import 'package:healthu/routes/desafios_routes.dart';
import 'package:healthu/routes/crear_rutina_routes.dart';
import 'package:healthu/routes/ejercicio_routes.dart';

import 'package:healthu/screens/ejercicios_y_desafios_screen.dart';
import 'package:healthu/screens/seleccionar_nivel_screen.dart';
import 'package:healthu/screens/ejercicios_principiante_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HEALTHU',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      initialRoute: DesafiosRoutes.desafios,
      routes: {
        DesafiosRoutes.desafios: (context) => const EjerciciosYDesafiosScreen(),
        EjercicioRoutes.seleccionarNivel: (context) => const SeleccionarNivelScreen(),
        CrearRutinaRoutes.crearRutina: (context) => const Placeholder(),

        // Ruta dinámica para ejercicios por nivel y enfoque
        EjercicioRoutes.ejerciciosPrincipiante: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return EjerciciosPrincipianteScreen(
            nivel: args['nivel']!,
            enfoque: args['enfoque']!,
          );
        },
      },
      onGenerateRoute: (settings) {
        final route = DesafiosRoutes.generateRoute(settings);
        if (route != null) return route;

        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
      },
    );
  }
}
