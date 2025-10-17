import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

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
}

/// 🚨 Excepción personalizada cuando no hay rutinas asignadas
class NoAssignmentsException implements Exception {
  final String mensaje;
  NoAssignmentsException(this.mensaje);

  @override
  String toString() => mensaje;
}

class AsignacionRutinaService {
  /// 🔹 Obtiene todas las asignaciones de rutina por persona
  static Future<List<AsignacionRutina>> obtenerRutinasPorPersona(int idPersona) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/asignaciones/rutina/$idPersona');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    _log('---> GET $url');
    _log('Headers: ${_redactHeaders(headers)}');

    try {
      final response = await http.get(url, headers: headers);
      _log('<--- ${response.statusCode}');
      _log(' Body completo:\n${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          _log(' JSON decodificado (lista de asignaciones)');
          return decoded
              .map((e) => AsignacionRutina.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else if (decoded is Map) {
          _log('JSON decodificado (objeto único)');
          return [AsignacionRutina.fromJson(Map<String, dynamic>.from(decoded))];
        } else {
          throw Exception('Formato de respuesta inesperado: ${decoded.runtimeType}');
        }
      }

      // 🚨 Si el backend devuelve 404 con mensaje “No se encontraron asignaciones…”
      if (response.statusCode == 404) {
        try {
          final decoded = jsonDecode(response.body);
          final mensaje = decoded['mensaje'] ??
              'No se encontraron asignaciones de rutina para este aprendiz.';
          _log(' $mensaje');
          throw NoAssignmentsException(mensaje);
        } catch (_) {
          throw NoAssignmentsException('No se encontraron asignaciones de rutina.');
        }
      }

      // Otros códigos de error
      throw Exception('Error al obtener asignaciones: ${response.statusCode}');
    } catch (e) {
      _log(' Error HTTP: $e');
      rethrow;
    }
  }

  // 🔹 Oculta el token en los logs
  static String _redactHeaders(Map<String, String> headers) {
    final copy = Map<String, String>.from(headers);
    if (copy.containsKey('Authorization')) copy['Authorization'] = 'Bearer ***';
    return copy.toString();
  }

  // 🔹 Registra logs solo en modo debug
  static void _log(Object msg) {
    if (kDebugMode) {
      print('[AsignacionRutinaService] $msg');
    }
  }
}
