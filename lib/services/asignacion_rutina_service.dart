
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/asignacion_rutina.dart';

class AsignacionRutinaService {
  static Future<AsignacionRutina?> obtenerPorPersona(int idPersona) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/asignaciones/rutina/$idPersona');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    _log('---> GET $url');
    _log('Headers: ${_redactHeaders(headers)}');

    final t0 = DateTime.now();
    http.Response resp;
    try {
      resp = await http.get(url, headers: headers);
    } catch (e) {
      _log('HTTP error: $e');
      rethrow;
    }
    final dt = DateTime.now().difference(t0).inMilliseconds;
    _log('<--- ${resp.statusCode} (${dt}ms)');
    _log('Body: ${_safeBody(resp.body)}');

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data == null) {
        _log('Respuesta 200 pero body null');
        return null;
      }
      final asignacion = AsignacionRutina.fromJson(data as Map<String, dynamic>);
      _log('Parse OK -> idAsignacion=${asignacion.idAsignacion}, idRutina=${asignacion.idRutina}');
      return asignacion;
    }

    if (resp.statusCode == 404) {
      _log('Sin asignación (404).');
      return null;
    }

    throw Exception('Error ${resp.statusCode}: ${resp.body}');
  }
  static Map<String, String> _redactHeaders(Map<String, String> h) {
    final copy = Map<String, String>.from(h);
    if (copy.containsKey('Authorization')) copy['Authorization'] = 'Bearer ***';
    return copy;
    }

  static String _safeBody(String body, {int max = 1200}) {
    if (body.length <= max) return body;
    return body.substring(0, max) + '...<truncated>';
  }
  static void _log(Object msg) {
    if (kDebugMode) {
  
      print('[AsignacionRutinaService] $msg');
    }
  }
}
