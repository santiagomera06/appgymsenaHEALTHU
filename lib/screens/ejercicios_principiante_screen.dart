import 'package:flutter/material.dart';
import 'package:healthu/models/desafio_model.dart';
import 'package:healthu/models/ejercicio_model.dart';
import 'package:healthu/styles/ejercicios_styles.dart';
import 'package:healthu/widgets/ejercicio_card.dart';

class EjerciciosPrincipianteScreen extends StatefulWidget {
  final String nombreDesafio;
  final Desafio desafio;
  final VoidCallback? onCompletado;
  
  const EjerciciosPrincipianteScreen({
    super.key,
    required this.nombreDesafio,
    required this.desafio,
    this.onCompletado,
  });

  @override
  State<EjerciciosPrincipianteScreen> createState() => _EjerciciosPrincipianteScreenState();
}

class _EjerciciosPrincipianteScreenState extends State<EjerciciosPrincipianteScreen> {
  List<Ejercicio> ejercicios = [];
  bool todosCompletados = false;

  @override
  void initState() {
    super.initState();
    _cargarEjercicios();
  }

  void _cargarEjercicios() {
    // Esto debería venir de una fuente de datos real
    final ejerciciosBase = [
      Ejercicio(
        id: '1',
        nombre: 'Sentadillas',
        descripcion: 'Ejercicio básico para piernas y glúteos',
        imagenUrl: '',
        duracion: 30,
        calorias: 50,
      ),
      Ejercicio(
        id: '2',
        nombre: 'Flexiones',
        descripcion: 'Fortalece brazos y pecho',
        imagenUrl: '',
        duracion: 45,
        calorias: 70,
      ),
      Ejercicio(
        id: '3',
        nombre: 'Abdominales',
        descripcion: 'Trabaja los músculos del core',
        imagenUrl: '',
        duracion: 40,
        calorias: 60,
      ),
    ];

    setState(() {
      ejercicios = ejerciciosBase;
    });
  }

  void _marcarEjercicioCompletado(String ejercicioId) {
    setState(() {
      final index = ejercicios.indexWhere((e) => e.id == ejercicioId);
      if (index != -1) {
        ejercicios[index] = Ejercicio(
          id: ejercicios[index].id,
          nombre: ejercicios[index].nombre,
          descripcion: ejercicios[index].descripcion,
          imagenUrl: ejercicios[index].imagenUrl,
          duracion: ejercicios[index].duracion,
          calorias: ejercicios[index].calorias,
          completado: true,
        );
      }

      // Verificar si todos los ejercicios están completados
      todosCompletados = ejercicios.every((e) => e.completado);
    });
  }

  void _completarDesafio() {
    if (!todosCompletados) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Completa todos los ejercicios primero!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.onCompletado != null) {
      widget.onCompletado!();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreDesafio),
        backgroundColor: EjerciciosStyles.colorPrimario,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rutina de Principiante',
              style: EjerciciosStyles.titulo,
            ),
            const SizedBox(height: 8),
            Text(
              widget.desafio.descripcion.isNotEmpty 
                  ? widget.desafio.descripcion 
                  : 'Completa estos ejercicios para avanzar en tu desafío',
              style: EjerciciosStyles.subtitulo,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: ejercicios.length,
                itemBuilder: (context, index) {
                  return EjercicioCard(
                    ejercicio: ejercicios[index],
                    onTap: () {
                      _marcarEjercicioCompletado(ejercicios[index].id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ejercicio ${ejercicios[index].nombre} completado'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (todosCompletados)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '¡Todos los ejercicios completados!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _completarDesafio,
        backgroundColor: EjerciciosStyles.colorPrimario,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}