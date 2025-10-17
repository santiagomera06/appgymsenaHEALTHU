import 'package:flutter/material.dart';

class Nivel extends StatelessWidget {
  final String nivel;

  const Nivel({super.key, required this.nivel});

  double _calcularProgreso(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'intermedio':
        return 0.66;
      case 'avanzado':
        return 1.0;
      default:
        return 0.33; // Principiante o valor desconocido
    }
  }

  @override
  Widget build(BuildContext context) {
    final progreso = _calcularProgreso(nivel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0, end: progreso),
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Principiante'),
            Text('Intermedio'),
            Text('Avanzado'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Nivel actual: $nivel',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
