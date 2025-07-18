import 'package:flutter/material.dart';
import 'package:healthu/screens/rutinas/detalle_rutina.dart';
import 'package:healthu/widgets/boton_en_imagen.dart';
import 'package:healthu/widgets/barra_navegacion.dart';
import 'package:healthu/models/rutina_model.dart';

class RutinasGenerales extends StatefulWidget {
  const RutinasGenerales({super.key});

  @override
  State<RutinasGenerales> createState() => _RutinasGeneralesState();
}

class _RutinasGeneralesState extends State<RutinasGenerales> {
  String nivelSeleccionado = 'Todos';

  final List<Map<String, dynamic>> _ejerciciosBase = [
    {
      'titulo': 'Full Body Básico',
      'nivel': 'Principiante',
      'etiqueta': 'FULLBODY',
      'descripcion': 'Rutina básica para activar todo el cuerpo con ejercicios fundamentales.',
      'imagen': 'assets/images/full.png',
      'detalles': ['Sentadillas', 'Flexiones pared', 'Jumping jacks'],
      'duracion': '10 min',
      'enfoque': 'Full Body',
      'dificultad': 'Baja',
    },
    {
      'titulo': 'Full Body Intermedio',
      'nivel': 'Intermedio',
      'etiqueta': 'FULLBODY',
      'descripcion': 'Rutina intermedia para mejorar resistencia y fuerza general.',
      'imagen': 'assets/images/full.png',
      'detalles': ['Burpees', 'Plancha', 'Flexiones'],
      'duracion': '15 min',
      'enfoque': 'Full Body',
      'dificultad': 'Media',
    },
    {
      'titulo': 'Pecho Avanzado',
      'nivel': 'Avanzado',
      'etiqueta': 'PECHO',
      'descripcion': 'Rutina avanzada para desarrollo muscular del pecho.',
      'imagen': 'assets/images/pecho.png',
      'detalles': ['Press banca', 'Fondos', 'Flexiones'],
      'duracion': '20 min',
      'enfoque': 'Tren Superior',
      'dificultad': 'Alta',
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

  int _generarIdDesdeTexto(String texto) {
    return texto.hashCode & 0x7FFFFFFF;
  }

  RutinaDetalle _crearRutinaDetalle(Map<String, dynamic> ejercicio, int index) {
    return RutinaDetalle(
      id: _generarIdDesdeTexto('${ejercicio['titulo']}_$index'),
      nombre: ejercicio['titulo'] ?? 'Rutina sin nombre',
      descripcion: ejercicio['descripcion'] ?? 'Descripción no disponible',
      imagenUrl: ejercicio['imagen'] ?? '',
      nivel: ejercicio['nivel'] ?? 'General',
      ejercicios: [
        for (var detalle in ejercicio['detalles'] as List<String>)
          EjercicioRutina(
            id: _generarIdDesdeTexto('${detalle}_${ejercicio['titulo']}'),
            nombre: detalle,
            series: 3,
            repeticiones: 12,
            pesoRecomendado: _obtenerPesoRecomendado(detalle, ejercicio['nivel']),
            descripcion: _obtenerDescripcionEjercicio(detalle),
            imagenUrl: _obtenerImagenEjercicio(detalle),
            duracionEstimada: 60,
          ),
      ],
    );
  }

  double _obtenerPesoRecomendado(String ejercicio, String nivel) {
    if (nivel == 'Principiante') return 5.0;
    if (nivel == 'Intermedio') return 10.0;
    return 20.0;
  }

  String _obtenerDescripcionEjercicio(String ejercicio) {
    switch (ejercicio.toLowerCase()) {
      case 'sentadillas':
        return 'Flexiona las rodillas bajando el cuerpo manteniendo la espalda recta';
      case 'flexiones':
        return 'Baja el cuerpo doblando los codos y luego empuja hacia arriba';
      case 'burpees':
        return 'Combinación de sentadilla, flexión y salto vertical';
      default:
        return 'Ejercicio para mejorar fuerza y resistencia';
    }
  }

  String _obtenerImagenEjercicio(String ejercicio) {
    switch (ejercicio.toLowerCase()) {
      case 'sentadillas':
        return 'https://example.com/sentadillas.jpg';
      case 'flexiones':
        return 'https://example.com/flexiones.jpg';
      case 'burpees':
        return 'https://example.com/burpees.jpg';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ejerciciosFiltrados = nivelSeleccionado == 'Todos'
        ? _ejerciciosBase
        : _ejerciciosBase.where((e) => e['nivel'] == nivelSeleccionado).toList();

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
          final rutinaDetalle = _crearRutinaDetalle(ejercicio, index);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalleRutinaScreen(rutina: rutinaDetalle),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ejercicio['titulo'] ?? 'Sin título',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Chip(
                          backgroundColor: _obtenerColorNivel(ejercicio['nivel'] as String?),
                          label: Text(
                            ejercicio['nivel'] ?? 'Sin nivel',
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
                        Text(ejercicio['duracion'] ?? 'Duración no especificada'),
                        const SizedBox(width: 16),
                        const Icon(Icons.fitness_center, size: 16),
                        const SizedBox(width: 4),
                        Text(ejercicio['enfoque'] ?? 'Enfoque no especificado'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            ejercicio['imagen'] ?? 'assets/images/default.png',
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 160,
                              color: Colors.grey[200],
                              child: const Icon(Icons.fitness_center, size: 50),
                            ),
                          ),
                        ),
                        BotonEnImagen(texto: ejercicio['etiqueta'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(ejercicio['descripcion'] ?? 'Sin descripción'),
                    const SizedBox(height: 10),
                    ExpansionTile(
                      title: const Text(
                        'Ver ejercicios',
                        style: TextStyle(fontSize: 16),
                      ),
                      children: ((ejercicio['detalles'] as List<String>?) ?? [])
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
                            builder: (context) => DetalleRutinaScreen(rutina: rutinaDetalle),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Ver detalles'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BarraNavegacion(indiceActual: 0),
    );
  }
}
