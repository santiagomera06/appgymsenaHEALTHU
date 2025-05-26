import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


/// BARRAS APILADAS  (Calorías por actividad)

class GraficaBarrasApiladas extends StatelessWidget {
  const GraficaBarrasApiladas({super.key});

  @override
  Widget build(BuildContext context) {
    final dias      = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi'];
    final cardio    = [300, 250, 400, 350, 200];
    final fuerza    = [150, 200, 100, 180, 120];
    final descanso  = [50,  60,  70,  40,  80];

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(dias.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: cardio[i] + fuerza[i] + descanso[i].toDouble(),
                  rodStackItems: [
                    BarChartRodStackItem(0, cardio[i].toDouble(), Colors.green),
                    BarChartRodStackItem(
                      cardio[i].toDouble(),
                      cardio[i] + fuerza[i].toDouble(),
                      Colors.lightGreen,
                    ),
                    BarChartRodStackItem(
                      cardio[i] + fuerza[i].toDouble(),
                      cardio[i] + fuerza[i] + descanso[i].toDouble(),
                      Colors.grey.shade300,
                    ),
                  ],
                  width: 16,
                ),
              ],
            );
          }),
          gridData:  FlGridData(show: true, horizontalInterval: 100),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(dias[value.toInt()]),
                ),
              ),
            ),
            leftTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}

