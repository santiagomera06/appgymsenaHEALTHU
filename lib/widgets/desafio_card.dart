import 'package:flutter/material.dart';
import 'package:healthu/models/desafio_model.dart';
import 'package:healthu/styles/desafios_styles.dart';

class DesafioCard extends StatelessWidget {
  final Desafio desafio;
  final VoidCallback? onTap;

  const DesafioCard({
    super.key,
    required this.desafio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: desafio.desbloqueado ? onTap : null,
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.circle,
                  size: 60,
                  color: DesafiosStyles.getCardColor(desafio),
                ),
                if (!desafio.desbloqueado)
                  const Icon(Icons.lock, size: 30, color: Colors.grey),
                if (desafio.completado)
                  const Icon(Icons.check, size: 30, color: Colors.white),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              desafio.nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: desafio.desbloqueado ? Colors.black : const Color.fromARGB(255, 200, 8, 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}