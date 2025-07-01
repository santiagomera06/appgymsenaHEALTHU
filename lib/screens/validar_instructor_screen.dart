import 'package:flutter/material.dart';

class ValidarInstructorScreen extends StatefulWidget {
  final String rutinaId;

  const ValidarInstructorScreen({
    Key? key,
    required this.rutinaId,
  }) : super(key: key);

  @override
  State<ValidarInstructorScreen> createState() => _ValidarInstructorScreenState();
}

class _ValidarInstructorScreenState extends State<ValidarInstructorScreen> {
  bool _isSubmitting = false;

  void _submitValidation() async {
    setState(() => _isSubmitting = true);
    // TODO: Llamar servicio para notificar al instructor
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitud enviada al instructor'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar con Instructor'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enviar tu rutina completada al instructor para validación.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitValidation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green[800],
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enviar a Instructor', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
