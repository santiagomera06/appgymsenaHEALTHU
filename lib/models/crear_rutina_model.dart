class Rutina {
  final String nombre;
  final String descripcion;
  final String fotoRutina;
  final String enfoque;
  final String dificultad;
  final List<EjercicioRutina> ejercicios;

  Rutina({
    required this.nombre,
    required this.descripcion,
    String? fotoRutina,
    required this.enfoque,
    required this.dificultad,
    required this.ejercicios,
  }) : fotoRutina = fotoRutina ?? 'https://via.placeholder.com/150';  


  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'fotoRutina': fotoRutina,
      'enfoque': enfoque.toUpperCase(),
      'dificultad': dificultad.toUpperCase(),
      'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
    };
  }
}

class EjercicioRutina {
  final int idEjercicio;
  final int series;
  final int repeticion;
  final int carga;
  final int duracion;

  EjercicioRutina({
    required this.idEjercicio,
    required this.series,
    required this.repeticion,
    required this.carga,
    required this.duracion,
  });

  Map<String, dynamic> toJson() {
    return {
      'idEjercicio': idEjercicio,
      'series': series,
      'repeticion': repeticion,
      'carga': carga,
      'duración': duracion,
    };
  }
}