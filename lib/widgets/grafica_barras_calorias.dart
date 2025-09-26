import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class GraficaBarrasCalorias extends StatelessWidget {
  final Map<String, double> caloriasPorDia; // clave: yyyy-MM-dd

  const GraficaBarrasCalorias({super.key, required this.caloriasPorDia});

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();

    // 🔹 Lunes de la semana actual
    final inicioSemana = hoy.subtract(Duration(days: hoy.weekday - 1));

    // 🔹 SIEMPRE 7 días: Lun a Dom (aunque hoy no haya llegado)
    final diasSemana = List<DateTime>.generate(
      7,
      (i) => inicioSemana.add(Duration(days: i)),
    );

    // 🔹 Valores por día (si falta, 0.0)
    final valores = diasSemana.map((fecha) {
      final key = DateFormat('yyyy-MM-dd').format(fecha);
      return caloriasPorDia[key] ?? 0.0;
    }).toList();

    // 🔹 Etiquetas tipo "vie 26"
    final etiquetas = diasSemana
        .map((f) => DateFormat('EEE d', 'es').format(f))
        .toList();

    // 🔹 Total semanal mostrado arriba
    final totalSemanal = valores.fold<double>(0, (a, b) => a + b);

    // 🔹 Escala Y dinámica (mínimo 10 para que se vea bien)
    final maxValor = valores.fold<double>(0, max);
    final maxY = max(10.0, (maxValor == 0 ? 1.0 : maxValor) * 1.4);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Total semanal: ${totalSemanal.toStringAsFixed(2)} kcal',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 260,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;

              return Stack(
                children: [
                  BarChart(
                    BarChartData(
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: maxY / 5,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            interval: maxY / 5,
                            getTitlesWidget: (value, _) => Text(
                              value.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final i = value.toInt();
                              if (i >= 0 && i < etiquetas.length) {
                                return Text(etiquetas[i],
                                    style: const TextStyle(fontSize: 11));
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        topTitles:
                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles:
                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: List.generate(valores.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: valores[i],
                              color: Colors.green,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                          showingTooltipIndicators: [0],
                        );
                      }),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(6),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.toStringAsFixed(2)} kcal',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 🔹 Etiqueta numérica dentro de la barra (oculta si es 0)
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(valores.length, (i) {
                        final alturaRel = (valores[i] / maxY) * maxHeight;
                        return SizedBox(
                          width: 18,
                          child: valores[i] > 0
                              ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: max(0, alturaRel - 16),
                                    ),
                                    child: Text(
                                      valores[i].toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
