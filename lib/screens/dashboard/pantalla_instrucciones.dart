
import 'package:flutter/material.dart';
import 'pantalla_procesamiento.dart';

class PantallaInstrucciones extends StatelessWidget {
  const PantallaInstrucciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Instrucciones")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📸 Para tomar la foto correctamente:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("1. Asegúrate de que la persona esté completamente visible de pies a cabeza."),
            const Text("2. Debe estar de pie, recta, en posición frontal."),
            const Text("3. Usa un fondo claro y evita objetos que obstruyan el cuerpo."),
            const Text("4. Toma la foto a 2-3 metros de distancia, con buena iluminación."),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaProcesamiento()));
                },
                child: const Text("Tomar o subir foto"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
