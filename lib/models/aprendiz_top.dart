class AprendizTop {
  final String nombre;
  final int puntos;
  final String nivel;

  AprendizTop({
    required this.nombre,
    required this.puntos,
    required this.nivel,
  });

  factory AprendizTop.fromJson(Map<String, dynamic> json) => AprendizTop(
        nombre: json['nombre'] ?? '',
        puntos: json['puntos'] ?? 0,
        nivel: json['nivel'] ?? '',
      );
}
