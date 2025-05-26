// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:healthu/models/usuario.dart';

import '../widgets/selector_dispersion.dart';
import '../widgets/graficas_extra.dart';
import 'ficha_identificacion.dart';
import 'tarjetas_dashboard.dart';
import 'graficas_dashboard.dart';
import 'grafica_anillo.dart';
import 'editar_usuario_screen.dart';   // ← NUEVO

// 1️⃣  Ahora es StatefulWidget
class DashboardScreen extends StatefulWidget {
  final Usuario usuario;
  const DashboardScreen({super.key, required this.usuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Usuario usuario;

  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;     // copia inicial para poder mutar
  }

  @override
  Widget build(BuildContext context) {
    // ─── Fecha y saludo ───
    final fechaHoy = DateFormat('EEEE d MMMM', 'es').format(DateTime.now());
    final hora = DateTime.now().hour;
    final saludo = (hora < 12)
        ? '¡Buenos días!'
        : (hora < 18)
            ? '¡Buenas tardes!'
            : '¡Buenas noches!';

    // ─── Datos demo ───
    final datosSemana = <double>[2, 3, 1, 4, 5, 2, 0];

    final actividades = <PieSectionDataModel>[
      PieSectionDataModel(
          value: 35,
          color: Colors.green,
          label: 'Cardio',
          textColor: Colors.white),
      PieSectionDataModel(
          value: 35,
          color: Colors.lightGreen,
          label: 'Fuerza',
          textColor: Colors.black),
      PieSectionDataModel(
          value: 30,
          color: Colors.grey.shade300,
          label: 'Descanso',
          textColor: Colors.black),
    ];

    final tarjetas = <CardDataModel>[
      CardDataModel(
          title: 'Puntos totales', value: '1 200', icon: Icons.star),
      CardDataModel(
          title: 'Desafíos completados',
          value: '45',
          icon: Icons.fitness_center),
      CardDataModel(
          title: 'Promedio diario', value: '3', icon: Icons.bar_chart),
      CardDataModel(
          title: 'Nivel actual',
          value: 'Avanzado',
          icon: Icons.trending_up),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard del Aprendiz'),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      // 2️⃣  Menú desplegable con “Actualizar datos”
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                      backgroundImage: NetworkImage(usuario.fotoUrl),
                      radius: 30),
                  const SizedBox(height: 10),
                  Text(usuario.nombre,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(usuario.email,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
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
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Actualizar datos'),
              onTap: () async {
                Navigator.pop(context); // cierra drawer
                final actualizado =
                    await Navigator.push<Usuario>(context,
                        MaterialPageRoute(
                            builder: (_) =>
                                EditarUsuarioScreen(usuario: usuario)));
                if (actualizado != null) {
                  setState(() => usuario = actualizado);
                }
              },
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

      // ─── Cuerpo ───
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Tarjeta de identificación
            FichaIdentificacion(usuario: usuario),
            const SizedBox(height: 12),

            // Bienvenida
            Center(
              child: Text('Bienvenido, ${usuario.nombre.split(' ')[0]}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            Center(
                child: Text(fechaHoy,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.grey))),
            const SizedBox(height: 8),
            Center(
                child: Text(saludo,
                    style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.green))),
            const SizedBox(height: 24),

            // Tarjetas resumen
            TarjetasDashboard(items: tarjetas),
            const SizedBox(height: 32),

            // Progreso de nivel
            const TextoSeccion('Progreso de Nivel'),
            const BarraProgreso(),
            const SizedBox(height: 32),

            // Progreso semanal
            const TextoSeccion('Progreso semanal de desafíos'),
            const SizedBox(height: 16),
            GraficaBarras(valores: datosSemana),
            const SizedBox(height: 32),
            GraficaCircular(sections: actividades),

            // Calorías por actividad
            const SizedBox(height: 32),
            const TextoSeccion('Calorías por actividad (semana)'),
            const SizedBox(height: 16),
            const GraficaBarrasApiladas(),

            // Comparar variables
            const SizedBox(height: 32),
            const TextoSeccion('Comparar variables'),
            const SelectorDispersion(),
          ],
        ),
      ),
    );
  }
}
