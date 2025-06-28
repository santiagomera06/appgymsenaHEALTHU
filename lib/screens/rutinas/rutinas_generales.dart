import 'package:flutter/material.dart';
import '../../widgets/boton_en_imagen.dart';
import '../../widgets/barra_navegacion.dart';
import '../../widgets/temporizador.dart';

class RutinasGenerales extends StatefulWidget {
  const RutinasGenerales({super.key});

  @override
  State<RutinasGenerales> createState() => _RutinasGeneralesState();
}

class _RutinasGeneralesState extends State<RutinasGenerales> {
  String nivelSeleccionado = 'Todos';

  final List<Map<String, dynamic>> ejercicios = [
    {
      'titulo': 'Full Body Básico',
      'nivel': 'Principiante',
      'etiqueta': 'FULL BODY',
      'descripcion': 'Rutina básica para activar todo el cuerpo.',
      'imagen': 'assets/images/full.png',
      'detalles': ['Sentadillas', 'Flexiones pared', 'Jumping jacks'],
    },
    {
      'titulo': 'Full Body Intermedio',
      'nivel': 'Intermedio',
      'etiqueta': 'FULL BODY',
      'descripcion': 'Rutina intermedia para resistencia y fuerza.',
      'imagen': 'assets/images/full.png',
      'detalles': ['Burpees', 'Plancha', 'Flexiones'],
    },
    {
      'titulo': 'Pecho Avanzado',
      'nivel': 'Avanzado',
      'etiqueta': 'PECHO',
      'descripcion': 'Rutina avanzada para pecho.',
      'imagen': 'assets/images/pecho.png',
      'detalles': ['Press banca', 'Fondos', 'Flexiones'],
    },
  ];

  // void _mostrarMenuNivel() async {
  //   final seleccion = await showMenu<String>(
  //     context: context,
  //     position: const RelativeRect.fromLTRB(1000, 120, 10, 0),
  //     items: [
  //       const PopupMenuItem(value: 'Todos', child: Text('Todos los niveles')),
  //       const PopupMenuItem(value: 'Principiante', child: Text('Principiante')),
  //       const PopupMenuItem(value: 'Intermedio', child: Text('Intermedio')),
  //       const PopupMenuItem(value: 'Avanzado', child: Text('Avanzado')),
  //     ],
  //   );
  //
  //   if (seleccion != null) {
  //     setState(() {
  //       nivelSeleccionado = seleccion;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas Generales'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: ejercicios.length,
        itemBuilder: (context, index) {
          final ejercicio = ejercicios[index];

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ejercicio['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          ejercicio['imagen'],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      BotonEnImagen(texto: ejercicio['etiqueta']),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(ejercicio['descripcion']),
                  const SizedBox(height: 10),
                  ExpansionTile(
                    title: const Text('Ver ejercicios', style: TextStyle(fontSize: 16)),
                    children: (ejercicio['detalles'] as List<String>).map((item) => ListTile(
                      leading: const Icon(Icons.fitness_center, color: Colors.green),
                      title: Text(item),
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemporizadorPage(
                            titulo: ejercicio['titulo'],
                            segundos: 300,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar rutina'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BarraNavegacion(indiceActual: 0),
    );
  }
}