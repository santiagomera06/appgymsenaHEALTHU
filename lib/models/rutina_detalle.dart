import 'ejercicio_rutina.dart';

class RutinaDetalle {
  final int idRutina;
  final String nombre;
  final String descripcion;
  final String? fotoRutina;
  final String enfoque;       // p. ej. "FULL_BODY"
  final String dificultad;    // p. ej. "Principiante"
  final num? puntajeRutina;
  final List<EjercicioRutina> ejercicios;

  RutinaDetalle({
    required this.idRutina,
    required this.nombre,
    required this.descripcion,
    this.fotoRutina,
    required this.enfoque,
    required this.dificultad,
    this.puntajeRutina,
    required this.ejercicios,
  });

  factory RutinaDetalle.fromJson(Map<String, dynamic> j) {
    int _toInt(dynamic v) => int.tryParse('${v ?? ''}') ?? 0;
    num? _toNum(dynamic v) => (v is num) ? v : num.tryParse('${v ?? ''}');
    String _toStr(dynamic v, [String def = '']) => v?.toString() ?? def;

    // Soporte para estructuras API variadas
    final ejerciciosList = (j['ejercicios'] ??
            j['practices'] ??
            j['rutinaEjercicios'] ??
            [])
        as List;

    return RutinaDetalle(
      idRutina: _toInt(j['idRutina'] ?? j['id'] ?? j['identifier']),
      nombre: _toStr(j['nombre'] ?? j['name'], 'Rutina sin nombre'),
      descripcion: _toStr(j['descripcion'] ?? j['description'], ''),
      fotoRutina: _toStr(j['fotoRutina'] ?? j['imagenUrl'] ?? j['imageUrl']),
      enfoque: _toStr(j['enfoque'] ?? j['focus'] ?? 'General'),
      dificultad: _toStr(j['dificultad'] ?? j['nivel'] ?? j['level'] ?? 'Intermedio'),
      puntajeRutina: _toNum(j['puntajeRutina']),
      ejercicios: ejerciciosList
          .map((e) => EjercicioRutina.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'idRutina': idRutina,
        'nombre': nombre,
        'descripcion': descripcion,
        'fotoRutina': fotoRutina,
        'enfoque': enfoque,
        'dificultad': dificultad,
        'puntajeRutina': puntajeRutina,
        'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
      };
}
