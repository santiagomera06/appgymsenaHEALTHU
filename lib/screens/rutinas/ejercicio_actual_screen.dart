  import 'package:flutter/material.dart';
  import 'package:healthu/models/rutina_model.dart';
  import 'package:healthu/services/rutina_service.dart';
  import 'package:healthu/screens/validar_instructor_screen.dart';
  import 'package:healthu/widgets/temporizador.dart';
  import 'package:lottie/lottie.dart';
  import 'package:http/http.dart' as http;
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
    late int _seriesCompletadas;
    late bool _ejercicioCompletado;
    late List<int> _idsRutinaEjercicio;
    final _timerKey = GlobalKey<TemporizadorWidgetState>();
    bool _isUpdating = false;
    bool _rutinaCompletada = false;
    int? _idDesafioRealizado;
    bool _puedeAvanzar = false;

  @override
  void initState() {
    super.initState();
    _seriesCompletadas = 0;
    _ejercicioCompletado = false;

    _idsRutinaEjercicio = widget.rutina.ejercicios
        .map((e) => e.idRutinaEjercicio ?? 0)
        .toList();
  }


    EjercicioRutina get _ejercicio => widget.rutina.ejercicios[widget.ejercicioIndex];

    Future<void> _verificarConexion() async {
      try {
        final response = await http.get(Uri.parse('https://www.google.com'));
        if (response.statusCode != 200) {
          _mostrarErrorSnackbar('Sin conexión a Internet');
        }
      } catch (e) {
        _mostrarErrorSnackbar('Error de conexión');
      }
    }

    void _mostrarErrorSnackbar(String mensaje) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    }

  Future<void> _iniciarRutinaDesafio() async {
    final desafio = await DesafioService.obtenerDesafioActual();
    if (desafio != null) {
      print('📥 Desafío actual: $desafio');

      final idDesafioRealizado = desafio['idDesafioRealizado'];

      if (idDesafioRealizado == null) {
        print('❌ idDesafioRealizado está ausente');
        return;
      }

      setState(() {
        _idDesafioRealizado = idDesafioRealizado;
      });

      // Ahora podemos empezar a registrar el progreso
      await _registrarProgreso();
    }
  }

  Future<void> _registrarProgreso() async {
    if (_idDesafioRealizado != null) {
      final idRutinaEjercicio = widget.rutina.ejercicios[widget.ejercicioIndex].idRutinaEjercicio;

      print('🧩 idDesafioRealizado: $_idDesafioRealizado');
      print('🏋️ idRutinaEjercicio: $idRutinaEjercicio');

      if (idRutinaEjercicio != null) {
        final resultado = await DesafioService.actualizarSerie(
          idDesafioRealizado: _idDesafioRealizado!,
          idRutinaEjercicio: idRutinaEjercicio,
        );

        if (resultado) {
          print('✅ Progreso actualizado');
        } else {
          print('❌ Error al actualizar progreso');
        }
      }
    }
  }


  Future<void> _siguienteEjercicio() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      if (_idDesafioRealizado != null) {
        final idRutinaEjercicio = widget.rutina.ejercicios[widget.ejercicioIndex].idRutinaEjercicio;

        print('🧩 idDesafioRealizado: $_idDesafioRealizado');
        print('🏋️ idRutinaEjercicio: $idRutinaEjercicio');

        if (idRutinaEjercicio == null) {
          _mostrarErrorSnackbar('Error: idRutinaEjercicio es nulo');
          return;
        }
  print('✅ IDs para enviar:');
  print('idDesafioRealizado: $_idDesafioRealizado');
  print('idRutinaEjercicio: $idRutinaEjercicio');
        final resultado = await DesafioService.actualizarSerie(
          idDesafioRealizado: _idDesafioRealizado!,
          idRutinaEjercicio: idRutinaEjercicio,
        );

        if (resultado == false) {
          _mostrarErrorSnackbar('No se pudo actualizar la serie del desafío');
          return;
        }
      }

      // ✅ 2. Registrar serie local de rutina
      final serieRegistrada = await RutinaService.registrarSerieCompletada(
        idEjercicio: _ejercicio.id,
        idRutina: widget.rutina.id,
      );

      if (!serieRegistrada) {
        _mostrarErrorSnackbar('No se pudo registrar la serie completada');
        return;
      }

      setState(() {
        _seriesCompletadas++;
        _ejercicioCompletado = _seriesCompletadas >= _ejercicio.series;
      });

      if (!_ejercicioCompletado) {
        _timerKey.currentState?.reset();
        setState(() {
          _puedeAvanzar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Serie $_seriesCompletadas/${_ejercicio.series} completada'),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      final progresoRegistrado = await RutinaService.registrarProgresoEjercicio(
        idRutina: widget.rutina.id,
        idEjercicio: _ejercicio.id,
      );

      if (!progresoRegistrado) {
        _mostrarErrorSnackbar('No se pudo registrar el progreso del ejercicio');
        return;
      }

      final ejercicioActualizado = _ejercicio.copyWith(
        completado: true,
        tiempoRealizado: _timerKey.currentState?.tiempoTranscurrido,
      );

    final rutinaActualizada = widget.rutina.copyWith(
    ejercicios: List<EjercicioRutina>.from(widget.rutina.ejercicios)
      ..[widget.ejercicioIndex] = _ejercicio.copyWith(completado: true),
  );


      if (widget.ejercicioIndex < widget.rutina.ejercicios.length - 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EjercicioActualScreen(
              rutina: rutinaActualizada,
              ejercicioIndex: widget.ejercicioIndex + 1,
              idDesafioRealizado: widget.idDesafioRealizado,
            ),
          ),
        );
      } else {
        await _marcarRutinaCompletada();
        await _mostrarDialogoCompletado(rutinaActualizada);
      }
    } catch (e) {
      _mostrarErrorSnackbar('Error: $e');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }


    Future<void> _marcarRutinaCompletada() async {
      try {
        final ejercicioActualizado = _ejercicio.copyWith(
          completado: true,
          tiempoRealizado: _timerKey.currentState?.tiempoTranscurrido,
        );

        final ejerciciosActualizados = List<EjercicioRutina>.from(widget.rutina.ejercicios)
          ..[widget.ejercicioIndex] = ejercicioActualizado;

        await RutinaService.actualizarRutina(
          widget.rutina.id.toString(),
          {
            "completada": true,
            "ejercicios": ejerciciosActualizados.map((e) => {
                  'id': e.id,
                  'completed': e.completado,
                  'time': e.tiempoRealizado,
                }).toList(),
          },
        );

        if (mounted) setState(() => _rutinaCompletada = true);
      } catch (e) {
        _mostrarErrorSnackbar('Error al finalizar rutina');
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Has finalizado todos los ejercicios de la rutina.'),
              const SizedBox(height: 16),
              Lottie.asset('assets/animations/success.json', width: 150, height: 150, repeat: false),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ValidarInstructorScreen(rutinaId: rutina.id.toString()),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code),
                label: const Text('Validar con instructor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Cerrar'),
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
                value: _seriesCompletadas / _ejercicio.series,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              Text('Progreso: $_seriesCompletadas/${_ejercicio.series} series', style: const TextStyle(fontSize: 16)),
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
    segundos: 3,
    onComplete: () {
      setState(() {
        _puedeAvanzar = true;
      });
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