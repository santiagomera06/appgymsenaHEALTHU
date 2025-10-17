import 'package:flutter/material.dart';
import 'package:healthu/services/frecuencia_service.dart';
import 'package:intl/intl.dart';

class FrecuenciaListScreen extends StatefulWidget {
  const FrecuenciaListScreen({super.key});

  @override
  State<FrecuenciaListScreen> createState() => _FrecuenciaListScreenState();
}

class _FrecuenciaListScreenState extends State<FrecuenciaListScreen> {
  late Future<List<Map<String, dynamic>>> _frecuenciasFuture;

  @override
  void initState() {
    super.initState();
    _frecuenciasFuture = FrecuenciaService.obtenerFrecuenciasCardiacas();
  }

  /// ✅ Formatea fecha si existe, o devuelve “Sin fecha”
  String _formatearFecha(dynamic fechaRaw) {
    if (fechaRaw == null || fechaRaw.toString().isEmpty) {
      return 'Sin fecha';
    }
    try {
      final fecha = DateTime.parse(fechaRaw.toString());
      return DateFormat('dd/MM/yyyy hh:mm a', 'es').format(fecha);
    } catch (_) {
      return 'Sin fecha';
    }
  }

  /// ✅ Color dinámico según rango de BPM
  Color _colorPorFrecuencia(int bpm) {
    if (bpm < 60) return Colors.blue;
    if (bpm <= 100) return Colors.green;
    if (bpm <= 120) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Frecuencia Cardíaca"),
        backgroundColor: Colors.red[700],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _frecuenciasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text("No hay mediciones registradas"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final bpm = item['frecuenciaCardiaca'] ?? 0;
              final fecha = _formatearFecha(item['fechaMedicion']);
              final color = _colorPorFrecuencia(bpm);

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.favorite, color: color, size: 30),
                  title: Text(
                    "$bpm BPM",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  subtitle: Text("Fecha: $fecha"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
