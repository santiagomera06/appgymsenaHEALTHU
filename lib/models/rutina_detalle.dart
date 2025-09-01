// lib/models/rutina_detalle.dart
import 'ejercicio_rutina.dart';

class RutinaDetalle {
  final int idRutina;
  final String? nombre;
  final String? descripcion;
  final String? fotoRutina;
  final String? enfoque;         // p. ej. "FULL_BODY"
  final String? dificultad;      // p. ej. "Principiante"
  final num? puntajeRutina;
  final List<EjercicioRutina> ejercicios;

  RutinaDetalle({
    required this.idRutina,
    this.nombre,
    this.descripcion,
    this.fotoRutina,
    this.enfoque,
    this.dificultad,
    this.puntajeRutina,
    required this.ejercicios,
  });

  factory RutinaDetalle.fromJson(Map<String, dynamic> j) {
    int _toInt(dynamic v) => int.tryParse('${v ?? ''}') ?? 0;
    final list = (j['ejercicios'] as List? ?? [])
        .map((e) => EjercicioRutina.fromJson(e as Map<String, dynamic>))
        .toList();

    return RutinaDetalle(
      idRutina: _toInt(j['idRutina']),
      nombre: j['nombre']?.toString(),
      descripcion: j['descripcion']?.toString(),
      fotoRutina: j['fotoRutina']?.toString(),
      enfoque: j['enfoque']?.toString(),
      dificultad: j['dificultad']?.toString(),
      puntajeRutina: (j['puntajeRutina'] is num) ? j['puntajeRutina'] as num : num.tryParse('${j['puntajeRutina'] ?? ''}'),
      ejercicios: list,
    );
  }
}
