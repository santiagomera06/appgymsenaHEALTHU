// lib/screens/graficas_dashboard.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget parametrizable que muestra una gráfica de barras.
/// Recibe una lista de valores (por ejemplo, métricas diarias).
class GraficaBarras extends StatelessWidget {
  final List<double> valores;

  const GraficaBarras({
    super.key,
    required this.valores,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar el valor máximo para escalar el eje Y
    final maxVal = valores.isNotEmpty ? valores.reduce(max) : 0.0;

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal + 1, // un poco más alto que el máximo
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            // Eje Y (izquierdo)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            // Eje X (inferior) con días de la semana
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                  final idx = value.toInt();
                  return Text(
                    (idx >= 0 && idx < dias.length) ? dias[idx] : '',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            // Ocultar ejes derecho y superior
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            valores.length,
            (i) => _barGroup(i, valores[i]),
          ),
        ),
      ),
    );
  }

  /// Crea un grupo de barras (una sola barra) en la posición x con altura y
  BarChartGroupData _barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 18,
          color: Colors.green,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

/// Widget que muestra una barra de progreso animada
class BarraProgreso extends StatelessWidget {
  const BarraProgreso({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 0.75),
      duration: const Duration(seconds: 2),
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.grey.shade300,
        color: Colors.green,
      ),
    );
  }
}

/// Muestra el título de sección con tamaño 18 y peso de letra negrita
class TextoSeccion extends StatelessWidget {
  final String texto;

  const TextoSeccion(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
