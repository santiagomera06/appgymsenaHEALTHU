// lib/screens/grafica_anillo.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Modelo simple para cada sección del pastel
class PieSectionDataModel {
  final double value;
  final Color color;
  final String label;
  final Color textColor;

  const PieSectionDataModel({
    required this.value,
    required this.color,
    required this.label,
    required this.textColor,
  });
}

/// Widget parametrizable que muestra una gráfica de pastel.
/// Recibe una lista de [PieSectionDataModel] con value/color/label/textColor.
class GraficaCircular extends StatelessWidget {
  final List<PieSectionDataModel> sections;

  const GraficaCircular({
    super.key,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Distribución de Actividades",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            height: 260,
            width: 260,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 3,
                centerSpaceRadius: 70,
                sections: List.generate(
                  sections.length,
                  (i) => _buildSection(sections[i]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye una sección de la gráfica a partir del modelo
  PieChartSectionData _buildSection(PieSectionDataModel data) {
    return PieChartSectionData(
      value: data.value,
      color: data.color,
      radius: 70,
      title: data.label,
      titleStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: data.textColor,
      ),
      titlePositionPercentageOffset: 0.65,
    );
  }
}
