import 'package:flutter/material.dart';

/// Barra de navegación inferior común a toda la app,
/// con tres pestañas: Desafíos, Clasificación y Perfil.
class HealthuBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HealthuBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.green[800],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Desafíos'),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Clasificación',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
