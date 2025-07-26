import 'package:flutter/material.dart';

class PantallaProcesamiento extends StatefulWidget {
  const PantallaProcesamiento({super.key});

  @override
  State<PantallaProcesamiento> createState() => _PantallaProcesamientoState();
}

class _PantallaProcesamientoState extends State<PantallaProcesamiento> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/medicion-altura');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 24),
            Text(
              'Procesando altura...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
