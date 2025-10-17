class AsignacionRutina {
  final int idAsignacion;
  final int idPersona;
  final int idRutina;
  final String? nombreRutina;
  final String? nombreAprendiz;
  final int? ficha;
  final String? nivelFisico;
  final String observaciones;
  final DateTime? fechaAsignacion;
  final DateTime? fechaFinalizacion;
  final String diasAsignado;

  AsignacionRutina({
    required this.idAsignacion,
    required this.idPersona,
    required this.idRutina,
    this.nombreRutina,
    this.nombreAprendiz,
    this.ficha,
    this.nivelFisico,
    required this.observaciones,
    this.fechaAsignacion,
    this.fechaFinalizacion,
    required this.diasAsignado,
  });

  factory AsignacionRutina.fromJson(Map<String, dynamic> json) {
    return AsignacionRutina(
      idAsignacion: json['idAsignacion'] ?? 0,
      idPersona: json['idPersona'] ?? 0,
      idRutina: json['idRutina'] ?? 0,
      nombreRutina: json['nombreRutina'] ?? json['rutinaNombre'] ?? '',
      nombreAprendiz: json['nombreAprendiz'] ?? '',
      ficha: json['ficha'] ?? 0,
      nivelFisico: json['nivelFisico'] ?? '',
      observaciones: json['observaciones'] ?? json['obsevaciones'] ?? '',
      fechaAsignacion: json['fechaAsignacion'] != null
          ? DateTime.tryParse(json['fechaAsignacion'])
          : null,
      fechaFinalizacion: json['fechaFinalizacion'] != null
          ? DateTime.tryParse(json['fechaFinalizacion'])
          : null,
      diasAsignado: json['diasAsignado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'idAsignacion': idAsignacion,
        'idPersona': idPersona,
        'idRutina': idRutina,
        'nombreRutina': nombreRutina,
        'nombreAprendiz': nombreAprendiz,
        'ficha': ficha,
        'nivelFisico': nivelFisico,
        'observaciones': observaciones,
        'fechaAsignacion': fechaAsignacion?.toIso8601String(),
        'fechaFinalizacion': fechaFinalizacion?.toIso8601String(),
        'diasAsignado': diasAsignado,
      };
}
