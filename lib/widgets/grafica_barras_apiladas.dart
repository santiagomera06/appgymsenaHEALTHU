import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:healthu/services/desafio_service.dart';

class GraficaBarrasApiladas extends StatefulWidget {
  const GraficaBarrasApiladas({super.key});

  @override
  State<GraficaBarrasApiladas> createState() => _GraficaBarrasApiladasState();
}

class _GraficaBarrasApiladasState extends State<GraficaBarrasApiladas> {
  bool _cargando = true;
  Map<String, Map<String, double>> _datosAgrupados = {}; // día -> actividad -> calorías

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final lista = await DesafioService.obtenerDesafiosPorUsuario();
      final hoy = DateTime.now();
      final lunes = hoy.subtract(Duration(days: hoy.weekday - 1));
      final semana = List.generate(7, (i) => lunes.add(Duration(days: i)));

      final Map<String, Map<String, double>> agrupados = {};

      for (var d in lista) {
        final estado = (d['estado'] ?? '').toString().toLowerCase();
        if (estado != 'finalizado') continue;

        final fechaRaw = d['fechaFinDesafio'] ?? d['fechaInicioDesafio'];
        if (fechaRaw == null) continue;

        final fecha = DateTime.parse(fechaRaw);
        final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);
        if (fecha.isBefore(lunes) || fecha.isAfter(lunes.add(const Duration(days: 6)))) continue;

        final actividad = 'Desafío ${d['idDesafio']}'; // puedes cambiar por nombre si lo tienes
        final calorias = (d['caloriasTotales'] ?? 0).toDouble();

        agrupados.putIfAbsent(fechaStr, () => {});
        agrupados[fechaStr]![actividad] = (agrupados[fechaStr]![actividad] ?? 0) + calorias;
      }

      setState(() {
        _datosAgrupados = agrupados;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error cargando datos apilados: $e');
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_datosAgrupados.isEmpty) return const Text("No hay datos de esta semana");

    final dias = _datosAgrupados.keys.toList()..sort();
    final actividades = _datosAgrupados.values.expand((v) => v.keys).toSet().toList();

    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actividades.map((a) {
              final color = _colorPorActividad(a);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, color: color),
                  const SizedBox(width: 4),
                  Text(a, style: const TextStyle(fontSize: 10)),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dias.map((fecha) {
                final dia = DateFormat('E', 'es').format(DateTime.parse(fecha)).toUpperCase();
                final totalDia = _datosAgrupados[fecha]!;
                final totalCal = totalDia.values.fold<double>(0, (a, b) => a + b);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 🔹 Barra apilada
                        SizedBox(
                          height: 180,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: totalDia.entries.map((e) {
                              final color = _colorPorActividad(e.key);
                              final altura = (e.value / (totalCal > 0 ? totalCal : 1)) * 120 + e.value * 2;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                width: 20,
                                height: altura,
                                color: color,
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dia,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${totalCal.toStringAsFixed(1)} kcal',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorPorActividad(String actividad) {
    final index = actividad.hashCode % Colors.primaries.length;
    return Colors.primaries[index].shade400;
  }
}
