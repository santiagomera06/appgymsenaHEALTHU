class Ejercicio {
  final String id;
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final int duracion; // en segundos
  final int calorias;
  final bool completado;

  Ejercicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.duracion,
    required this.calorias,
    this.completado = false,
  });
}