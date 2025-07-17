import 'package:flutter/material.dart';

/// 🏆 Pantalla para ver estadísticas detalladas de rutinas completadas
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

      // Simular carga de estadísticas (reemplazar con llamada real al backend)
      await Future.delayed(const Duration(seconds: 1));

      // Datos simulados - reemplazar con datos reales del backend
      final estadisticas = {
        'rutinasCompletadas': 15,
        'rutinasEnProgreso': 3,
        'desafiosCompletados': 5,
        'puntosTotal': 1250,
        'diasActivo': 28,
        'rachaActual': 7,
        'promedioSemanal': 4.2,
        'tiempoTotal': 420, // minutos
        'semanaPasada': [1, 3, 2, 4, 2, 1, 3],
        'mesActual': [
          {'semana': 1, 'rutinas': 5},
          {'semana': 2, 'rutinas': 8},
          {'semana': 3, 'rutinas': 6},
          {'semana': 4, 'rutinas': 12},
        ],
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
      body:
          _cargando
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

          // Grid de estadísticas principales
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
                'En Progreso',
                '${stats['rutinasEnProgreso']}',
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

          const SizedBox(height: 24),

          // Información adicional
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔥 Racha y Consistencia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildProgressRow(
                    'Racha actual',
                    '${stats['rachaActual']} días',
                    Colors.orange,
                  ),
                  _buildProgressRow(
                    'Días activo este mes',
                    '${stats['diasActivo']} días',
                    Colors.blue,
                  ),
                  _buildProgressRow(
                    'Promedio semanal',
                    '${stats['promedioSemanal']} rutinas',
                    Colors.green,
                  ),
                  _buildProgressRow(
                    'Tiempo total',
                    '${(stats['tiempoTotal'] / 60).toStringAsFixed(1)} horas',
                    Colors.indigo,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficasTab() {
    final stats = _estadisticas!;
    final semanaPasada = List<double>.from(
      stats['semanaPasada'].map((x) => x.toDouble()),
    );

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
                  const Text('Rutinas por día (última semana)'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildSimpleBarChart(semanaPasada),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '📅 Progreso Mensual',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Rutinas por semana (este mes)'),
                  const SizedBox(height: 16),
                  ...List.generate(4, (index) {
                    final semana = stats['mesActual'][index];
                    final progreso = (semana['rutinas'] / 15.0).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Semana ${semana['semana']}'),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progreso,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progreso > 0.8
                                  ? Colors.green
                                  : progreso > 0.5
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${semana['rutinas']} rutinas completadas',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogrosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Logros Desbloqueados',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildLogroCard(
            'Primera Rutina',
            'Completaste tu primera rutina',
            Icons.baby_changing_station,
            Colors.green,
            true,
          ),
          _buildLogroCard(
            'Racha de 7 días',
            'Mantuviste una racha de 7 días consecutivos',
            Icons.local_fire_department,
            Colors.orange,
            true,
          ),
          _buildLogroCard(
            'Madrugador',
            'Completaste 5 rutinas antes de las 8 AM',
            Icons.wb_sunny,
            Colors.amber,
            true,
          ),
          _buildLogroCard(
            '100 Rutinas',
            'Alcanza 100 rutinas completadas',
            Icons.emoji_events,
            Colors.purple,
            false,
          ),
          _buildLogroCard(
            'Racha de 30 días',
            'Mantén una racha de 30 días consecutivos',
            Icons.whatshot,
            Colors.red,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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

  Widget _buildProgressRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(List<double> data) {
    final dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (index) {
        final height =
            (data[index] * 30) + 20; // Min height 20, max height based on data
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
            Text(dias[index]),
          ],
        );
      }),
    );
  }

  Widget _buildLogroCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool desbloqueado,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: desbloqueado ? color : Colors.grey,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: desbloqueado ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: desbloqueado ? Colors.black87 : Colors.grey),
        ),
        trailing:
            desbloqueado
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }
}
