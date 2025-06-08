import 'package:flutter/material.dart';
import 'package:healthu/widgets/boton_en_imagen.dart';
import 'temporizador.dart';

class EjerciciosScreen extends StatelessWidget {
  final String nivel;
  final String enfoque;

  const EjerciciosScreen({
    super.key,
    required this.nivel,
    required this.enfoque,
  });

  @override
  Widget build(BuildContext context) {
    final ejercicios = obtenerEjercicios(nivel, enfoque);

    return Scaffold(
      appBar: AppBar(title: Text('$enfoque - Nivel $nivel')),
      body: ListView.builder(
        itemCount: ejercicios.length,
        itemBuilder: (context, index) {
          final ejercicio = ejercicios[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: BotonEnImagen(
              texto: ejercicio['nombre'] ?? '',
              imagen: ejercicio['imagen'] ?? '',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TemporizadorPage(
                          titulo: ejercicio['nombre'] ?? '',
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

  List<Map<String, String>> obtenerEjercicios(String nivel, String enfoque) {
    // Puedes extender esta lista según tus necesidades
    final todos = {
      'Básico': {
        'Cuerpo Completo': [
          {'nombre': 'Jumping Jacks', 'imagen': 'assets/images/full.png'},
          {'nombre': 'Sentadillas', 'imagen': 'assets/images/full.png'},
        ],
        'Piernas': [
          {'nombre': 'Zancadas', 'imagen': 'assets/images/piernas.png'},
          {
            'nombre': 'Sentadilla isométrica',
            'imagen': 'assets/images/piernas.png',
          },
        ],
      },
      'Intermedio': {
        'Brazos': [
          {'nombre': 'Flexiones', 'imagen': 'assets/images/brazos.png'},
          {
            'nombre': 'Curl con mancuerna',
            'imagen': 'assets/images/brazos.png',
          },
        ],
      },
    };

    return todos[nivel]?[enfoque] ?? [];
  }
}
