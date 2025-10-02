class Usuario {
 final int id;        
  final String nombre;
  final String email;
  final String fotoUrl;
  final String nivelActual; 

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.fotoUrl,
    required this.nivelActual,
  });

  /// 🔹 Método copyWith para clonar el objeto cambiando solo lo necesario
Usuario copyWith({
  int? id,                // 👈 corregido a int
  String? nombre,
  String? email,
  String? fotoUrl,
  String? nivelActual,
}) {
  return Usuario(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    email: email ?? this.email,
    fotoUrl: fotoUrl ?? this.fotoUrl,
    nivelActual: nivelActual ?? this.nivelActual,
  );
}

}
