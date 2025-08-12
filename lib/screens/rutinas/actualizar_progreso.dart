import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class ActualizarProgreso extends StatefulWidget {
  final String desafioId;
  final String userId;
  final int puntosGanados;

  const ActualizarProgreso({
    super.key,
    required this.desafioId,
    required this.userId,
    required this.puntosGanados,
  });

  @override
  State<ActualizarProgreso> createState() => _ActualizarProgresoState();
}

class _ActualizarProgresoState extends State<ActualizarProgreso> {
  bool _progresoActualizado = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _actualizarProgreso();
  }

  Future<void> _actualizarProgreso() async {
    try {
      setState(() => _progresoActualizado = true);
    } catch (e) {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_progresoActualizado) ...[
              Lottie.asset(
                'assets/animations/success.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Progreso Actualizado!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '+${widget.puntosGanados} puntos',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Continuar', style: TextStyle(fontSize: 18)),
              ),
            ] else if (_error) ...[
              const Icon(Icons.error, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Error al actualizar progreso',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Volver', style: TextStyle(fontSize: 18)),
              ),
            ] else ...[
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Actualizando progreso...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
