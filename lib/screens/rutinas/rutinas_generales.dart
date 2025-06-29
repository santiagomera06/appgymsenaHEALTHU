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
      'etiqueta': 'FULLBODY',
      'descripcion': 'Rutina básica para activar todo el cuerpo.',
      'imagen': 'assets/images/full.png',
      'detalles': ['Sentadillas', 'Flexiones pared', 'Jumping jacks'],
      'duracion': '10 min',
    },
    {
      'titulo': 'Full Body Intermedio',
      'nivel': 'Intermedio',
      'etiqueta': 'FULLBODY',
      'descripcion': 'Rutina intermedia para resistencia y fuerza.',
      'imagen': 'assets/images/full.png',
      'detalles': ['Burpees', 'Plancha', 'Flexiones'],
      'duracion': '15 min',
    },
    {
      'titulo': 'Pecho Avanzado',
      'nivel': 'Avanzado',
      'etiqueta': 'PECHO',
      'descripcion': 'Rutina avanzada para pecho.',
      'imagen': 'assets/images/pecho.png',
      'detalles': ['Press banca', 'Fondos', 'Flexiones'],
      'duracion': '20 min',
    },
  ];

  void _mostrarMenuNivel() async {
    final seleccion = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 120, 10, 0),
      items: [
        const PopupMenuItem(value: 'Todos', child: Text('Todos los niveles')),
        const PopupMenuItem(value: 'Principiante', child: Text('Principiante')),
        const PopupMenuItem(value: 'Intermedio', child: Text('Intermedio')),
        const PopupMenuItem(value: 'Avanzado', child: Text('Avanzado')),
      ],
    );

    if (seleccion != null) {
      setState(() {
        nivelSeleccionado = seleccion;
      });
    }
  }

  Color _obtenerColorNivel(String? nivel) {
    switch (nivel) {
      case 'Principiante':
        return Colors.green;
      case 'Intermedio':
        return Colors.orange;
      case 'Avanzado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar ejercicios según nivel seleccionado
    final ejerciciosFiltrados = nivelSeleccionado == 'Todos'
        ? ejercicios
        : ejercicios.where((e) => e['nivel'] == nivelSeleccionado).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas Generales'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarMenuNivel,
            tooltip: 'Filtrar por nivel',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: ejerciciosFiltrados.length,
        itemBuilder: (context, index) {
          final ejercicio = ejerciciosFiltrados[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ejercicio['titulo'] ?? 'Sin título', // Comprobación de nulidad
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Chip(
                        backgroundColor: _obtenerColorNivel(ejercicio['nivel'] as String?),
                        label: Text(
                          (ejercicio['nivel'] as String?) ?? 'Sin nivel', // Comprobación de nulidad
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16),
                      const SizedBox(width: 4),
                      Text(ejercicio['duracion'] ?? 'Duración no especificada'), // Comprobación de nulidad
                    ],
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          ejercicio['imagen'] ?? 'assets/images/default.png', // Comprobación de nulidad
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      BotonEnImagen(texto: ejercicio['etiqueta'] ?? ''), // Comprobación de nulidad
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(ejercicio['descripcion'] ?? 'Sin descripción'), // Comprobación de nulidad
                  const SizedBox(height: 10),
                  ExpansionTile(
                    title: const Text(
                      'Ver ejercicios',
                      style: TextStyle(fontSize: 16),
                    ),
                    children: ((ejercicio['detalles'] as List<String>?) ?? []) // Comprobación de nulidad
                        .map((item) => ListTile(
                      leading: const Icon(Icons.fitness_center, color: Colors.green),
                      title: Text(item),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemporizadorPage(
                            titulo: ejercicio['titulo'] ?? 'Rutina', // Comprobación de nulidad
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
                      minimumSize: const Size(double.infinity, 48),
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