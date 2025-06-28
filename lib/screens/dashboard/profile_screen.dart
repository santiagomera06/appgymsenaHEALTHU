import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:healthu/models/usuario.dart';
import 'package:healthu/screens/dashboard/ficha_identificacion.dart';
import 'package:healthu/screens/dashboard/tarjetas_dashboard.dart';
import 'package:healthu/screens/graficas/graficas_dashboard.dart';
import 'package:healthu/screens/graficas/grafica_anillo.dart';

class ProfileScreen extends StatelessWidget {
  final Usuario usuario;
  const ProfileScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    // Fecha y saludo
    final fechaHoy = DateFormat('EEEE d MMMM', 'es').format(DateTime.now());
    final hora = DateTime.now().hour;
    final saludo = hora < 12
        ? '¡Buenos días!'
        : hora < 18
            ? '¡Buenas tardes!'
            : '¡Buenas noches!';

    // Datos de ejemplo
    final datosSemana = <double>[2, 3, 1, 4, 5, 2, 0];
    final secciones = <PieSectionDataModel>[
      PieSectionDataModel(value: 35, color: Colors.green,      label: "Cardio",   textColor: Colors.white),
      PieSectionDataModel(value: 35, color: Colors.lightGreen, label: "Fuerza",   textColor: Colors.black),
      PieSectionDataModel(value: 30, color: Colors.grey.shade300, label: "Descanso", textColor: Colors.black),
    ];
    final tarjetas = <CardDataModel>[
      CardDataModel(title: "Puntos totales",       value: "1,200",    icon: Icons.star),
      CardDataModel(title: "Desafíos completados", value: "45",       icon: Icons.fitness_center),
      CardDataModel(title: "Promedio diario",      value: "3",        icon: Icons.bar_chart),
      CardDataModel(title: "Nivel actual",         value: "Avanzado", icon: Icons.trending_up),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FichaIdentificacion(usuario: usuario),
          const SizedBox(height: 12),
          Center(
            child: Text("Bienvenido, ${usuario.nombre.split(' ')[0]}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          Center(
            child: Text(fechaHoy,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(saludo,
                style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.green)),
          ),
          const SizedBox(height: 24),

          // Tarjetas de estadísticas
          TarjetasDashboard(items: tarjetas),
          const SizedBox(height: 32),

          // Progreso de nivel
          const TextoSeccion("Progreso de Nivel"),
          const BarraProgreso(),
          const SizedBox(height: 32),

          // Progreso semanal
          const TextoSeccion("Progreso semanal de desafíos"),
          const SizedBox(height: 16),
          GraficaBarras(valores: datosSemana),
          const SizedBox(height: 32),

          // Gráfica de anillo
          GraficaCircular(sections: secciones),
        ],
      ),
    );
  }
}
