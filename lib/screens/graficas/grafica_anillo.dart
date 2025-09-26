import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthu/services/desafio_service.dart';

/// Modelo para cada pedazo del anillo
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

/// 🔹 Gráfica de anillo que muestra Finalizados vs En Progreso
class GraficaDesafios extends StatefulWidget {
  const GraficaDesafios({super.key});

  @override
  State<GraficaDesafios> createState() => _GraficaDesafiosState();
}

class _GraficaDesafiosState extends State<GraficaDesafios> {
  Map<String, int> conteoEstados = {"finalizados": 0, "enProgreso": 0};
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEstados();
  }

  /// Consulta al backend cuántos desafíos están finalizados/en progreso
  Future<void> _cargarEstados() async {
    final prefs = await SharedPreferences.getInstance();
    final idPersona = int.tryParse(prefs.getString('id_persona') ?? '');

    if (idPersona != null) {
      final data = await DesafioService.obtenerConteoEstados(idPersona);
      setState(() {
        conteoEstados = data;
        cargando = false;
      });
    } else {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final secciones = <PieSectionDataModel>[];

    // Finalizados (verde)
    for (int i = 0; i < (conteoEstados["finalizados"] ?? 0); i++) {
      secciones.add(PieSectionDataModel(
        value: 1,
        color: Colors.green,
        label: "${i + 1}",
        textColor: Colors.white,
      ));
    }

    // En progreso (naranja)
    for (int i = 0; i < (conteoEstados["enProgreso"] ?? 0); i++) {
      secciones.add(PieSectionDataModel(
        value: 1,
        color: Colors.orange,
        label: "${i + 1}",
        textColor: Colors.black,
      ));
    }

    return Column(
      children: [
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
                  secciones.length,
                  (i) => _buildSection(secciones[i]),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(width: 16, height: 16, color: Colors.green),
                const SizedBox(width: 6),
                const Text("Finalizados"),
              ],
            ),
            const SizedBox(width: 20),
            Row(
              children: [
                Container(width: 16, height: 16, color: Colors.orange),
                const SizedBox(width: 6),
                const Text("En Progreso"),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Construye un pedazo del anillo
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
