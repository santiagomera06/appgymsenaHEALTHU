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
      onTap: (index) {
        // Aquí puedes manejar navegación entre pantallas si lo necesitas
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Rutinas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timer),
          label: 'Temporizador',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
