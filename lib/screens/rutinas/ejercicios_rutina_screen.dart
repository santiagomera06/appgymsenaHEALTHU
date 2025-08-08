import 'package:flutter/material.dart';
import 'package:healthu/services/desafio_service.dart';
import 'package:healthu/widgets/progreso_desafios_card.dart';
import 'package:healthu/screens/rutinas/precalentamiento_screen.dart';
import 'package:healthu/models/rutina_model.dart';

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
      'repeticiones': 30,
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
      body: _cargando
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
          const Icon(Icons.play_circle_outline, size: 100, color: Colors.orange),
          const SizedBox(height: 24),
          Text(widget.nombreRutina, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Ejercicios: ${_ejercicios.length}', style: const TextStyle(fontSize: 18)),
          if (widget.registrosCreados != null) ...[
            const SizedBox(height: 8),
            Text('Registros creados: ${widget.registrosCreados}', style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Iniciar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          LinearProgressIndicator(
            value: (_ejercicioActual + 1) / _ejercicios.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ejercicio['nombre'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(ejercicio['descripcion'], style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Serie', style: TextStyle(color: Colors.grey)),
                          Text('$_serieActual / $totalSeries', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Repeticiones', style: TextStyle(color: Colors.grey)),
                          Text('${ejercicio['repeticiones']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (_ultimoProgreso != null) ...[
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('Series: ${_ultimoProgreso!['seriesRealizadas']}/${_ultimoProgreso!['seriesObjetivo']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    if (_ultimoProgreso!['ejercicioCompletado'] == true)
                      const Text('¡Ejercicio completado!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    if (_ultimoProgreso!['rutinaCompletada'] == true)
                      const Text('¡Rutina completada!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _cargando ? null : _siguienteSerie,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: _cargando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _ultimoProgreso?['rutinaCompletada'] == true ? 'Finalizar Rutina' : 'Siguiente Serie',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final rutina = RutinaDetalle(
      id: widget.idRutina,
      nombre: widget.nombreRutina,
      descripcion: '',
      imagenUrl: '',
      nivel: '',
      ejercicios: [], // Puedes llenarlo si tienes los datos
    );

    if (!mounted) return;

    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => PrecalentamientoScreen(
      rutina: rutina,
      idDesafioRealizado: widget.idDesafio, // ✅ Aquí está el fix
    ),
  ),
);

  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _cargando = false);
  }
}


 Future<void> _siguienteSerie() async {
  setState(() => _cargando = true);
  try {
    final resultado = await DesafioService.actualizarSerie(
      idDesafioRealizado: widget.idDesafio,
      idRutinaEjercicio: _ejercicios[_ejercicioActual]['id'],
    );

    if (!resultado) throw Exception('No se pudo actualizar la serie');

    setState(() {
      if (_serieActual < (_ejercicios[_ejercicioActual]['series'] ?? 1)) {
        _serieActual++;
      } else if (_ejercicioActual < _ejercicios.length - 1) {
        _ejercicioActual++;
        _serieActual = 1;
      } else {
        // Rutina completada
        _rutinaIniciada = false;
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_rutinaIniciada
            ? '✅ Serie completada'
            : '🎉 ¡Rutina completada!'),
        backgroundColor: Colors.green,
      ),
    );

    if (!_rutinaIniciada) await _completarRutina();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar serie: $e'), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _cargando = false);
  }
}


  Future<void> _completarRutina() async {
    try {
      final progreso = await DesafioService.registrarProgreso(
        idRutina: widget.idRutina,
        idDesafioRealizado: widget.idDesafio,
      );

      if (progreso != null && progreso['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 ¡Rutina completada!'), backgroundColor: Colors.green),
        );
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop(true);
      } else {
        throw Exception('No se pudo registrar el progreso');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar progreso: $e'), backgroundColor: Colors.red),
      );
      Navigator.of(context).pop(false);
    }
  }
}
