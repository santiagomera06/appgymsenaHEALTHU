import 'package:flutter/material.dart';

class BarraNavegacion extends StatelessWidget {
  final int indiceActual;

  const BarraNavegacion({super.key, required this.indiceActual});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceActual,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Rutinas'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Progreso'),
      ],
      onTap: (index) {
        // Aquí puedes agregar navegación si lo necesitas
      },
    );
  }
}
