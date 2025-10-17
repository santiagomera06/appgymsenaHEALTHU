import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:healthu/services/asignacion_rutina_service.dart';
import 'package:healthu/services/rutina_service.dart';
import 'package:healthu/models/rutina_model.dart' as rutina_model;
import 'package:awesome_dialog/awesome_dialog.dart';

class RutinaAsignadaScreen extends StatefulWidget {
  final List<AsignacionRutina> asignaciones;
  const RutinaAsignadaScreen({super.key, required this.asignaciones});

  @override
  State<RutinaAsignadaScreen> createState() => _RutinaAsignadaScreenState();
}

class _RutinaAsignadaScreenState extends State<RutinaAsignadaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  Future<rutina_model.RutinaDetalle>? _futureRutina;
  String? _diaSeleccionado;

  final Map<int, Color> _coloresRutinas = {};
  final List<Color> _coloresDisponibles = [
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.blue,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _asignarColoresRutinas();

    // 🚨 Mostrar alerta si no hay rutinas asignadas
    if (widget.asignaciones.isEmpty) {
      Future.microtask(() {
        _mostrarDialogo(
          tipo: DialogType.warning,
          titulo: 'Sin rutinas asignadas 🏋️‍♂️',
          mensaje:
              'Actualmente no tienes rutinas asignadas.\nPuedes crear una o esperar a que tu instructor te asigne una rutina.',
        );
      });
    }
  }

  /// 🔹 Diálogo profesional unificado
  void _mostrarDialogo({
    required DialogType tipo,
    required String titulo,
    required String mensaje,
    VoidCallback? onOk,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: tipo,
      animType: AnimType.scale,
      title: titulo,
      desc: mensaje,
      btnOkOnPress: onOk ?? () {},
      btnOkColor: tipo == DialogType.success
          ? Colors.green
          : tipo == DialogType.error
              ? Colors.red
              : Colors.orange,
      width: 330,
      dismissOnTouchOutside: true,
    ).show();
  }

  void _asignarColoresRutinas() {
    int i = 0;
    for (final a in widget.asignaciones) {
      if (!_coloresRutinas.containsKey(a.idRutina)) {
        _coloresRutinas[a.idRutina] =
            _coloresDisponibles[i % _coloresDisponibles.length];
        i++;
      }
    }
  }

  List<String> _dias(String diasAsignado) {
    return diasAsignado
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<int> _diasWeekdays(String diasAsignado) {
    final mapaDias = {
      'lunes': DateTime.monday,
      'martes': DateTime.tuesday,
      'miércoles': DateTime.wednesday,
      'miercoles': DateTime.wednesday,
      'jueves': DateTime.thursday,
      'viernes': DateTime.friday,
      'sábado': DateTime.saturday,
      'sabado': DateTime.saturday,
      'domingo': DateTime.sunday,
    };

    return _dias(diasAsignado)
        .map((d) => mapaDias[d.toLowerCase()])
        .whereType<int>()
        .toList();
  }

  Future<void> _cargarEjercicios(AsignacionRutina a) async {
    try {
      final rutina = a.nombreRutina != null && a.nombreRutina!.isNotEmpty
          ? await RutinaService.obtenerRutinaPorNombre(a.nombreRutina!)
          : await RutinaService.obtenerRutinaPorId(a.idRutina);

      if (!mounted) return;
      setState(() {
        _futureRutina = Future.value(rutina);
        _tab.animateTo(1);
      });
    } catch (e) {
      debugPrint('Error cargando ejercicios de rutina ${a.idRutina}: $e');
      _mostrarDialogo(
        tipo: DialogType.error,
        titulo: 'Error al cargar rutina',
        mensaje: 'No se pudo cargar la rutina seleccionada.\nIntenta nuevamente.',
      );
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asignaciones.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rutinas asignadas')),
        body: const Center(
          child: Text(
            'No tienes rutinas asignadas',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    final firstDay = widget.asignaciones
        .map((a) => a.fechaAsignacion ?? DateTime.now())
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final lastDay = DateTime.now().add(const Duration(days: 30));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas asignadas'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Resumen'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Ejercicios'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Días'),
            Tab(icon: Icon(Icons.note_alt_outlined), text: 'Observaciones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildResumen(),
          _buildEjercicios(),
          _buildCalendario(firstDay, lastDay),
          _buildObservaciones(),
        ],
      ),
    );
  }

  Widget _buildResumen() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.asignaciones.length,
      itemBuilder: (_, i) {
        final a = widget.asignaciones[i];
        final numeroRutina = i + 1;
        final colorBase = _coloresRutinas[a.idRutina] ?? Colors.grey;
        final fondoSuave = colorBase.withOpacity(0.15);

        return Card(
          color: fondoSuave,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: colorBase),
            title: Text(
              'Rutina asignada $numeroRutina',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Días: ${a.diasAsignado.isNotEmpty ? a.diasAsignado : "-"}'),
                Text(
                    'Asignada: ${DateFormat("yyyy-MM-dd").format(a.fechaAsignacion ?? DateTime.now())}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () => _cargarEjercicios(a),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEjercicios() {
    if (_futureRutina == null) {
      return const Center(
        child: Text('Selecciona una rutina para ver sus ejercicios.'),
      );
    }

    return FutureBuilder<rutina_model.RutinaDetalle>(
      future: _futureRutina,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.ejercicios.isEmpty) {
          return const Center(child: Text('No hay ejercicios registrados.'));
        }

        final ejercicios = snapshot.data!.ejercicios;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ejercicios.length,
          itemBuilder: (_, i) {
            final e = ejercicios[i];
            return Card(
              color: Colors.grey[100],
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
                title: Text(e.nombre),
                subtitle: Text(
                    '${e.descripcion ?? ""}\nSeries: ${e.series ?? "-"} | Reps: ${e.repeticiones ?? "-"} | Carga: ${e.pesoRecomendado ?? "-"}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendario(DateTime firstDay, DateTime lastDay) {
    return Column(
      children: [
        Expanded(
          child: TableCalendar(
            locale: 'es_ES',
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                final rutinasDelDia = widget.asignaciones.where((a) {
                  final dias = _diasWeekdays(a.diasAsignado);
                  return dias.contains(day.weekday);
                }).toList();

                if (rutinasDelDia.isEmpty) return null;

                if (rutinasDelDia.length > 1) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: rutinasDelDia
                            .map((a) =>
                                _coloresRutinas[a.idRutina] ?? Colors.grey)
                            .toList(),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text('${day.day}',
                        style: const TextStyle(color: Colors.white)),
                  );
                }

                final color = _coloresRutinas[rutinasDelDia.first.idRutina] ??
                    Colors.grey;

                return Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('${day.day}',
                      style: const TextStyle(color: Colors.white)),
                );
              },
            ),
            onDaySelected: (selectedDay, _) {
              final rutinasDelDia = widget.asignaciones.where((a) {
                final dias = _diasWeekdays(a.diasAsignado);
                return dias.contains(selectedDay.weekday);
              }).toList();

              if (rutinasDelDia.isNotEmpty) {
                final nombres = rutinasDelDia
                    .map((a) =>
                        'Rutina asignada ${widget.asignaciones.indexOf(a) + 1}')
                    .toSet()
                    .join(', ');
                setState(() {
                  _diaSeleccionado =
                      DateFormat.EEEE('es_ES').format(selectedDay);
                });
                _mostrarDialogo(
                  tipo: DialogType.info,
                  titulo: 'Rutinas del $_diaSeleccionado',
                  mensaje: nombres,
                );
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: widget.asignaciones.asMap().entries.map((entry) {
              final index = entry.key;
              final asignacion = entry.value;
              final numeroRutina = index + 1;
              final color = _coloresRutinas[asignacion.idRutina] ?? Colors.grey;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text('Rutina asignada $numeroRutina'),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildObservaciones() {
    final observaciones = widget.asignaciones
        .where((a) => a.observaciones.trim().isNotEmpty)
        .toList();

    if (observaciones.isEmpty) {
      return const Center(child: Text('Sin observaciones.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: observaciones.length,
      itemBuilder: (_, i) {
        final a = observaciones[i];
        final numeroRutina = widget.asignaciones.indexOf(a) + 1;
        final colorBase = _coloresRutinas[a.idRutina] ?? Colors.grey;
        final fondoSuave = colorBase.withOpacity(0.15);

        return Card(
          color: fondoSuave,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: colorBase),
            title: Text(
              'Observación de la rutina asignada $numeroRutina',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(a.observaciones),
          ),
        );
      },
    );
  }
}
