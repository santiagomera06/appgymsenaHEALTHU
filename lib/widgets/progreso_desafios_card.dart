import 'package:flutter/material.dart';
import 'package:healthu/services/desafio_service.dart';
import 'package:healthu/screens/estadisticas/progreso_estadisticas_screen.dart';

/// Widget para mostrar el progreso actual de desafíos en el Dashboard
class ProgresoDesafiosCard extends StatefulWidget {
  const ProgresoDesafiosCard({super.key});

  @override
  State<ProgresoDesafiosCard> createState() => _ProgresoDesafiosCardState();

  //  Instancia estática para permitir refresco global
  static _ProgresoDesafiosCardState? _currentInstance;

  /// Método estático para refrescar el widget desde cualquier pantalla
  static Future<void> refrescarGlobal() async {
    if (_currentInstance != null) {
      await _currentInstance!._cargarProgresoDesafio();
    }
  }
}

class _ProgresoDesafiosCardState extends State<ProgresoDesafiosCard> {
  Map<String, dynamic>? _desafioActual;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Registrar esta instancia para refresco global
    ProgresoDesafiosCard._currentInstance = this;

    // Delay para evitar llamadas duplicadas con desafios_screen
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _cargarProgresoDesafio();
      }
    });
  }

  @override
  void dispose() {
    // Limpiar referencia al destruir el widget
    if (ProgresoDesafiosCard._currentInstance == this) {
      ProgresoDesafiosCard._currentInstance = null;
    }
    super.dispose();
  }

  Future<void> _cargarProgresoDesafio() async {
    try {
      setState(() {
        _cargando = true;
        _error = null;
      });

      final desafio = await DesafioService.obtenerDesafioActual();

      setState(() {
        _desafioActual = desafio;
        _cargando = false;
      });
    } catch (e) {
      print(' Error al cargar progreso del desafío: $e');
      setState(() {
        _error = 'Error al cargar desafío: ${e.toString()}';
        _cargando = false;
      });
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'en progreso':
        return Colors.orange;
      case 'bloqueado':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getIconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Icons.check_circle;
      case 'en progreso':
        return Icons.play_circle_filled;
      case 'bloqueado':
        return Icons.lock;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Desafío Actual',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_cargando)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _cargarProgresoDesafio,
                    tooltip: 'Actualizar progreso',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            if (_cargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _cargarProgresoDesafio,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else if (_desafioActual != null)
              _buildDesafioInfo()
            else
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox, color: Colors.grey, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'No hay desafíos disponibles',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesafioInfo() {
    final desafio = _desafioActual!;
    final nombreDesafio = desafio['nombreDesafio'] ?? 'Desafío Sin Nombre';
    final numeroDesafio = desafio['numeroDesafio'] ?? 0;
    final estadoDesafio = desafio['estadoDesafio'] ?? 'Desconocido';

    final colorEstado = _getColorEstado(estadoDesafio);
    final iconoEstado = _getIconoEstado(estadoDesafio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información principal
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorEstado.withOpacity(0.1),
                colorEstado.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorEstado.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(iconoEstado, color: colorEstado, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreDesafio,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Desafío #$numeroDesafio',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorEstado,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            estadoDesafio,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 🔹 Solo mostrar Estado (sin Puntos)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildStatCard(
                'Estado',
                estadoDesafio,
                iconoEstado,
                colorEstado,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Botones de acción
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProgresoEstadisticasScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.analytics),
                label: const Text('Estadísticas'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorEstado,
                  side: BorderSide(color: colorEstado),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
