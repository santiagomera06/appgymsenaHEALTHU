// lib/screens/rutinas/rutina_asignada_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:healthu/models/asignacion_rutina.dart';
import 'package:healthu/services/rutina_service.dart';
import 'package:healthu/models/rutina_model.dart' as rutina_model;

class RutinaAsignadaScreen extends StatefulWidget {
  final AsignacionRutina asignacion;
  const RutinaAsignadaScreen({super.key, required this.asignacion});

  @override
  State<RutinaAsignadaScreen> createState() => _RutinaAsignadaScreenState();
}

class _RutinaAsignadaScreenState extends State<RutinaAsignadaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  Future<rutina_model.RutinaDetalle>? _futureRutina;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    if (widget.asignacion.idRutina != 0) {
      _futureRutina =
          RutinaService.obtenerRutina(widget.asignacion.idRutina.toString());

    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _fmt(DateTime? dt) =>
      dt == null ? '-' : DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());

  List<String> _dias() {
    final raw = widget.asignacion.diasAsignado ?? '';
    return raw.split(RegExp(r'[,\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.asignacion;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutina asignada'),
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
          // -------- Resumen --------
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _tile('ID Asignación', '${a.idAsignacion}'),
              _tile('ID Persona', '${a.idPersona}'),
              _tile('ID Rutina', '${a.idRutina}'),
              _tile('Fecha asignación', _fmt(a.fechaAsignacion)),
              _tile('Fecha finalización', _fmt(a.fechaFinalizacion)),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.green.withValues(alpha: 0.08),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(children: [
                    Icon(Icons.check_circle_outline, size: 36),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Rutina activa', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Text('Días: ${_dias().isEmpty ? '-' : _dias().join(', ')}'),
            ],
          ),

          // -------- Ejercicios (desde /rutina/obtenerRutina/{id}) --------
          _futureRutina == null
              ? _vacio('No se configuró la carga de ejercicios (idRutina=0).')
              : FutureBuilder<rutina_model.RutinaDetalle>(
                  future: _futureRutina,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      const hint =
                          'Verifica: GET /rutina/obtenerRutina/{id} (debe traer "ejercicios").';
                      return _error('No se pudieron cargar los ejercicios.\n\n$hint\n\n${snap.error}');
                    }
                    final items = snap.data!.ejercicios;
                    return items.isEmpty
                        ? _vacio('Esta rutina no tiene ejercicios.')
                        : _listaEjercicios(items);
                  },
                ),

          // -------- Días (pestañas por día) --------
          _buildDiasTabs(),

          // -------- Observaciones --------
          _observaciones(a.observaciones),
        ],
      ),
    );
  }

  // ---------- Widgets auxiliares ----------
  Widget _tile(String t, String v) => ListTile(
        dense: true,
        leading: const Icon(Icons.chevron_right),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(v),
      );

  Widget _vacio(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ),
      );

  Widget _error(String msg) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(msg, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ]),
      );

  Widget _listaEjercicios(List<rutina_model.EjercicioRutina> items) {
    Text _kv(String k, String v) => Text('$k: $v');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final e = items[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
            title: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                if ((e.descripcion ?? '').isNotEmpty) Text(e.descripcion!),
                _kv('Series', '${e.series ?? '-'}'),
                _kv('Reps', '${e.repeticiones ?? '-'}'),
                if (e.pesoRecomendado != null) _kv('Carga', '${e.pesoRecomendado}'),
                if (e.duracionEstimada != null) _kv('Duración', '${e.duracionEstimada}'),
                if (e.completado == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Chip(label: Text('Completado')),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  /// Pestañas por día: por ahora muestra todos los ejercicios en cada día.
  Widget _buildDiasTabs() {
    final dias = _dias();
    if (dias.isEmpty) return _vacio('Sin días asignados.');

    return FutureBuilder<rutina_model.RutinaDetalle>(
      future: _futureRutina,
      builder: (context, snap) {
        final ejercicios =
            snap.hasData ? snap.data!.ejercicios : <rutina_model.EjercicioRutina>[];
        return DefaultTabController(
          length: dias.length,
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: TabBar(isScrollable: true, tabs: dias.map((d) => Tab(text: d)).toList()),
              ),
              const Divider(height: 1),
              Expanded(
                child: TabBarView(
                  children: dias.map((_) {
                    if (!snap.hasData) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return _error('Error cargando la rutina:\n${snap.error}');
                      }
                    }
                    return ejercicios.isEmpty
                        ? _vacio('Sin ejercicios asignados para este día.')
                        : _listaEjercicios(ejercicios);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _observaciones(String? obs) {
    final text = (obs == null || obs.trim().isEmpty) ? 'Sin observaciones.' : obs.trim();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(padding: const EdgeInsets.all(16), child: Text(text)),
      ),
    );
  }
}
