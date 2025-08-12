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
  State<TemporizadorWidget> createState() => TemporizadorWidgetState();
}

class TemporizadorWidgetState extends State<TemporizadorWidget> {
  late int _tiempoRestante;
  Timer? _timer;
  // ignore: unused_field
  int _tiempoTranscurrido = 0;

  bool get isRunning => _timer?.isActive ?? false;
  int get tiempoTranscurrido => widget.segundos - _tiempoRestante;

  @override
  void initState() {
    super.initState();
    _tiempoRestante = widget.segundos;
    _tiempoTranscurrido = 0;
  }

  void start() {
  if (isRunning) return;

  _timer = Timer.periodic(const Duration(seconds: 1), (_) {
    if (_tiempoRestante > 0) {
      setState(() {
        _tiempoRestante--;
        _tiempoTranscurrido++;
      });
      if (_tiempoRestante == 0) {
        _complete(); // <-- dispara justo cuando llega a 0
      }
    }
  });
}

void _complete() {
  _timer?.cancel();
  setState(() {}); // opcional: asegura refresco de UI
  widget.onComplete();
}
  void pause() {
    _timer?.cancel();
    setState(() {});
  }

  void reset() {
    _timer?.cancel();
    setState(() {
      _tiempoRestante = widget.segundos;
      _tiempoTranscurrido = 0;
    });
  }
  void restart() {
  reset();
  start();
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tiempo realizado: ${tiempoTranscurrido}s',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isRunning ? null : start,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Iniciar', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isRunning ? pause : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Pausar', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: reset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Reiniciar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}