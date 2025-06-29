import 'package:flutter/material.dart';
import 'package:healthu/models/rutina_model.dart';
import 'package:healthu/widgets/temporizador.dart';

class EjercicioActualScreen extends StatefulWidget {
  final RutinaDetalle rutina;
  final int ejercicioIndex;

  const EjercicioActualScreen({
    super.key,
    required this.rutina,
    required this.ejercicioIndex,
  });

  @override
  State<EjercicioActualScreen> createState() => _EjercicioActualScreenState();
}

class _EjercicioActualScreenState extends State<EjercicioActualScreen> {
  late int _serieActual;
  late bool _ejercicioCompletado;
  bool _temporizadorActivo = false;

  @override
  void initState() {
    super.initState();
    _serieActual = 1;
    _ejercicioCompletado = false;
  }

  EjercicioRutina get _ejercicio => widget.rutina.ejercicios[widget.ejercicioIndex];

  void _iniciarTemporizador() {
    setState(() => _temporizadorActivo = true);
  }

  void _pausarTemporizador() {
    setState(() => _temporizadorActivo = false);
  }

  void _siguienteSerie() {
    if (_serieActual < _ejercicio.series) {
      setState(() {
        _serieActual++;
        _ejercicioCompletado = false;
      });
    } else {
      _siguienteEjercicio();
    }
  }

  void _siguienteEjercicio() {
    if (widget.ejercicioIndex < widget.rutina.ejercicios.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EjercicioActualScreen(
            rutina: widget.rutina,
            ejercicioIndex: widget.ejercicioIndex + 1,
          ),
        ),
      );
    } else {
      // Rutina completada
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Rutina completada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ejercicio ${widget.ejercicioIndex + 1}/${widget.rutina.ejercicios.length}'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagen del ejercicio
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: _ejercicio.imagenUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(_ejercicio.imagenUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[200],
              ),
              child: _ejercicio.imagenUrl.isEmpty
                  ? const Icon(Icons.fitness_center, size: 60)
                  : null,
            ),
            const SizedBox(height: 24),

            // Nombre del ejercicio
            Text(
              _ejercicio.nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Detalles del ejercicio
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('Series completadas', '$_serieActual de ${_ejercicio.series}'),
                    const Divider(),
                    _buildInfoRow('Repeticiones', '${_ejercicio.repeticiones}'),
                    if (_ejercicio.pesoRecomendado != null) ...[
                      const Divider(),
                      _buildInfoRow('Peso recomendado', '${_ejercicio.pesoRecomendado} kg'),
                    ],
                    const Divider(),
                    _buildInfoRow('Duración estimada', '${_ejercicio.duracionEstimada} seg'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Descripción
            if (_ejercicio.descripcion.isNotEmpty) ...[
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _ejercicio.descripcion,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
            ],

            // Temporizador
            if (_temporizadorActivo)
              TemporizadorWidget(
                segundos: _ejercicio.duracionEstimada,
                onComplete: () {
                  setState(() => _ejercicioCompletado = true);
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Botón de temporizador
            Expanded(
              child: ElevatedButton(
                onPressed: _temporizadorActivo ? _pausarTemporizador : _iniciarTemporizador,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _temporizadorActivo ? Colors.orange : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _temporizadorActivo ? 'Pausar' : 'Iniciar Temporizador',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Botón siguiente
            Expanded(
              child: ElevatedButton(
                onPressed: _ejercicioCompletado ? _siguienteSerie : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Siguiente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}