import 'package:flutter/material.dart';
import 'dart:async';

class TemporizadorWidget extends StatefulWidget {
  final int segundos;
  final VoidCallback onComplete;

  const TemporizadorWidget({
    super.key,
    required this.segundos,
    required this.onComplete,
  });

  @override
  State<TemporizadorWidget> createState() => _TemporizadorWidgetState();
}

class _TemporizadorWidgetState extends State<TemporizadorWidget> {
  late int _segundosRestantes;
  late Timer _timer;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();
    _segundosRestantes = widget.segundos;
    _iniciarTemporizador();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _iniciarTemporizador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 0) {
        setState(() => _segundosRestantes--);
      } else {
        _timer.cancel();
        widget.onComplete();
      }
    });
  }

  void _pausarTemporizador() {
    if (_isRunning) {
      _timer.cancel();
    } else {
      _iniciarTemporizador();
    }
    setState(() => _isRunning = !_isRunning);
  }

  @override
  Widget build(BuildContext context) {
    final minutos = (_segundosRestantes ~/ 60).toString().padLeft(2, '0');
    final segundos = (_segundosRestantes % 60).toString().padLeft(2, '0');

    return Column(
      children: [
        Text(
          '$minutos:$segundos',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pausarTemporizador,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRunning ? Colors.orange : Colors.green,
          ),
          child: Text(
            _isRunning ? 'Pausar' : 'Reanudar',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}