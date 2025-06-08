import 'package:flutter/material.dart';
import 'enfoque_screen.dart';

class NivelesScreen extends StatelessWidget {
  const NivelesScreen({super.key});

  final List<String> niveles = const ['Principiante', 'Intermedio', 'Avanzado'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona un nivel')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: niveles.length,
        itemBuilder: (context, index) {
          final nivel = niveles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(nivel),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnfoqueScreen(nivel: nivel),
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
