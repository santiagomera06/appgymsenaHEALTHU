import 'package:flutter/material.dart';
import 'package:healthu/models/usuario.dart';
import 'package:healthu/screens/desafios_screen.dart';
import 'package:healthu/screens/clasificacion_screen.dart';
import 'package:healthu/screens/dashboard_screen.dart';
import 'package:healthu/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;
  final int indiceInicial;                           

  const HomeScreen({
    super.key,                                      
    required this.usuario,
    this.indiceInicial = 0,                         
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex = widget.indiceInicial;   

  late final List<Widget> _screens = [
    const DesafiosScreen(),
    const ClasificacionScreen(),
    DashboardScreen(usuario: widget.usuario),
  ];

  void _onTap(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: HealthuBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
