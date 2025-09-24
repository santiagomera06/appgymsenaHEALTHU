import 'package:flutter/material.dart';
import 'package:healthu/models/rutina_model.dart' as rutina_model;
import 'package:healthu/services/rutina_service.dart';
import 'detalle_rutina.dart';

class DetalleRutinaScreenConApi extends StatelessWidget {
  final String rutinaId;

  const DetalleRutinaScreenConApi({super.key, required this.rutinaId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<rutina_model.RutinaDetalle>(
      future: RutinaService.obtenerRutina(rutinaId),
      builder: (context, snapshot) {
        // Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Manejo de errores
        if (snapshot.hasError) {
          return _buildErrorScaffold(
            context,
            title: 'Error',
            icon: Icons.error_outline,
            color: Colors.red,
            message: 'Error al cargar la rutina',
            details: snapshot.error.toString(),
          );
        }

        // Verificación de datos nulos
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildErrorScaffold(
            context,
            title: 'Rutina no encontrada',
            icon: Icons.search_off,
            color: Colors.orange,
            message: 'No se encontró la rutina solicitada',
          );
        }

        // Mostrar la rutina
        return DetalleRutinaScreen(rutina: snapshot.data!);
      },
    );
  }

  /// Construye pantallas de error/reintento reutilizables
  Scaffold _buildErrorScaffold(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String message,
    String? details,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: color),
              const SizedBox(height: 20),
              Text(
                message,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (details != null) ...[
                const SizedBox(height: 10),
                Text(
                  details,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
