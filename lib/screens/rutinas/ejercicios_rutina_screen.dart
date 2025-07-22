import 'package:flutter/material.dart';
import 'package:healthu/services/desafio_service.dart';
import 'package:healthu/widgets/progreso_desafios_card.dart';

class EjerciciosRutinaScreen extends StatefulWidget {
  final int idDesafio;
  final int idRutina;
  final String nombreRutina;
  final int? registrosCreados;

  const EjerciciosRutinaScreen({
    super.key,
    required this.idDesafio,
    required this.idRutina,
    required this.nombreRutina,
    this.registrosCreados,
  });

  @override
  State<EjerciciosRutinaScreen> createState() => _EjerciciosRutinaScreenState();
}

class _EjerciciosRutinaScreenState extends State<EjerciciosRutinaScreen> {
  bool _rutinaIniciada = false;
  bool _cargando = false;
  int _ejercicioActual = 0;
  int _serieActual = 1;
  Map<String, dynamic>? _ultimoProgreso;

  // Datos simulados de ejercicios (reemplazar con datos reales de la API)
  final List<Map<String, dynamic>> _ejercicios = [
    {
      'id': 1,
      'nombre': 'Flexiones',
      'series': 3,
      'repeticiones': 15,
      'descripcion': 'Flexiones de brazos clásicas',
    },
    {
      'id': 2,
      'nombre': 'Sentadillas',
      'series': 3,
      'repeticiones': 20,
      'descripcion': 'Sentadillas profundas',
    },
    {
      'id': 3,
      'nombre': 'Plancha',
      'series': 3,
      'repeticiones': 30, // segundos
      'descripcion': 'Mantener posición de plancha',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreRutina),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : !_rutinaIniciada
              ? _buildPantallaInicial()
              : _buildPantallaEjercicios(),
    );
  }

  Widget _buildPantallaInicial() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.play_circle_outline,
            size: 100,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            widget.nombreRutina,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Ejercicios: ${_ejercicios.length}',
            style: const TextStyle(fontSize: 18),
          ),
          if (widget.registrosCreados != null) ...[
            const SizedBox(height: 8),
            Text(
              'Registros creados: ${widget.registrosCreados}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _iniciarEjercicios,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Iniciar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPantallaEjercicios() {
    final ejercicio = _ejercicios[_ejercicioActual];
    final totalSeries = ejercicio['series'] as int;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progreso
          LinearProgressIndicator(
            value: (_ejercicioActual + 1) / _ejercicios.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          const SizedBox(height: 16),

          // Información del ejercicio
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ejercicio['nombre'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ejercicio['descripcion'],
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Serie',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '$_serieActual / $totalSeries',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Repeticiones',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${ejercicio['repeticiones']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Información del último progreso
          if (_ultimoProgreso != null) ...[
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      'Series: ${_ultimoProgreso!['seriesRealizadas']}/${_ultimoProgreso!['seriesObjetivo']}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (_ultimoProgreso!['ejercicioCompletado'] == true)
                      const Text(
                        '¡Ejercicio completado!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_ultimoProgreso!['rutinaCompletada'] == true)
                      const Text(
                        '¡Rutina completada!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Botón de acción
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _cargando ? null : _siguienteSerie,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child:
                  _cargando
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        _ultimoProgreso?['rutinaCompletada'] == true
                            ? 'Finalizar Rutina'
                            : 'Siguiente Serie',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _iniciarEjercicios() async {
    setState(() => _cargando = true);

    try {
      final desafioActual = await DesafioService.obtenerDesafioActual();

      Map<String, dynamic>? patchResponse;

      if (desafioActual != null) {
        var idParaPatch = widget.idDesafio;
        if (desafioActual['idDesafioRealiado'] != null) {
          idParaPatch = desafioActual['idDesafioRealiado'];
          print('USANDO idDesafioRealiado: $idParaPatch');
        } else {
          print('USANDO widget.idDesafio (fallback): $idParaPatch');
        }

        patchResponse = await DesafioService.iniciarRutinaDesafio(idParaPatch);
      } else {
        print('No se pudo obtener desafío actual, usando widget.idDesafio');

        patchResponse = await DesafioService.iniciarRutinaDesafio(
          widget.idDesafio,
        );
      }

      final rutinaIniciada = patchResponse != null;

      if (rutinaIniciada) {
        setState(() {
          _rutinaIniciada = true;
          _cargando = false;
        });

        print('Intentando refrescar datos del dashboard...');
        try {
          await Future.delayed(const Duration(milliseconds: 800));
          await DesafioService.obtenerDesafioActual();
          await ProgresoDesafiosCard.refrescarGlobal();
        } catch (reloadError) {
          print(' Error al recargar datos del dashboard: $reloadError');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Rutina iniciada! Comenzando ejercicios...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception(
          'El servidor no pudo iniciar la rutina. Verifica que el desafío exista y esté activo.',
        );
      }
    } catch (e) {
      print('Error al iniciar rutina: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar rutina: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: _iniciarEjercicios,
            ),
          ),
        );
      }

      setState(() => _cargando = false);
    }
  }

  Future<void> _siguienteSerie() async {
    if (_ultimoProgreso?['rutinaCompletada'] == true) {
      await _completarRutina();
      return;
    }

    setState(() => _cargando = true);

    try {
      // Llamar al endpoint de actualizar serie
      final progreso = await DesafioService.actualizarSerie(
        idDesafioRealizado: widget.idDesafio,
        idRutinaEjercicio: _ejercicios[_ejercicioActual]['id'],
      );

      if (progreso != null) {
        setState(() {
          _ultimoProgreso = progreso;

          // Si el ejercicio está completado, pasar al siguiente
          if (progreso['ejercicioCompletado'] == true &&
              _ejercicioActual < _ejercicios.length - 1) {
            _ejercicioActual++;
            _serieActual = 1;
          } else if (progreso['ejercicioCompletado'] != true) {
            // Incrementar serie actual
            _serieActual++;
          }
        });

        // Mostrar mensaje de progreso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                progreso['rutinaCompletada'] == true
                    ? '¡Rutina completada!'
                    : progreso['ejercicioCompletado'] == true
                    ? '¡Ejercicio completado!'
                    : 'Serie completada: ${progreso['seriesRealizadas']}/${progreso['seriesObjetivo']}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (progreso['rutinaCompletada'] == true) {
          await _completarRutina();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar serie: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _completarRutina() async {
    try {
      print(
        '🎉 Completando rutina ${widget.idRutina} del desafío ${widget.idDesafio}...',
      );

      final progreso = await DesafioService.registrarProgreso(
        idRutina: widget.idRutina,
        idDesafioRealizado: widget.idDesafio,
      );

      if (progreso != null && progreso['success'] == true) {
        print(' Progreso registrado exitosamente');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 ¡Rutina completada y progreso guardado!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          await Future.delayed(const Duration(seconds: 2));

          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('No se pudo registrar el progreso');
      }
    } catch (e) {
      print(' Error al completar rutina: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar progreso: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.of(context).pop(false);
      }
    }
  }
}
