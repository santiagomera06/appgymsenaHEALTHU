import 'dart:async';
import 'package:flutter/material.dart';

class TemporizadorWidget extends StatefulWidget {
  /// Duración inicial en segundos
  final int segundos;
  /// Callback al completar la cuenta atrás
  final VoidCallback onComplete;

  const TemporizadorWidget({
    super.key,
    required this.segundos,
    required this.onComplete,
  });

  @override
  State<TemporizadorWidget> createState() =>
      TemporizadorWidgetState(); // usa clase pública
}

// Cambiamos de privado (_...) a público sin guión bajo
class TemporizadorWidgetState extends State<TemporizadorWidget> {
  late int _tiempoRestante;
  Timer? _timer;

  bool get isRunning => _timer?.isActive ?? false;

  @override
  void initState() {
    super.initState();
    _tiempoRestante = widget.segundos;
  }

 void start() {
  if (isRunning) return;
  // Fuerza rebuild para que el botón cambie de estado
  setState(() {});
  _timer = Timer.periodic(const Duration(seconds: 1), (_) {
    if (_tiempoRestante > 0) {
      setState(() => _tiempoRestante--);
    } else {
      _complete();
    }
  });
}

void pause() {
  _timer?.cancel();
  // Fuerza rebuild para que el botón cambie de estado
  setState(() {});
}

  void reset() {
    _timer?.cancel();
    setState(() => _tiempoRestante = widget.segundos);
  }

  void _complete() {
    _timer?.cancel();
    widget.onComplete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutos = (_tiempoRestante ~/ 60).toString().padLeft(2, '0');
    final segundos = (_tiempoRestante % 60).toString().padLeft(2, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
        '$minutos:$segundos',
        style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isRunning ? null : start,
              child: const Text('Iniciar'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isRunning ? pause : null,
              child: const Text('Pausar'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: reset,
              child: const Text('Reiniciar'),
            ),
          ],
        ),
      ],
    );
  }
}
