class RutinaDetalle {
  final int id;
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
        id: int.tryParse(json['identifier']?.toString() ?? json['id']?.toString() ?? '') ?? 0,
        nombre: json['name'] ?? json['nombre'] ?? 'Rutina sin nombre',
        descripcion: json['description'] ?? json['descripcion'] ?? '',
        imagenUrl: json['imageUrl'] ?? json['imagenUrl'] ?? '',
        nivel: json['level'] ?? json['nivel'] ?? 'Intermedio',
        completada: json['completed'] ?? json['completada'] ?? false,
        ejercicios: (json['practices'] ?? json['ejercicios'] ?? [])
            .map<EjercicioRutina>((e) => EjercicioRutina.fromJson(e))
            .toList(),
      );
    } catch (e) {
      throw Exception('Error al crear RutinaDetalle: ${e.toString()}');
    }
  }

  RutinaDetalle copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? imagenUrl,
    String? nivel,
    bool? completada,
    List<EjercicioRutina>? ejercicios,
  }) {
    return RutinaDetalle(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      nivel: nivel ?? this.nivel,
      completada: completada ?? this.completada,
      ejercicios: ejercicios ?? this.ejercicios,
    );
  }
}

class EjercicioRutina {
  final int id;
  final String nombre;
  final int series;
  final int repeticiones;
  final double? pesoRecomendado;
  final String descripcion;
  final String imagenUrl;
  final int duracionEstimada;
  final bool completado;
  final int? tiempoRealizado;

   final int? idRutinaEjercicio;

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
     this.idRutinaEjercicio,
  });

  factory EjercicioRutina.fromJson(Map<String, dynamic> json) {
    try {
      return EjercicioRutina(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        nombre: json['name'] ?? json['nombre'] ?? 'Ejercicio sin nombre',
        series: json['repetition'] ?? json['series'] ?? 3,
        repeticiones: json['target'] ?? json['repeticiones'] ?? 10,
        pesoRecomendado: (json['value'] ?? json['pesoRecomendado'])?.toDouble(),
        descripcion: json['description'] ?? json['descripcion'] ?? '',
        imagenUrl: json['imageUrl'] ?? json['imagenUrl'] ?? '',
        duracionEstimada: json['timeplacement'] ?? json['duracionEstimada'] ?? 60,
        completado: json['completed'] ?? json['completado'] ?? false,
        tiempoRealizado: json['time'] ?? json['tiempoRealizado'],
         idRutinaEjercicio: json['idRutinaEjercicio'],
      );
    } catch (e) {
      throw Exception('Error al crear EjercicioRutina: ${e.toString()}');
    }
  }

  EjercicioRutina copyWith({
    int? id,
    String? nombre,
    int? series,
    int? repeticiones,
    double? pesoRecomendado,
    String? descripcion,
    String? imagenUrl,
    int? duracionEstimada,
    bool? completado,
    int? tiempoRealizado,
    int? idRutinaEjercicio, 
  }) {
    return EjercicioRutina(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      series: series ?? this.series,
      repeticiones: repeticiones ?? this.repeticiones,
      pesoRecomendado: pesoRecomendado ?? this.pesoRecomendado,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      duracionEstimada: duracionEstimada ?? this.duracionEstimada,
      completado: completado ?? this.completado,
      tiempoRealizado: tiempoRealizado ?? this.tiempoRealizado,
      idRutinaEjercicio: idRutinaEjercicio ?? this.idRutinaEjercicio,
    );
  }
}
