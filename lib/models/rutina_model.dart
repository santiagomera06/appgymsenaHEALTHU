class RutinaDetalle {
  final String id;
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final String nivel;
  final List<EjercicioRutina> ejercicios;

  RutinaDetalle({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.nivel,
    required this.ejercicios,
  });

  factory RutinaDetalle.fromJson(Map<String, dynamic> json) {
    return RutinaDetalle(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      imagenUrl: json['imagenUrl'],
      nivel: json['nivel'],
      ejercicios: (json['ejercicios'] as List)
          .map((e) => EjercicioRutina.fromJson(e))
          .toList(),
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
  final int duracionEstimada; // en segundos

  EjercicioRutina({
    required this.id,
    required this.nombre,
    required this.series,
    required this.repeticiones,
    this.pesoRecomendado,
    required this.descripcion,
    required this.imagenUrl,
    required this.duracionEstimada,
  });

  factory EjercicioRutina.fromJson(Map<String, dynamic> json) {
    return EjercicioRutina(
      id: json['id'],
      nombre: json['nombre'],
      series: json['series'],
      repeticiones: json['repeticiones'],
      pesoRecomendado: json['pesoRecomendado'],
      descripcion: json['descripcion'],
      imagenUrl: json['imagenUrl'],
      duracionEstimada: json['duracionEstimada'],
    );
  }
}