import 'package:flutter/material.dart';

class BarraNavegacion extends StatelessWidget {
  final int indiceActual;

  const BarraNavegacion({super.key, required this.indiceActual});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceActual,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/desafios');
            break;
          case 1:
            Navigator.pushNamed(context, '/clasificacion');
            break;
          case 2:
            Navigator.pushNamed(context, '/perfil');
            break;
        }
      },
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      backgroundColor: Colors.green[800],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Desafíos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Clasificación',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
