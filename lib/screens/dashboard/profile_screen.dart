import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:healthu/models/usuario.dart';
import 'package:healthu/screens/dashboard/ficha_identificacion.dart';
import 'package:healthu/screens/dashboard/tarjetas_dashboard.dart';
import 'package:healthu/screens/graficas/graficas_dashboard.dart';
import 'package:healthu/screens/graficas/grafica_anillo.dart';

import 'package:healthu/services/desafio_service.dart';

class ProfileScreen extends StatefulWidget {
  final Usuario usuario;
  const ProfileScreen({super.key, required this.usuario});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<CardDataModel>> _tarjetasFuture;

  @override
  void initState() {
    super.initState();
    _tarjetasFuture = _cargarTarjetas();
  }

  Future<List<CardDataModel>> _cargarTarjetas() async {
    final totales = await DesafioService.obtenerTotalesUsuario();
    final lista = await DesafioService.obtenerDesafiosPorUsuario();

    // ✅ 1. Puntos totales
    final puntosTotales = totales['puntos'] ?? 0;

    // ✅ 2. Desafíos completados
    final completados = lista
        .where((d) => (d['estado'] ?? '').toString().toLowerCase() == 'finalizado')
        .length;

    // ✅ 3. Promedio diario (solo del día actual)
    final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final hoyCount = lista.where((d) {
      final fecha = d['fechaFinDesafio'] ?? d['fechaInicioDesafio'];
      if (fecha == null) return false;
      final fechaNormalizada = fecha.toString().substring(0, 10);
      return fechaNormalizada == hoy;
    }).length;

    // ✅ 4. Nivel actual (del usuario autenticado)
    final nivel = widget.usuario.nivelActual;

    return [
      CardDataModel(title: 'Puntos totales', value: '$puntosTotales', icon: Icons.star),
      CardDataModel(title: 'Desafíos completados', value: '$completados', icon: Icons.fitness_center),
      CardDataModel(title: 'Promedio diario', value: '$hoyCount', icon: Icons.bar_chart),
      CardDataModel(title: 'Nivel actual', value: nivel, icon: Icons.trending_up),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final fechaHoy = DateFormat('EEEE d MMMM', 'es').format(DateTime.now());
    final hora = DateTime.now().hour;
    final saludo = hora < 12
        ? '¡Buenos días!'
        : hora < 18
            ? '¡Buenas tardes!'
            : '¡Buenas noches!';

    final datosSemana = <double>[2, 3, 1, 4, 5, 2, 0];

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FichaIdentificacion(usuario: widget.usuario),
          const SizedBox(height: 12),
          Center(
            child: Text("Bienvenido, ${widget.usuario.nombre.split(' ')[0]}",
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

          // ✅ Tarjetas de estadísticas dinámicas
          FutureBuilder<List<CardDataModel>>(
            future: _tarjetasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }
              if (!snapshot.hasData) {
                return const Text("No hay datos disponibles");
              }
              return TarjetasDashboard(items: snapshot.data!);
            },
          ),

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

          const GraficaDesafios(),
        ],
      ),
    );
  }
}
