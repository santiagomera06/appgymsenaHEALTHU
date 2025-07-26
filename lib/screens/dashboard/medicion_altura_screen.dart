import 'dart:math';
import 'package:flutter/material.dart';

class MedicionAlturaScreen extends StatefulWidget {
  const MedicionAlturaScreen({super.key});

  @override
  State<MedicionAlturaScreen> createState() => _MedicionAlturaScreenState();
}

class _MedicionAlturaScreenState extends State<MedicionAlturaScreen> {
  double? altura;
  final Random random = Random();

  void calcularAltura() {
    setState(() {
      altura = 150 + random.nextInt(40) + random.nextDouble(); // entre 150 y 190 cm
    });
  }

  @override
  void initState() {
    super.initState();
    calcularAltura();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado de la Medición'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: altura == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tu altura estimada es:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${altura!.toStringAsFixed(1)} cm',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver al dashboard'),
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
