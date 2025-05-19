// lib/models/usuario.dart

/// Modelo que representa un usuario en la aplicación
class Usuario {
  /// Identificador único (cédula)
  final String id;

  /// Nombre completo del usuario
  final String nombre;

  /// Correo electrónico del usuario
  final String email;

  /// URL de la foto de perfil
  final String fotoUrl;

  /// Constructor
  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.fotoUrl,
  });
}
