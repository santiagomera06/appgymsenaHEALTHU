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
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Manejo de errores
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 50, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      'Error al cargar la rutina',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Verificación de datos nulos
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Rutina no encontrada')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 50, color: Colors.orange),
                  const SizedBox(height: 20),
                  Text(
                    'No se encontró la rutina solicitada',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        }

        // Mostrar la rutina
        return DetalleRutinaScreen(rutina: snapshot.data!);
      },
    );
  }
}