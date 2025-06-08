import 'package:flutter/material.dart';

class BotonEnImagen extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const BotonEnImagen({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        child: Text(texto),
      ),
    );
  }
}

