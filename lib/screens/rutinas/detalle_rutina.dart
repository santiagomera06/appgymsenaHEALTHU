import 'package:flutter/material.dart';
import 'package:healthu/models/rutina_model.dart';
import 'package:healthu/screens/rutinas/ejercicio_actual_screen.dart';
class DetalleRutinaScreen extends StatelessWidget {
  final RutinaDetalle rutina;

  const DetalleRutinaScreen({super.key, required this.rutina});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(rutina.nombre),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                rutina.imagenUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fitness_center, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nivel de dificultad
            Chip(
              label: Text(
                rutina.nivel,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
            ),
            const SizedBox(height: 16),

            // Descripción
            Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              rutina.descripcion,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Lista de ejercicios
            Text(
              'Ejercicios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            ...rutina.ejercicios.map((ejercicio) => _buildEjercicioCard(ejercicio)).toList(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EjercicioActualScreen(
                  rutina: rutina,
                  ejercicioIndex: 0,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Iniciar Rutina',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildEjercicioCard(EjercicioRutina ejercicio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Imagen del ejercicio
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: ejercicio.imagenUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(ejercicio.imagenUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[200],
                  ),
                  child: ejercicio.imagenUrl.isEmpty
                      ? const Icon(Icons.fitness_center, size: 40)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ejercicio.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${ejercicio.series} series x ${ejercicio.repeticiones} repeticiones',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (ejercicio.pesoRecomendado != null)
                        Text(
                          'Peso sugerido: ${ejercicio.pesoRecomendado} kg',
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (ejercicio.descripcion.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                ejercicio.descripcion,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}