import 'package:flutter/material.dart';
import 'package:healthu/models/rutina_model.dart';
import 'package:healthu/screens/rutinas/ejercicio_actual_screen.dart';
import 'package:healthu/services/desafio_service.dart';


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
    // 1) Mostrar loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // 2) Marcar el inicio de la rutina (el 201 con registrosCreados: 0 es válido)
    final inicio = await DesafioService.registrarInicioRutina(
      idRutina: rutina.id,
      idDesafioRealizado: idDesafioRealizado,
    );

    // 3) Cerrar loader
    if (context.mounted) Navigator.pop(context);

    // 4) Validar respuesta y navegar
    if (inicio == null || inicio['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar la rutina.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // (Opcional) feedback de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rutina iniciada correctamente.'),
        backgroundColor: Colors.green,
      ),
    );

    // 5) Ir al primer ejercicio
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EjercicioActualScreen(
            rutina: rutina,
            ejercicioIndex: 0,
            idDesafioRealizado: idDesafioRealizado,
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) Navigator.pop(context);
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
