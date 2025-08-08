import 'package:flutter/material.dart';
import 'package:healthu/models/rutina_model.dart';
import 'package:healthu/services/desafio_service.dart';
import 'package:healthu/screens/rutinas/precalentamiento_screen.dart';

class DetalleRutinaScreen extends StatefulWidget {
  final RutinaDetalle rutina;

  const DetalleRutinaScreen({super.key, required this.rutina});

  @override
  State<DetalleRutinaScreen> createState() => _DetalleRutinaScreenState();
}

class _DetalleRutinaScreenState extends State<DetalleRutinaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rutina.nombre),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen y descripción
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.rutina.imagenUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fitness_center, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Chip(
              label: Text(
                widget.rutina.nivel,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.rutina.descripcion,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              'Ejercicios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            ...widget.rutina.ejercicios.map(_buildEjercicioCard),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () =>
              _iniciarRutinaConEndpoint(context, widget.rutina),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Iniciar Rutina',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildEjercicioCard(e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: e.imagenUrl.isNotEmpty
            ? Image.network(
                e.imagenUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.fitness_center, size: 40),
        title: Text(
          e.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${e.series} series x ${e.repeticiones} repeticiones'),
            if (e.pesoRecomendado != null)
              Text('Peso sugerido: ${e.pesoRecomendado} kg'),
          ],
        ),
      ),
    );
  }

Future<void> _iniciarRutinaConEndpoint(
  BuildContext context,
  RutinaDetalle rutina,
) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final desafio = await DesafioService.obtenerDesafioActual();
    debugPrint('🔁 Desafío obtenido: $desafio');

    // Extraemos el ID de forma segura
    final dynamic rawId = desafio?['idDesafioRealizado']
                       ?? desafio?['idDesafioRealiado'];
    final int? idDesafio = (rawId is int)
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');

    if (idDesafio == null) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró un ID válido de desafío.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final resultado = await DesafioService.iniciarRutinaDesafio(idDesafio);
    debugPrint('🔁 Respuesta al iniciar rutina: $resultado');

    if (context.mounted) Navigator.pop(context);

    if (resultado != null &&
        (resultado == true ||
         (resultado is Map && resultado['success'] == true))) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrecalentamientoScreen(
            rutina: rutina,
            idDesafioRealizado: idDesafio,
          ),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar la rutina.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) Navigator.pop(context);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

}
