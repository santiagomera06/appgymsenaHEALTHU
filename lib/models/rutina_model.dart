class RutinaDetalle {
  final String id;
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final String nivel;
  final bool completada;
  final List<EjercicioRutina> ejercicios;

  RutinaDetalle({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.nivel,
    required this.ejercicios,
    this.completada = false,
  });

  factory RutinaDetalle.fromJson(Map<String, dynamic> json) {
    try {
      return RutinaDetalle(
        id: json['identifier']?.toString() ?? json['id']?.toString() ?? '0',
        nombre: json['name'] ?? json['nombre'] ?? 'Rutina sin nombre',
        descripcion: json['description'] ?? json['descripcion'] ?? '',
        imagenUrl: json['imageUrl'] ?? json['imagenUrl'] ?? '',
        nivel: json['level'] ?? json['nivel'] ?? 'Intermedio',
        completada: json['completed'] ?? json['completada'] ?? false,
        ejercicios: (json['practices'] ?? json['ejercicios'] ?? [])
            .map((e) => EjercicioRutina.fromJson(e))
            .toList(),
      );
    } catch (e) {
      throw Exception('Error al crear RutinaDetalle: ${e.toString()}');
    }
  }

  RutinaDetalle copyWith({
    List<EjercicioRutina>? ejercicios,
    bool? completada,
  }) {
    return RutinaDetalle(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      imagenUrl: imagenUrl,
      nivel: nivel,
      ejercicios: ejercicios ?? this.ejercicios,
      completada: completada ?? this.completada,
    );
  }
}

class EjercicioRutina {
  final String id;
  final String nombre;
  final int series;
  final int repeticiones;
  final double? pesoRecomendado;
  final String descripcion;
  final String imagenUrl;
  final int duracionEstimada;
  final bool completado;
  final int? tiempoRealizado;

  EjercicioRutina({
    required this.id,
    required this.nombre,
    required this.series,
    required this.repeticiones,
    this.pesoRecomendado,
    required this.descripcion,
    required this.imagenUrl,
    required this.duracionEstimada,
    this.completado = false,
    this.tiempoRealizado,
  });

  factory EjercicioRutina.fromJson(Map<String, dynamic> json) {
    try {
      return EjercicioRutina(
        id: json['id']?.toString() ?? '0',
        nombre: json['name'] ?? json['nombre'] ?? 'Ejercicio sin nombre',
        series: json['repetition'] ?? json['series'] ?? 3,
        repeticiones: json['target'] ?? json['repeticiones'] ?? 10,
        pesoRecomendado: json['value']?.toDouble() ?? json['pesoRecomendado']?.toDouble(),
        descripcion: json['description'] ?? json['descripcion'] ?? '',
        imagenUrl: json['imageUrl'] ?? json['imagenUrl'] ?? '',
        duracionEstimada: json['timeplacement'] ?? json['duracionEstimada'] ?? 60,
        completado: json['completed'] ?? json['completado'] ?? false,
        tiempoRealizado: json['time']?.toInt() ?? json['tiempoRealizado']?.toInt(),
      );
    } catch (e) {
      throw Exception('Error al crear EjercicioRutina: ${e.toString()}');
    }
  }

  EjercicioRutina copyWith({
    bool? completado,
    int? tiempoRealizado,
    int? series,
    int? repeticiones,
    double? pesoRecomendado,
  }) {
    return EjercicioRutina(
      id: id,
      nombre: nombre,
      series: series ?? this.series,
      repeticiones: repeticiones ?? this.repeticiones,
      pesoRecomendado: pesoRecomendado ?? this.pesoRecomendado,
      descripcion: descripcion,
      imagenUrl: imagenUrl,
      duracionEstimada: duracionEstimada,
      completado: completado ?? this.completado,
      tiempoRealizado: tiempoRealizado ?? this.tiempoRealizado,
    );
  }
}