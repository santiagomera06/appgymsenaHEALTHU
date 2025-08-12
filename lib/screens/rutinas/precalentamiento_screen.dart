import 'package:flutter/material.dart';
import 'package:healthu/models/rutina_model.dart';
import 'package:healthu/screens/rutinas/ejercicio_actual_screen.dart';
import 'package:healthu/services/desafio_service.dart';
import 'package:healthu/services/rutina_service.dart';

class PrecalentamientoScreen extends StatelessWidget {
  final RutinaDetalle rutina;
  final int idDesafioRealizado;

  const PrecalentamientoScreen({
    super.key,
    required this.rutina,
    required this.idDesafioRealizado,
  });

  Future<void> _iniciarEjercicios(BuildContext context) async {
    try {
      // 0) Si por alguna razón viene sin ejercicios, corta
      if (rutina.ejercicios.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta rutina no tiene ejercicios.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 1) Loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // 2) Iniciar rutina (201 con registrosCreados: X es válido)
      final inicio = await DesafioService.registrarInicioRutina(
        idRutina: rutina.id,
        idDesafioRealizado: idDesafioRealizado,
      );

      if (inicio == null || inicio['success'] != true) {
        if (context.mounted) Navigator.pop(context);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar la rutina.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 3) ¿Ya tenemos idRutinaEjercicio?
      RutinaDetalle rutinaParaNavegar = rutina;
      final faltantesLocales =
          rutina.ejercicios.where((e) => e.idRutinaEjercicio == null).length;

      debugPrint('→ ejercicios en UI: ${rutina.ejercicios.length}. '
          'Faltan idRutinaEjercicio en UI: $faltantesLocales');

      if (faltantesLocales > 0) {
        // Re-hidratar desde GET /rutina/obtenerRutina/{id}
        final r = await RutinaService.obtenerRutina(rutina.id.toString());

        final faltantesRemotos =
            r.ejercicios.where((e) => e.idRutinaEjercicio == null).length;

        debugPrint('→ ejercicios backend: ${r.ejercicios.length}. '
            'Faltan idRutinaEjercicio desde backend: $faltantesRemotos');

        if (faltantesRemotos > 0) {
          if (context.mounted) Navigator.pop(context);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No se pudieron obtener $faltantesRemotos id(s) de rutina-ejercicio. Intenta de nuevo.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        rutinaParaNavegar = r;
      }

      // 4) Cerrar loader
      if (context.mounted) Navigator.pop(context);

      // 4.1) Evitar navegar si quedó vacía (por si acaso)
      if (rutinaParaNavegar.ejercicios.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron ejercicios para esta rutina.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 5) Feedback y navegar
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rutina iniciada. ¡Vamos!'),
          backgroundColor: Colors.green,
        ),
      );

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EjercicioActualScreen(
            rutina: rutinaParaNavegar,
            ejercicioIndex: 0,
            idDesafioRealizado: idDesafioRealizado,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Precalentamiento'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Antes de iniciar la rutina, realiza estos estiramientos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _estiramiento('Estiramiento de cuello'),
            _estiramiento('Rotación de hombros'),
            _estiramiento('Flexión de tronco'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _iniciarEjercicios(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Iniciar Ejercicios',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estiramiento(String titulo) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.accessibility_new),
        title: Text(titulo),
        subtitle: const Text('Realiza durante 30 segundos'),
      ),
    );
  }
}

