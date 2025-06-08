import 'package:flutter/material.dart';
import 'ejercicios_principiante_screen.dart';

class EnfoqueScreen extends StatelessWidget {
  final String nivel;

  const EnfoqueScreen({super.key, required this.nivel});

  final List<String> enfoques = const [
    'Cuerpo completo',
    'Tren superior',
    'Tren inferior'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enfoque - $nivel')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enfoques.length,
        itemBuilder: (context, index) {
          final enfoque = enfoques[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(enfoque),
              trailing: const Icon(Icons.fitness_center),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EjerciciosPrincipianteScreen(
                      nivel: nivel,
                      enfoque: enfoque,
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
}
