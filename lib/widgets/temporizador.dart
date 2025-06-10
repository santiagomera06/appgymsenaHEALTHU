import 'package:flutter/material.dart';
import 'dart:async';

class TemporizadorPage extends StatefulWidget {
  final String titulo;
  final int segundos;

  const TemporizadorPage({super.key, required this.titulo, required this.segundos});

  @override
  State<TemporizadorPage> createState() => _TemporizadorPageState();
}

class _TemporizadorPageState extends State<TemporizadorPage> {
  late int _segundosRestantes;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _segundosRestantes = widget.segundos;
    _iniciarTemporizador();
  }

  void _iniciarTemporizador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 0) {
        setState(() {
          _segundosRestantes--;
        });
      } else {
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Rutina completada!')),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutos = (_segundosRestantes ~/ 60).toString().padLeft(2, '0');
    final segundos = (_segundosRestantes % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          '$minutos:$segundos',
          style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
