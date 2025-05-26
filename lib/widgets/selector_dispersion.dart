// lib/widgets/selector_dispersion.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SelectorDispersion extends StatefulWidget {
  const SelectorDispersion({super.key});

  @override
  State<SelectorDispersion> createState() => _SelectorDispersionState();
}

class _SelectorDispersionState extends State<SelectorDispersion> {
  int _index = 0; 


  final List<double> duraciones = [10, 20, 30, 40, 50];   // min
  final List<double> calorias   = [50, 120, 200, 280, 350]; // kcal
  final List<double> pesos      = [60, 70, 80, 90, 100];  // kg
  final List<double> imc        = [22, 24, 26, 28, 30];   // IMC
  

  @override
  Widget build(BuildContext context) {
    late String titulo;
    late List<ScatterSpot> spots;
    late List<_Leyenda> leyendas;

    if (_index == 0) {
      // ── Duración (X,0)  +  Calorías (0,Y) ──
      titulo = 'Duración-Calorías';
      spots  = [
        for (var d in duraciones)
          ScatterSpot(d, 0, color: Colors.blue,   radius: 6),
        for (var c in calorias)
          ScatterSpot(0, c, color: Colors.orange, radius: 6),
      ];
      leyendas = const [
        _Leyenda(color: Colors.blue,   texto: 'Duración (min)'),
        _Leyenda(color: Colors.orange, texto: 'Calorías (kcal)'),
      ];
    } else {
      // ── Peso (X,0)  +  IMC (0,Y) ──
      titulo = 'Peso-IMC';
      spots  = [
        for (var p in pesos)
          ScatterSpot(p, 0, color: Colors.green,  radius: 6),
        for (var i in imc)
          ScatterSpot(0, i, color: Colors.yellow, radius: 6),
      ];
      leyendas = const [
        _Leyenda(color: Colors.green,  texto: 'Peso (kg)'),
        _Leyenda(color: Colors.yellow, texto: 'IMC'),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selector de pestañas
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Durac-Cal')),
            ButtonSegment(value: 1, label: Text('Peso-IMC')),
          ],
          selected: {_index},
          onSelectionChanged: (s) => setState(() => _index = s.first),
        ),
        const SizedBox(height: 12),

        // Título de la gráfica
        Center(child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600))),

        // Gráfica de dispersión
        SizedBox(
          height: 240,
          child: ScatterChart(
            ScatterChartData(
              scatterSpots: spots,
              gridData:   FlGridData(show: true),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: true),
              scatterTouchData: ScatterTouchData(enabled: true),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Leyenda con los dos colores activos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: leyendas
              .expand((l) => [l, const SizedBox(width: 16)])
              .toList()
            ..removeLast(), // quita el último espacio
        ),
      ],
    );
  }
}

// ---- widget interno para la leyenda -------------------------
class _Leyenda extends StatelessWidget {
  final Color color;
  final String texto;
  const _Leyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(texto, style: const TextStyle(fontSize: 12)),
        ],
      );
}
