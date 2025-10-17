import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthu/models/crear_rutina_model.dart' as crear_rutina;
import 'package:healthu/models/rutina_model.dart' as rutina_model;
import 'package:flutter/foundation.dart';

const int timeoutSeconds = 10;

class RutinaService {
  static const String baseUrl = 'http://54.227.38.102:8080';

  static final _mockRutina = rutina_model.RutinaDetalle(
    id: 9999,
    nombre: 'Rutina de prueba',
    descripcion: 'Rutina mock para desarrollo',
    imagenUrl: '',
    nivel: 'Principiante',
    completada: false,
    ejercicios: [
      rutina_model.EjercicioRutina(
        id: 101,
        nombre: 'Sentadillas',
        series: 3,
        repeticiones: 12,
        pesoRecomendado: 5.0,
        descripcion: 'Ejercicio básico para piernas',
        imagenUrl: '',
        duracionEstimada: 3,
      ),
      rutina_model.EjercicioRutina(
        id: 102,
        nombre: 'Flexiones',
        series: 3,
        repeticiones: 10,
        descripcion: 'Ejercicio para brazos y pecho',
        imagenUrl: '',
        duracionEstimada: 3,
      ),
    ],
  );

  static Future<String?> _obtenerToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (withAuth) {
      final token = await _obtenerToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<int?> iniciarRutina(int idRutina) async {
    final token = await _obtenerToken();
    if (token == null) return null;

    final resp = await http.post(
      Uri.parse('$baseUrl/rutina-realizada/iniciar'),
      headers: await _headers(),
      body: json.encode({'idRutina': idRutina}),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      return data['idDesafioRealizado'] as int?;
    }
    return null;
  }

  static Future<bool> registrarSerieCompletada({
    required int idRutina,
    required int idEjercicio,
  }) async {
    final token = await _obtenerToken();
    if (token == null) return false;

    final body = {
      'idDesafioRealizado': idRutina,
      'idRutinaEjercicio': idEjercicio,
    };

    final resp = await http.patch(
      Uri.parse('$baseUrl/rutina-realizada/serie'),
      headers: await _headers(),
      body: json.encode(body),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      return data['ejercicioCompletado'] == true || data['rutinaCompletada'] == true;
    }
    return false;
  }

  static Future<bool> registrarProgresoEjercicio({
    required int idRutina,
    required int idEjercicio,
  }) async {
    final token = await _obtenerToken();
    if (token == null) return false;

    final body = {
      'idDesafioRealizado': idRutina,
      'idRutina': idEjercicio,
    };

    final resp = await http.post(
      Uri.parse('$baseUrl/progreso/RegistrarProgreso'),
      headers: await _headers(),
      body: json.encode(body),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      return data['success'] == true;
    }
    return false;
  }

  static Future<rutina_model.RutinaDetalle> obtenerRutina(String id) async {
    try {
      final resp = await http.get(
        Uri.parse('$baseUrl/rutina/obtenerRutina/$id'),
        headers: await _headers(withAuth: false),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        return _mapearRutinaDesdeApi(data);
      }
    } catch (e) {
      print('Error al obtener rutina: $e');
    }
    return _mockRutina;
  }

  static Future<List<rutina_model.RutinaDetalle>> obtenerRutinas() async {
    try {
      final resp = await http.get(
        Uri.parse('$baseUrl/rutina/obtenerRutinas'),
        headers: await _headers(withAuth: false),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        return data.map((e) => _mapearRutinaDesdeApi(e)).toList();
      }
    } catch (e) {
      print('Error al obtener rutinas: $e');
    }
    return [_mockRutina];
  }

  static Future<bool> crearRutina(crear_rutina.Rutina rutina) async {
    final token = await _obtenerToken();
    if (token == null) return false;

    final body = {
      'name': rutina.nombre,
      'description': rutina.descripcion,
      'imageUrl': rutina.fotoRutina,
      'focus': rutina.enfoque,
      'level': rutina.dificultad,
      'practices': rutina.ejercicios.map((e) => {
        'id': e.idEjercicio,
        'repetition': e.series,
        'target': e.repeticion,
        'value': e.carga,
        'timeplacement': e.duracion,
      }).toList(),
    };

    final resp = await http.post(
      Uri.parse('$baseUrl/rutina/crear'),
      headers: await _headers(),
      body: json.encode(body),
    ).timeout(const Duration(seconds: timeoutSeconds));

    return resp.statusCode == 201;
  }

  static Future<bool> actualizarRutina(String rutinaId, Map<String, dynamic> datos) async {
    final body = {
      'idButton': rutinaId,
      'practices': (datos['ejercicios'] as List?)?.map((e) => {
        'id': e['id'],
        'completed': e['completed'],
        'time': e['time'],
      }).toList() ?? [],
      'completed': datos['completada'],
    };

    final resp = await http.put(
      Uri.parse('$baseUrl/rutina/actualizar/$rutinaId'),
      headers: await _headers(),
      body: json.encode(body),
    ).timeout(const Duration(seconds: timeoutSeconds));

    return resp.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> validarQR({
    required String codigoQR,
    required int idDesafioRealizado,
  }) async {
    try {
      final headers = await _headers(withAuth: false);

      final response = await http.post(
        Uri.parse('$baseUrl/admin/validarQR'),
        headers: headers,
        body: json.encode({
          "codigoQR": codigoQR,
          "idDesafioRealizado": idDesafioRealizado,
        }),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al validar QR: $e');
      return null;
    }
  }

  static rutina_model.RutinaDetalle _mapearRutinaDesdeApi(Map<String, dynamic> data) {
    final ejerciciosRaw = (data['ejercicios'] ?? data['practices'] ?? []) as List;

    //  Normalización de imagen
    String? imagen;
    final foto = data['fotoRutina'] ?? data['imageUrl'] ?? '';
    if (foto != null && foto.toString().isNotEmpty) {
      final fotoStr = foto.toString();
      if (fotoStr.startsWith('http')) {
        imagen = fotoStr;
      } else {
        imagen = 'http://54.227.38.102:8080/uploads/$fotoStr';
      }
    }

    return rutina_model.RutinaDetalle(
      id: int.tryParse(
            data['identifier']?.toString() ??
            data['idRutina']?.toString() ??
            data['id']?.toString() ??
            '0',
          ) ??
          0,
      nombre: data['nombre'] ?? data['name'] ?? 'Rutina sin nombre',
      descripcion: data['descripcion'] ?? data['description'] ?? '',
      imagenUrl: imagen ?? '',
      nivel: data['nivel'] ?? data['level'] ?? data['dificultad'] ?? 'Intermedio',
      completada: data['completada'] ?? data['completed'] ?? false,
      ejercicios: _mapearEjercicios(ejerciciosRaw),
    );
  }

  static List<rutina_model.EjercicioRutina> _mapearEjercicios(List<dynamic> items) {
    int _int(dynamic v, [int def = 0]) => v == null ? def : (v is int ? v : int.tryParse(v.toString()) ?? def);
    double? _doubleN(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

    return items.map((p) {
      final m = p as Map<String, dynamic>;
      return rutina_model.EjercicioRutina(
        id: _int(m['id'] ?? m['idEjercicio']),
        nombre: m['name'] ?? m['nombre'] ?? 'Ejercicio sin nombre',
        series: _int(m['repetition'] ?? m['series'], 3),
        repeticiones: _int(m['target'] ?? m['repeticion'] ?? m['repeticiones'], 10),
        pesoRecomendado: _doubleN(m['value'] ?? m['carga'] ?? m['pesoRecomendado']),
        descripcion: m['description'] ?? m['descripcion'] ?? '',
        imagenUrl: m['imageUrl'] ?? m['imagenUrl'] ?? '',
        duracionEstimada: _int(m['timeplacement'] ?? m['duracion'] ?? m['duracionEstimada'], 60),
        completado: m['completed'] ?? m['completado'] ?? false,
        tiempoRealizado: m['time'] ?? m['tiempoRealizado'] != null ? _int(m['time'] ?? m['tiempoRealizado']) : null,
        idRutinaEjercicio: int.tryParse(
          m['idRutinaEjercicio']?.toString() ??
          m['rutinaEjercicioId']?.toString() ??
          m['idRelacion']?.toString() ?? ''
        ),
      );
    }).toList();
  }

  static Future<Map<String, dynamic>> generarRutina(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final resp = await http.post(
      Uri.parse('$baseUrl/rutina/generar'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return {};
      try {
        final parsed = jsonDecode(resp.body);
        return parsed is Map<String, dynamic> ? parsed : {'data': parsed};
      } catch (_) {
        return {'raw': resp.body};
      }
    }
    throw Exception('Error ${resp.statusCode}: ${resp.body}');
  }
static Future<rutina_model.RutinaDetalle?> obtenerRutinaPorAprendiz(int idPersona) async {
  try {
    debugPrint('[RutinaService] ---> GET $baseUrl/asignaciones/rutina/$idPersona');

    final asignacionResp = await http.get(
      Uri.parse('$baseUrl/asignaciones/rutina/$idPersona'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (asignacionResp.statusCode != 200 || asignacionResp.body.isEmpty) {
      debugPrint("❌ No se encontró asignación para idPersona=$idPersona");
      return null;
    }

    final asignacion = json.decode(asignacionResp.body);
    final idRutina = asignacion['idRutina'];
    if (idRutina == null) {
      debugPrint("⚠️ La asignación no tiene idRutina válido");
      return null;
    }

    debugPrint('[RutinaService] ---> GET $baseUrl/rutina/obtenerRutina/$idRutina');
    final rutinaResp = await http.get(
      Uri.parse('$baseUrl/rutina/obtenerRutina/$idRutina'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (rutinaResp.statusCode == 200 && rutinaResp.body.isNotEmpty) {
      final data = json.decode(rutinaResp.body);
      return _mapearRutinaDesdeApi(data);
    } else {
      debugPrint("❌ Error obteniendo rutina asignada: ${rutinaResp.statusCode}");
      return null;
    }
  } catch (e) {
    debugPrint(" Error en obtenerRutinaPorAprendiz: $e");
    return null;
  }
}

static Future<rutina_model.RutinaDetalle> obtenerRutinaPorNombre(String nombre) async {
  final url = Uri.parse('$baseUrl/rutina/obtenerPorNombre/$nombre');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final headers = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  try {
    debugPrint('[RutinaService] ---> GET $url');
    final resp = await http.get(url, headers: headers);
    debugPrint('[RutinaService] <--- ${resp.statusCode}');
    debugPrint('[RutinaService] Body: ${resp.body}');

    if (resp.statusCode == 200) {
      final jsonData = json.decode(resp.body);
      return rutina_model.RutinaDetalle.fromJson(jsonData);
    } else if (resp.statusCode == 404) {
      throw Exception('Rutina no encontrada: $nombre');
    } else {
      throw Exception('Error ${resp.statusCode} al obtener rutina $nombre: ${resp.body}');
    }
  } catch (e) {
    debugPrint('❌ Error al obtener rutina $nombre: $e');
    rethrow;
  }
}
static Future<rutina_model.RutinaDetalle> obtenerRutinaPorId(int idRutina) async {
  final url = Uri.parse('$baseUrl/rutina/obtenerRutina/$idRutina');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  debugPrint('[RutinaService] ---> GET $url');
  final response = await http.get(url, headers: headers);
  debugPrint('[RutinaService] <--- ${response.statusCode}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return rutina_model.RutinaDetalle.fromJson(data);
  } else {
    throw Exception('Error al obtener rutina por ID: ${response.statusCode}');
  }
}
}
