class AsignacionRutina {
  final int idAsignacion;
  final int idPersona;
  final int idRutina;
  final String? observaciones;
  final DateTime? fechaAsignacion;
  final DateTime? fechaFinalizacion;
  final String? diasAsignado;

  AsignacionRutina({
    required this.idAsignacion,
    required this.idPersona,
    required this.idRutina,
    this.observaciones,
    this.fechaAsignacion,
    this.fechaFinalizacion,
    this.diasAsignado,
  });

  factory AsignacionRutina.fromJson(Map<String, dynamic> json) {
    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.isEmpty) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    return AsignacionRutina(
      idAsignacion: int.tryParse(json['idAsignacion']?.toString() ?? '') ?? 0,
      idPersona: int.tryParse(json['idPersona']?.toString() ?? '') ?? 0,
      idRutina: int.tryParse(json['idRutina']?.toString() ?? '') ?? 0,
      observaciones: json['observaciones'] as String?,
      fechaAsignacion: _toDate(json['fechaAsignacion']),
      fechaFinalizacion: _toDate(json['fechaFinalizacion']),
      diasAsignado: json['diasAsignado'] as String?,
    );
  }
}
