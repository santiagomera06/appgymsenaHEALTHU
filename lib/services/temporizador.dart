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
  late int tiempoRestante;
  Timer? temporizador;

  @override
  void initState() {
    super.initState();
    tiempoRestante = widget.segundos;
    iniciarTemporizador();
  }

  void iniciarTemporizador() {
    temporizador = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (tiempoRestante == 0) {
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Tiempo finalizado!")),
        );
      } else {
        setState(() {
          tiempoRestante--;
        });
      }
    });
  }

  @override
  void dispose() {
    temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutos = (tiempoRestante ~/ 60).toString().padLeft(2, '0');
    final segundos = (tiempoRestante % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Center(
        child: Text(
          "$minutos:$segundos",
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
