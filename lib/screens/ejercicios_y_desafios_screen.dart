import 'package:flutter/material.dart';
import 'package:healthu/routes/ejercicio_routes.dart';

class EjerciciosYDesafiosScreen extends StatelessWidget {
  const EjerciciosYDesafiosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios y Desafíos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.fitness_center),
              label: const Text('Ejercicios'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  EjercicioRoutes.seleccionarNivel,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
