
import 'package:flutter/material.dart';

class TemporizadorPage extends StatelessWidget {
  final String titulo;
  final int segundos;

  const TemporizadorPage({
    super.key,
    required this.titulo,
    required this.segundos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: const Center(
        child: Text(
          "Temporizador activo...",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
