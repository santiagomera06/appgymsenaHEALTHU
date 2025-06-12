import 'package:flutter/material.dart';

class DetalleRutina extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String imagen;
  final List<String> ejercicios;
  final String nivel;
  final List<String> musculos;
  final String imagenMusculos;

  const DetalleRutina({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.ejercicios,
    required this.nivel,
    required this.musculos,
    required this.imagenMusculos,
  });

  Icon _iconoMusculo(String musculo) {
    switch (musculo.toLowerCase()) {
      case 'piernas':
        return const Icon(Icons.directions_walk, color: Colors.green);
      case 'brazos':
        return const Icon(Icons.fitness_center, color: Colors.green);
      case 'espalda':
      case 'core':
      case 'espalda y core':
        return const Icon(Icons.accessibility_new, color: Colors.green);
      case 'abdomen':
        return const Icon(Icons.sports_mma, color: Colors.green);
      case 'pecho':
        return const Icon(Icons.self_improvement, color: Colors.green);
      case 'hombros':
        return const Icon(Icons.accessibility, color: Colors.green);
      default:
        return const Icon(Icons.adjust, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(titulo),
          backgroundColor: Colors.green,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Descripción'),
              Tab(text: 'Ejercicios'),
              Tab(text: 'Músculos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // DESCRIPCIÓN
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagen,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          nivel,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    descripcion,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // EJERCICIOS
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ejercicios.length,
              itemBuilder: (context, index) {
                final ejercicio = ejercicios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center, color: Colors.green),
                    title: Text(ejercicio),
                    trailing: const Text('+10 pts', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),

            // MÚSCULOS
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Músculos trabajados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagenMusculos,
                      height: 240,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...musculos.map((m) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: _iconoMusculo(m),
                      title: Text(
                        m,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),

        // BOTÓN FIJO
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.play_circle),
            label: const Text('Iniciar rutina'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
      ),
    );
  }
}
