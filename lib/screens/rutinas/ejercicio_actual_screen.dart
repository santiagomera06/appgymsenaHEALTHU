  import 'package:flutter/material.dart';
  import 'package:healthu/models/rutina_model.dart';
  import 'package:healthu/screens/validar_instructor_screen.dart';
  import 'package:healthu/widgets/temporizador.dart';
  import 'package:healthu/services/desafio_service.dart';

  class EjercicioActualScreen extends StatefulWidget {
    final RutinaDetalle rutina;
    final int ejercicioIndex;
    final int idDesafioRealizado; 

    const EjercicioActualScreen({
      super.key,
      required this.rutina,
      required this.ejercicioIndex,
      required this.idDesafioRealizado, 
    });

    @override
    State<EjercicioActualScreen> createState() => _EjercicioActualScreenState();
  }

  class _EjercicioActualScreenState extends State<EjercicioActualScreen> {
    late List<int> _seriesHechas; 

    late bool _ejercicioCompletado;
    final _timerKey = GlobalKey<TemporizadorWidgetState>();
    bool _isUpdating = false;
    bool _puedeAvanzar = false;

  @override
  void initState() {
    super.initState();
    _ejercicioCompletado = false;
    _seriesHechas = List<int>.filled(widget.rutina.ejercicios.length, 0);
  }


    EjercicioRutina get _ejercicio => widget.rutina.ejercicios[widget.ejercicioIndex];

    void _mostrarErrorSnackbar(String mensaje) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    }

Future<void> _siguienteEjercicio() async {
  if (_isUpdating || _puedeAvanzar != true) return;
  setState(() {
    _isUpdating = true;
    _puedeAvanzar = false; 
  });

  try {
    final idx = widget.ejercicioIndex;
    final ej = widget.rutina.ejercicios[idx];
    final objetivo = (ej.series <= 0) ? 1 : ej.series;

    final int? idRutinaEjercicio = ej.idRutinaEjercicio; 
    if (idRutinaEjercicio == null) {
      _mostrarErrorSnackbar(
        'No se encontró idRutinaEjercicio para este ejercicio. '
        'Regresa y vuelve a iniciar la rutina.',
      );
      return;
    }

    await DesafioService.actualizarSerie(
      idDesafioRealizado: widget.idDesafioRealizado,
      idRutinaEjercicio: idRutinaEjercicio,
    );
    final nuevasHechas = (_seriesHechas[idx] + 1).clamp(0, objetivo);
    setState(() {
      _seriesHechas[idx] = nuevasHechas;
      _ejercicioCompletado = nuevasHechas >= objetivo;
    });

    // si ¿Aún faltan series?  NO AVANZA DE EJERCICIO
    if (!_ejercicioCompletado) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Serie ${_seriesHechas[idx]}/$objetivo completada. '
              'Inicia el temporizador para la siguiente serie.'),
          duration: const Duration(seconds: 2),
        ),
      );
      _timerKey.currentState?.reset();   
      return;
    }

    // —— Ejercicio COMPLETO (todas las series)
    final total = widget.rutina.ejercicios.length;
    final idxHumano = idx + 1;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Bien! Completaste el ejercicio $idxHumano de $total.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final bool haySiguiente = idx < total - 1;
    if (haySiguiente) {
      _timerKey.currentState?.reset(); 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EjercicioActualScreen(
            rutina: widget.rutina,
            ejercicioIndex: idx + 1,
            idDesafioRealizado: widget.idDesafioRealizado,
          ),
        ),
      );
    } else {
     
      await _mostrarDialogoCompletado(widget.rutina);
      if (!mounted) return;
      _timerKey.currentState?.reset();
      Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => ValidarInstructorScreen(
      rutinaId: widget.rutina.id.toString(),
      idDesafioRealizado: widget.idDesafioRealizado,
    ),
  ),
);

    }
  } catch (e) {
    _mostrarErrorSnackbar('Error al actualizar serie: $e');
  } finally {
    if (mounted) setState(() => _isUpdating = false);
  }
}


Future<void> _mostrarDialogoCompletado(RutinaDetalle rutina) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.orange),
          SizedBox(width: 8),
          Text('¡Rutina completada!'),
        ],
      ),
      content: const Text(
        'Has finalizado todos los ejercicios. Ahora debes validarla con el instructor.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Continuar'),
        ),
      ],
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

    @override
    Widget build(BuildContext context) {
      final int hechas = _seriesHechas[widget.ejercicioIndex];
  final int objetivo = (_ejercicio.series <= 0) ? 1 : _ejercicio.series;
      return Scaffold(
  
        appBar: AppBar(
          title: Text('Ejercicio ${widget.ejercicioIndex + 1}/${widget.rutina.ejercicios.length}'),
          backgroundColor: Colors.green[800],
          actions: [
            if (_isUpdating)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: _ejercicio.imagenUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(_ejercicio.imagenUrl), fit: BoxFit.cover)
                      : null,
                  color: Colors.grey[200],
                ),
                child: _ejercicio.imagenUrl.isEmpty
                    ? const Icon(Icons.fitness_center, size: 60)
                    : null,
              ),
              const SizedBox(height: 24),
              Text(_ejercicio.nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
             LinearProgressIndicator(
  value: (objetivo == 0) ? 0 : (hechas / objetivo),
  minHeight: 10,
  backgroundColor: Colors.grey[300],
  color: Colors.green,
),
const SizedBox(height: 8),
Text('Progreso: $hechas/$objetivo series', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
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
                      if (_timerKey.currentState?.tiempoTranscurrido != null) ...[
                        const Divider(),
                        _buildInfoRow('Tiempo realizado', '${_timerKey.currentState!.tiempoTranscurrido} seg'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_ejercicio.descripcion.isNotEmpty) ...[
                const Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_ejercicio.descripcion, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
              ],
            TemporizadorWidget(
            key: _timerKey,
            segundos: _ejercicio.duracionEstimada,
            onComplete: () {
             setState(() { _puedeAvanzar = true; });
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
                  child: Text(
                    _timerKey.currentState?.isRunning == true ? 'Pausar' : 'Iniciar Temporizador',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_isUpdating || !_puedeAvanzar) ? null : _siguienteEjercicio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Siguiente', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }