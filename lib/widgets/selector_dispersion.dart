import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthu/services/desafio_service.dart';
import 'dart:async';
import 'dart:math';

class SelectorDispersion extends StatefulWidget {
  const SelectorDispersion({super.key});

  @override
  State<SelectorDispersion> createState() => _SelectorDispersionState();
}

class _SelectorDispersionState extends State<SelectorDispersion> {
  int _index = 0;
  late Future<List<Map<String, dynamic>>> _futureDesafios;
  Timer? _timer;
  bool _actualizando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _cargar());
  }

  void _cargar() async {
    if (_actualizando) return;
    setState(() => _actualizando = true);

    setState(() {
      _futureDesafios = DesafioService.obtenerDesafiosPorUsuario();
    });

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _actualizando = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureDesafios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("No hay datos disponibles para comparar variables");
        }

        final lista = snapshot.data!;
        final spots = <ScatterSpot>[];
        final random = Random();

        if (_index == 0) {
          for (final d in lista) {
            final inicio = d['fechaInicioDesafio'];
            final fin = d['fechaFinDesafio'];
            final calorias = (d['caloriasTotales'] ?? 0).toDouble();
            if (inicio != null && fin != null && calorias > 0) {
              final start = DateTime.parse(inicio);
              final end = DateTime.parse(fin);
              final duracionMin = end.difference(start).inSeconds / 60;
              if (duracionMin > 0) {
                spots.add(
                  ScatterSpot(
                    duracionMin,
                    calorias,
                    dotPainter: FlDotCirclePainter(
                      color: Colors.orangeAccent,
                      radius: 6,
                    ),
                  ),
                );
              }
            }
          }
        } else {
          for (final d in lista) {
            final calorias = (d['caloriasTotales'] ?? 0).toDouble();
            final puntos = (d['puntosObtenidos'] ?? 0).toDouble();
            if (calorias > 0 && puntos > 0) {
              spots.add(
                ScatterSpot(
                  puntos,
                  calorias,
                  dotPainter: FlDotCirclePainter(
                    color: Colors.tealAccent.shade700,
                    radius: 6 + random.nextDouble() * 2,
                  ),
                ),
              );
            }
          }
        }

        if (spots.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No hay suficientes datos con calorías/puntos válidos."),
          );
        }

        final titulo = _index == 0
            ? "Duración (min) vs Calorías quemadas"
            : "Puntos obtenidos vs Calorías quemadas";

        final leyendas = _index == 0
            ? [_Leyenda(color: Colors.orangeAccent, texto: "Duración vs Calorías")]
            : [_Leyenda(color: Colors.teal, texto: "Puntos vs Calorías")];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Duración-Calorías')),
                      ButtonSegment(value: 1, label: Text('Puntos-Calorías')),
                    ],
                    selected: {_index},
                    onSelectionChanged: (s) {
                      setState(() => _index = s.first);
                      _cargar();
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar ahora',
                  onPressed: _actualizando ? null : _cargar,
                  icon: Icon(
                    Icons.refresh,
                    color: _actualizando ? Colors.grey : Colors.blueAccent,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12), // 🔥 sin const aquí

            Center(
              child: Text(
                titulo,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 8),

            SizedBox(
              height: 250,
              child: ScatterChart(
                ScatterChartData(
                  scatterSpots: spots,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 50),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 50),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  scatterTouchData: ScatterTouchData(enabled: true),
                ),
              ),
            ),

            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: leyendas
                  .expand((l) => [l, SizedBox(width: 16)])
                  .toList()
                ..removeLast(),
            ),
            SizedBox(height: 6),
            Center(
              child: Text(
                "Se actualiza automáticamente cada 10 s 🔄",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String texto;
  const _Leyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 4),
          Text(texto, style: TextStyle(fontSize: 12)),
        ],
      );
}
