 import 'package:flutter/material.dart';
  import 'package:healthu/models/rutina_model.dart';
  import 'package:healthu/services/rutina_service.dart';
  import 'package:healthu/screens/validar_instructor_screen.dart';
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
    final _timerKey = GlobalKey<TemporizadorWidgetState>();

    @override
    void initState() {
      super.initState();
      _serieActual = 1;
      _ejercicioCompletado = false;
    }

    EjercicioRutina get _ejercicio => widget.rutina.ejercicios[widget.ejercicioIndex];

    Future<void> _marcarRutinaCompletada() async {
      // Cambiar estado en la base de datos
      await RutinaService.completarRutina(widget.rutina.id);
    }

    void _siguienteSerie() {
      if (_serieActual < _ejercicio.series) {
        setState(() {
          _serieActual++;
          _ejercicioCompletado = false;
        });
        _timerKey.currentState?.reset();
      } else {
        _siguienteEjercicio();
      }
    }

    Future<void> _siguienteEjercicio() async {
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
        // Último ejercicio completado
        await _marcarRutinaCompletada();
        // Mostrar confirmación final con opción de validar
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.emoji_events, color: Colors.orange),
                SizedBox(width: 8),
                Text('¡Rutina completada!'),
              ],
            ),
            content: const Text('Has finalizado todos los ejercicios de la rutina.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ValidarInstructorScreen(rutinaId: widget.rutina.id),
                    ),
                  );
                },
                child: const Text('Validar con instructor'),
              ),
            ],
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Progreso de series
              LinearProgressIndicator(
                value: _serieActual / _ejercicio.series,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: Colors.green[800],
              ),
              const SizedBox(height: 8),
              Text('Serie $_serieActual de ${_ejercicio.series}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              // Detalles del ejercicio
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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
                const Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_ejercicio.descripcion, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
              ],

              // Temporizador
              TemporizadorWidget(
                key: _timerKey,
                //segundos: _ejercicio.duracionEstimada,
                segundos:1,
                onComplete: () {
                  setState(() => _ejercicioCompletado = true);
                  if (_serieActual < _ejercicio.series) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Serie completada'),
                        content: Text('Has completado $_serieActual de ${_ejercicio.series} series.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _timerKey.currentState?.pause();
                              _siguienteSerie();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Future.delayed(const Duration(milliseconds: 500), _siguienteEjercicio);
                  }
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _timerKey.currentState?.isRunning == true
                      ? _timerKey.currentState?.pause
                      : _timerKey.currentState?.start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _timerKey.currentState?.isRunning == true ? Colors.orange : Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_timerKey.currentState?.isRunning == true ? 'Pausar' : 'Iniciar Temporizador', style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _ejercicioCompletado ? _siguienteSerie : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Siguiente', style: TextStyle(color: Colors.white)),
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
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
  }