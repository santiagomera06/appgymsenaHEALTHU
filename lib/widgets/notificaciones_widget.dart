import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔔 Widget para gestionar notificaciones y recordatorios
class NotificacionesWidget extends StatefulWidget {
  const NotificacionesWidget({super.key});

  @override
  State<NotificacionesWidget> createState() => _NotificacionesWidgetState();
}

class _NotificacionesWidgetState extends State<NotificacionesWidget> {
  bool _recordatoriosDiarios = true;
  bool _recordatoriosRacha = true;
  bool _notificacionesProgreso = true;
  TimeOfDay _horaRecordatorio = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recordatoriosDiarios = prefs.getBool('recordatorios_diarios') ?? true;
      _recordatoriosRacha = prefs.getBool('recordatorios_racha') ?? true;
      _notificacionesProgreso =
          prefs.getBool('notificaciones_progreso') ?? true;

      final hora = prefs.getInt('hora_recordatorio') ?? 18;
      final minuto = prefs.getInt('minuto_recordatorio') ?? 0;
      _horaRecordatorio = TimeOfDay(hour: hora, minute: minuto);
    });
  }

  Future<void> _guardarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('recordatorios_diarios', _recordatoriosDiarios);
    await prefs.setBool('recordatorios_racha', _recordatoriosRacha);
    await prefs.setBool('notificaciones_progreso', _notificacionesProgreso);
    await prefs.setInt('hora_recordatorio', _horaRecordatorio.hour);
    await prefs.setInt('minuto_recordatorio', _horaRecordatorio.minute);
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? nuevaHora = await showTimePicker(
      context: context,
      initialTime: _horaRecordatorio,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (nuevaHora != null) {
      setState(() {
        _horaRecordatorio = nuevaHora;
      });
      await _guardarPreferencias();
    }
  }

  void _probarNotificacion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.white),
            SizedBox(width: 8),
            Text('¡Notificación de prueba enviada! 🔔'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔔 Encabezado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Configuración de Notificaciones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildOpcionNotificacion(
                      icon: Icons.schedule,
                      titulo: 'Recordatorios Diarios',
                      descripcion: 'Recibe recordatorios para hacer ejercicio',
                      valor: _recordatoriosDiarios,
                      onChanged: (value) {
                        setState(() => _recordatoriosDiarios = value);
                        _guardarPreferencias();
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildOpcionNotificacion(
                      icon: Icons.local_fire_department,
                      titulo: 'Alertas de Racha',
                      descripcion: 'Avisos cuando tu racha esté en riesgo',
                      valor: _recordatoriosRacha,
                      onChanged: (value) {
                        setState(() => _recordatoriosRacha = value);
                        _guardarPreferencias();
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildOpcionNotificacion(
                      icon: Icons.trending_up,
                      titulo: 'Notificaciones de Progreso',
                      descripcion: 'Celebra tus logros y avances',
                      valor: _notificacionesProgreso,
                      onChanged: (value) {
                        setState(() => _notificacionesProgreso = value);
                        _guardarPreferencias();
                      },
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.access_time,
                              color:
                                  _recordatoriosDiarios
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                            title: Text(
                              'Hora de Recordatorio',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    _recordatoriosDiarios
                                        ? Colors.black
                                        : Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                              _recordatoriosDiarios
                                  ? 'Toca para cambiar la hora'
                                  : 'Habilita los recordatorios diarios',
                              style: TextStyle(
                                color:
                                    _recordatoriosDiarios
                                        ? Colors.grey
                                        : Colors.grey.shade400,
                              ),
                            ),
                            trailing: Text(
                              _recordatoriosDiarios
                                  ? _horaRecordatorio.format(context)
                                  : '--:--',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    _recordatoriosDiarios
                                        ? Colors.blue
                                        : Colors.grey,
                              ),
                            ),
                            onTap:
                                _recordatoriosDiarios ? _seleccionarHora : null,
                          ),
                          if (_recordatoriosDiarios)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Recibirás un recordatorio todos los días a esta hora',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🧪 Botón de Prueba
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _probarNotificacion,
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text(
                          'Probar Notificación',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _guardarPreferencias();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Configuración guardada correctamente'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionNotificacion({
    required IconData icon,
    required String titulo,
    required String descripcion,
    required bool valor,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        color:
            valor
                ? Colors.blue.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.02),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  valor
                      ? Colors.blue.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: valor ? Colors.blue : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: valor ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 12,
                    color: valor ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: valor, onChanged: onChanged, activeColor: Colors.blue),
        ],
      ),
    );
  }
}
