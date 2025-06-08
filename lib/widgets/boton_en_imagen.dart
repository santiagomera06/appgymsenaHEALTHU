import 'package:flutter/material.dart';

class BotonEnImagen extends StatelessWidget {
  final String texto;
  final String imagen;
  final VoidCallback onPressed;

  const BotonEnImagen({
    super.key,
    required this.texto,
    required this.imagen,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            imagen,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            height: 160,
            color: Colors.black.withOpacity(0.4),
          ),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
