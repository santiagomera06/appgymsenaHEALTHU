import 'package:flutter/material.dart';
import 'temporizador.dart';
import '../widgets/boton_en_imagen.dart';
import '../widgets/barra_navegacion.dart';

class RutinaAvanzada extends StatefulWidget {
  const RutinaAvanzada({super.key});

  @override
  State<RutinaAvanzada> createState() => _RutinaAvanzadaState();
}

class _RutinaAvanzadaState extends State<RutinaAvanzada> {
  String enfoqueSeleccionado = 'Todos';

  final List<Map<String, dynamic>> ejercicios = [
    {
      'titulo': 'Avanzada Full Body Power',
      'etiqueta': 'FULL BODY',
      'descripcion':
          'Sesión intensa para todo el cuerpo: cardio, fuerza y resistencia en un solo entrenamiento.',
      'imagen': 'assets/images/full.png',
      'detalles': [
        'Snatch con mancuernas',
        'Burpees con salto y push-up',
        'Thrusters con barra',
        'Box jumps',
        'Mountain climbers rápidos',
      ],
    },
    {
      'titulo': 'Avanzada Potencia Torso Superior',
      'etiqueta': 'PECHO',
      'descripcion': 'Explosividad y carga máxima para el tren superior.',
      'imagen': 'assets/images/pecho.png',
      'detalles': [
        'Press inclinado con barra',
        'Flexiones explosivas',
        'Press declinado pesado',
        'Dominadas con lastre',
        'Push-ups en anillas',
      ],
    },
    {
      'titulo': 'Avanzada Espalda y Core',
      'etiqueta': 'ESPALDA',
      'descripcion':
          'Fuerza isométrica y cargas pesadas para zona dorsal y lumbar.',
      'imagen': 'assets/images/espalda.png',
      'detalles': [
        'Peso muerto rumano',
        'Pull-ups estrictos',
        'Remo invertido',
        'Superman hold',
        'Kettlebell swings',
      ],
    },
    {
      'titulo': 'Avanzada Tren Inferior Explosivo',
      'etiqueta': 'PIERNA',
      'descripcion':
          'Enfoque en fuerza, equilibrio y movilidad del tren inferior.',
      'imagen': 'assets/images/pierna.png',
      'detalles': [
        'Sentadilla frontal con barra',
        'Zancadas explosivas',
        'Peso muerto a una pierna',
        'Saltos al cajón',
        'Pistol squats asistidas',
      ],
    },
    {
      'titulo': 'Avanzada Brazos de Acero',
      'etiqueta': 'BRAZO',
      'descripcion': 'Hipertrofia y volumen para bíceps, tríceps y antebrazo.',
      'imagen': 'assets/images/brazo.png',
      'detalles': [
        'Curl 21',
        'Fondos con peso',
        'Curl concentrado en banco',
        'Extensión de tríceps en polea alta',
        'Remo en cuerda para antebrazo',
      ],
    },
  ];

  void _mostrarMenuEnfoque() async {
    final seleccion = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 120, 10, 0),
      items: const [
        PopupMenuItem(value: 'Todos', child: Text('Mostrar todo')),
        PopupMenuItem(value: 'Full Body', child: Text('Full Body')),
        PopupMenuItem(value: 'Pierna', child: Text('Pierna')),
        PopupMenuItem(value: 'Brazo', child: Text('Brazo')),
        PopupMenuItem(value: 'Espalda', child: Text('Espalda')),
        PopupMenuItem(value: 'Pecho', child: Text('Pecho')),
      ],
    );

    if (seleccion != null) {
      setState(() {
        enfoqueSeleccionado = seleccion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ejerciciosFiltrados =
        enfoqueSeleccionado == 'Todos'
            ? ejercicios
            : ejercicios
                .where(
                  (e) =>
                      e['etiqueta'].toString().toLowerCase() ==
                      enfoqueSeleccionado.toLowerCase(),
                )
                .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas Avanzadas'),
        backgroundColor: Colors.redAccent,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 16),
            child: ElevatedButton.icon(
              onPressed: _mostrarMenuEnfoque,
              icon: const Icon(Icons.filter_list),
              label: Text(
                enfoqueSeleccionado == 'Todos'
                    ? 'Enfoque'
                    : enfoqueSeleccionado,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                        Text(
                          ejercicio['titulo'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
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
                            BotonEnImagen(
                              texto: ejercicio['etiqueta'] as String,
                              imagen: ejercicio['imagen'] as String,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => TemporizadorPage(
                                          titulo: ejercicio['titulo'] as String,
                                          segundos: 300,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(ejercicio['descripcion']),
                        ExpansionTile(
                          title: const Text(
                            'Ver ejercicios',
                            style: TextStyle(fontSize: 16),
                          ),
                          children:
                              (ejercicio['detalles'] as List<String>)
                                  .map(
                                    (item) => ListTile(
                                      leading: const Icon(
                                        Icons.fitness_center,
                                        color: Colors.redAccent,
                                      ),
                                      title: Text(item),
                                    ),
                                  )
                                  .toList(),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => TemporizadorPage(
                                      titulo: ejercicio['titulo'],
                                      segundos:
                                          600, // 🔴 Aumentado para rutina avanzada
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Iniciar rutina'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
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
          ),
        ],
      ),
      bottomNavigationBar: const BarraNavegacion(indiceActual: 0),
    );
  }
}
