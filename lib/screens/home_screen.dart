// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:healthu/models/usuario.dart';
import 'package:healthu/widgets/bottom_nav_bar.dart';

// Importa tus pantallas con package:
import 'package:healthu/screens/desafios_screen.dart';
import 'package:healthu/screens/clasificacion_screen.dart';
import 'package:healthu/screens/dashboard_screen.dart'; // lo usas como "Perfil"

class HomeScreen extends StatefulWidget {
  final Usuario usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Asegúrate de tener tantas pantallas aquí como ítems en tu BottomNavBar:
  late final List<Widget> _screens = [
    const DesafiosScreen(),           // índice 0
    const ClasificacionScreen(),      // índice 1 (vacío por ahora)
    DashboardScreen(usuario: widget.usuario), // índice 2 = Perfil
  ];

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantiene el estado de cada pestaña:
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: HealthuBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
