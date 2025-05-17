class Desafio {
  final String id;
  final String nombre;
  final String descripcion;
  final bool desbloqueado;
  final bool completado;
  final int puntuacion;
  final List<String> ejerciciosIds;

  Desafio({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    required this.desbloqueado,
    required this.completado,
    this.puntuacion = 0,
    this.ejerciciosIds = const [],
  });

  Desafio copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    bool? desbloqueado,
    bool? completado,
    int? puntuacion,
    List<String>? ejerciciosIds,
  }) {
    return Desafio(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      desbloqueado: desbloqueado ?? this.desbloqueado,
      completado: completado ?? this.completado,
      puntuacion: puntuacion ?? this.puntuacion,
      ejerciciosIds: ejerciciosIds ?? this.ejerciciosIds,
    );
  }
}