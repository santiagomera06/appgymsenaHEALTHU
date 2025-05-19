// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:healthu/models/usuario.dart';

import 'ficha_identificacion.dart';
import 'tarjetas_dashboard.dart';
import 'graficas_dashboard.dart';
import 'grafica_anillo.dart';

class DashboardScreen extends StatelessWidget {
  final Usuario usuario;

  const DashboardScreen({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    // Fecha y saludo
    final fechaHoy = DateFormat('EEEE d MMMM', 'es').format(DateTime.now());
    final hora = DateTime.now().hour;
    String saludo;
    if (hora < 12) {
      saludo = '¡Buenos días!';
    } else if (hora < 18) {
      saludo = '¡Buenas tardes!';
    } else {
      saludo = '¡Buenas noches!';
    }

    // Datos para la gráfica de barras
    final datosSemana = <double>[2.0, 3.0, 1.0, 4.0, 5.0, 2.0, 0.0];

    // Datos para la gráfica circular
    final actividades = <PieSectionDataModel>[
      PieSectionDataModel(value: 35, color: Colors.green,      label: "Cardio",  textColor: Colors.white),
      PieSectionDataModel(value: 35, color: Colors.lightGreen, label: "Fuerza",  textColor: Colors.black),
      PieSectionDataModel(value: 30, color: Colors.grey.shade300, label: "Descanso", textColor: Colors.black),
    ];

    // Datos para las tarjetas
    final tarjetas = <CardDataModel>[
      CardDataModel(title: "Puntos totales",       value: "1,200",    icon: Icons.star),
      CardDataModel(title: "Desafíos completados", value: "45",       icon: Icons.fitness_center),
      CardDataModel(title: "Promedio diario",      value: "3",        icon: Icons.bar_chart),
      CardDataModel(title: "Nivel actual",         value: "Avanzado", icon: Icons.trending_up),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard del Aprendiz'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/perfil.png'),
                    radius: 30,
                  ),
                  SizedBox(height: 10),
                  Text('Aprendiz SENA', style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text('aprendiz@sena.edu.co', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(usuario.fotoUrl),
                    radius: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(usuario.nombre, style: const TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(usuario.email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FichaIdentificacion(usuario: usuario),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "Bienvenido, ${usuario.nombre.split(' ')[0]}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            Center(
              child: Text(fechaHoy, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                saludo,
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.green),
              ),
            ),
            const SizedBox(height: 24),
            TarjetasDashboard(items: tarjetas),
            const SizedBox(height: 32),
            const TextoSeccion("Progreso de Nivel"),
            const BarraProgreso(),
            const SizedBox(height: 32),
            const TextoSeccion("Progreso semanal de desafíos"),
            const SizedBox(height: 16),
            GraficaBarras(valores: datosSemana),
            const SizedBox(height: 32),
            GraficaCircular(sections: actividades),
          ],
        ),
      ),
    );
  }
}
