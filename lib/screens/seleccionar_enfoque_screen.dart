import 'package:flutter/material.dart';
import '../widgets/boton_en_imagen.dart';
import 'temporizador.dart';

class EjerciciosPrincipianteScreen extends StatelessWidget {
  final String nivel;
  final String enfoque;

  const EjerciciosPrincipianteScreen({
    super.key,
    required this.nivel,
    required this.enfoque,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> ejercicios = _cargarEjercicios(nivel, enfoque);

    return Scaffold(
      appBar: AppBar(
        title: Text('$enfoque - Nivel $nivel'),
      ),
      body: ListView.builder(
        itemCount: ejercicios.length,
        itemBuilder: (context, index) {
          final ejercicio = ejercicios[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: BotonEnImagen(
              texto: ejercicio['nombre']!,
              imagen: ejercicio['imagen']!,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TemporizadorPage(
                      titulo: ejercicio['nombre']!,
                      segundos: 300,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<Map<String, String>> _cargarEjercicios(String nivel, String enfoque) {
    // Datos de ejemplo, puedes personalizar por nivel y enfoque
    return [
      {
        'nombre': 'Sentadillas básicas',
        'imagen': 'assets/images/sentadillas.png',
      },
      {
        'nombre': 'Flexiones apoyadas',
        'imagen': 'assets/images/flexiones.png',
      },
      {
        'nombre': 'Abdominales cortos',
        'imagen': 'assets/images/abdominales.png',
      },
    ];
  }
}
