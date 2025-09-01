
class EjercicioRutina {
  final int idEjercicio;
  final String nombre;
  final String? descripcion;
  final String? musculos;
  final int? series;
  final int? repeticiones;
  final num? carga;
  final int? duracion;
  final int? calorias;
  final int? orden;
  final int? tiempoDescanso; 
  final bool? asignacion;

  EjercicioRutina({
    required this.idEjercicio,
    required this.nombre,
    this.descripcion,
    this.musculos,
    this.series,
    this.repeticiones,
    this.carga,
    this.duracion,
    this.calorias,
    this.orden,
    this.tiempoDescanso,
    this.asignacion,
  });

  factory EjercicioRutina.fromJson(Map<String, dynamic> j) {
    int? _toInt(dynamic v) => v == null ? null : int.tryParse('$v');
    num? _toNum(dynamic v) => v == null ? null : num.tryParse('$v');

    return EjercicioRutina(
      idEjercicio: _toInt(j['idEjercicio'] ?? j['id'] ?? 0) ?? 0,
      nombre: j['nombre']?.toString() ?? 'Ejercicio',
      descripcion: j['descripcion']?.toString(),
      musculos: j['musculos']?.toString(),
      series: _toInt(j['series']),
      repeticiones: _toInt(j['repeticiones']),
      carga: _toNum(j['carga']),
      duracion: _toInt(j['duracion']),
      calorias: _toInt(j['calorias']),
      orden: _toInt(j['orden']),
      tiempoDescanso: _toInt(j['tiempoDescanso']),
      asignacion: j['asignacion'] is bool ? j['asignacion'] as bool : (j['asignacion']?.toString().toLowerCase() == 'true'),
    );
  }
}
