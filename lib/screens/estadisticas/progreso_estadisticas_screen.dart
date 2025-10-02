import 'package:flutter/material.dart';
import 'package:healthu/services/desafio_service.dart';

class ProgresoEstadisticasScreen extends StatefulWidget {
  const ProgresoEstadisticasScreen({super.key});

  @override
  State<ProgresoEstadisticasScreen> createState() =>
      _ProgresoEstadisticasScreenState();
}

class _ProgresoEstadisticasScreenState extends State<ProgresoEstadisticasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _estadisticas;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarEstadisticas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarEstadisticas() async {
    try {
      setState(() {
        _cargando = true;
        _error = null;
      });

      // 🔹 Obtener lista de desafíos (rutinas realizadas)
      final listaDesafios = await DesafioService.obtenerDesafiosPorUsuario();

      // 🔹 Filtrar solo finalizados
      final rutinasCompletadas = listaDesafios
          .where((d) =>
              (d['estado'] ?? '').toString().toLowerCase() == 'finalizado')
          .toList();

      // 📅 Semana actual (lunes a domingo)
      DateTime now = DateTime.now();
      DateTime lunes = now.subtract(Duration(days: now.weekday - 1));
      DateTime domingo = lunes.add(const Duration(days: 6));

      // 🔹 Filtrar rutinas solo dentro de la semana actual
      final rutinasSemana = rutinasCompletadas.where((r) {
        final fechaRaw = r['fechaFinDesafio'];
        if (fechaRaw == null) return false;
        final fecha = DateTime.tryParse(fechaRaw);
        if (fecha == null) return false;
        return fecha.isAfter(lunes.subtract(const Duration(days: 1))) &&
            fecha.isBefore(domingo.add(const Duration(days: 1)));
      }).toList();

      final totalRutinas = rutinasSemana.length;

      // 🔹 Agrupar por día de la semana (L-D)
      final Map<int, int> conteoPorDia = {
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
        7: 0,
      };

      for (var rutina in rutinasSemana) {
        final fechaRaw = rutina['fechaFinDesafio'];
        if (fechaRaw != null) {
          final fecha = DateTime.tryParse(fechaRaw);
          if (fecha != null) {
            conteoPorDia[fecha.weekday] =
                (conteoPorDia[fecha.weekday] ?? 0) + 1;
          }
        }
      }

      // Pasar los datos a la vista
      final semanaActual = [
        conteoPorDia[1] ?? 0,
        conteoPorDia[2] ?? 0,
        conteoPorDia[3] ?? 0,
        conteoPorDia[4] ?? 0,
        conteoPorDia[5] ?? 0,
        conteoPorDia[6] ?? 0,
        conteoPorDia[7] ?? 0,
      ];

      // 🔹 Totales del usuario
      final totales = await DesafioService.obtenerTotalesUsuario();

      final estadisticas = {
        'rutinasCompletadas': totalRutinas,
        'semanaActual': semanaActual,
        'diasSemana': List.generate(7, (i) {
          final fecha = lunes.add(Duration(days: i));
          final nombres = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
          return "${nombres[i]}\n${fecha.day}";
        }),
        'desafiosEnProgreso': listaDesafios
            .where((d) =>
                (d['estado'] ?? '').toString().toLowerCase() == 'en progreso')
            .length,
        'desafiosCompletados': rutinasCompletadas.length,
        'puntosTotal': (totales['puntos'] ?? 0).toInt(),
      };

      setState(() {
        _estadisticas = estadisticas;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar estadísticas: ${e.toString()}';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso y Estadísticas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarEstadisticas,
            tooltip: 'Actualizar estadísticas',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.show_chart), text: 'Gráficas'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Logros'),
          ],
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildResumenTab(),
                    _buildGraficasTab(),
                    _buildLogrosTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargarEstadisticas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenTab() {
    final stats = _estadisticas!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Resumen General',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                'Rutinas Completadas',
                '${stats['rutinasCompletadas']}',
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                'Desafíos en Progreso',
                '${stats['desafiosEnProgreso']}',
                Icons.play_circle_filled,
                Colors.orange,
              ),
              _buildStatCard(
                'Desafíos Completados',
                '${stats['desafiosCompletados']}',
                Icons.emoji_events,
                Colors.amber,
              ),
              _buildStatCard(
                'Puntos Totales',
                '${stats['puntosTotal']}',
                Icons.stars,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraficasTab() {
    final stats = _estadisticas!;
    final semanaActual =
        List<int>.from(stats['semanaActual'].map((x) => x.toInt()));
    final diasSemana = List<String>.from(stats['diasSemana']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Progreso Semanal',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Rutinas por día (semana actual)'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: _buildSimpleBarChart(
                      semanaActual.map((e) => e.toDouble()).toList(),
                      diasSemana,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogrosTab() {
    return const Center(
      child: Text("🏆 Próximamente logros dinámicos"),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart(List<double> data, List<String> diasLabels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (index) {
        final height = (data[index] * 30) + 20;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('${data[index].toInt()}'),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(diasLabels[index], textAlign: TextAlign.center),
          ],
        );
      }),
    );
  }
}
