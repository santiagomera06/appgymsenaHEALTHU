import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimacionProgreso extends StatelessWidget {
  const AnimacionProgreso({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/success.json',
              width: 200,
              height: 200,
              repeat: false,
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Desafío Completado!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tu progreso ha sido actualizado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}