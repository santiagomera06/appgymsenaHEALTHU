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
    int? toInt(dynamic v) => v == null ? null : int.tryParse('$v');
    num? toNum(dynamic v) => v == null ? null : num.tryParse('$v');

    return EjercicioRutina(
      idEjercicio: toInt(j['idEjercicio'] ?? j['id'] ?? 0) ?? 0,
      nombre: j['nombre']?.toString() ?? 'Ejercicio',
      descripcion: j['descripcion']?.toString(),
      musculos: j['musculos']?.toString(),
      series: toInt(j['series']),
      repeticiones: toInt(j['repeticiones']),
      carga: toNum(j['carga']),
      duracion: toInt(j['duracion']),
      calorias: toInt(j['calorias']),
      orden: toInt(j['orden']),
      tiempoDescanso: toInt(j['tiempoDescanso']),
      asignacion: j['asignacion'] is bool
          ? j['asignacion'] as bool
          : (j['asignacion']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() => {
        'idEjercicio': idEjercicio,
        'nombre': nombre,
        'descripcion': descripcion,
        'musculos': musculos,
        'series': series,
        'repeticiones': repeticiones,
        'carga': carga,
        'duracion': duracion,
        'calorias': calorias,
        'orden': orden,
        'tiempoDescanso': tiempoDescanso,
        'asignacion': asignacion,
      };
}
