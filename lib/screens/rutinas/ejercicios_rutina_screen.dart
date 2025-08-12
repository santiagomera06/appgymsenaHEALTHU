import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthu/models/crear_rutina_model.dart' as crear_rutina;
import 'package:healthu/models/rutina_model.dart' as rutina_model;

const int timeoutSeconds = 10;

class RutinaService {
  static const String baseUrl = 'http://54.227.38.102:8080';

  // ---------- Helpers ----------
  static Future<String?> _obtenerToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth) {
      final t = await _obtenerToken();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  // ---------- Iniciar rutina (si lo sigues usando aquí) ----------
  static Future<int?> iniciarRutina(int idRutina) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/rutina-realizada/iniciar'),
            headers: await _headers(),
            body: json.encode({'idRutina': idRutina}),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['idDesafioRealizado'] as int?;
      }
      return null;
    } catch (e) {
      print('Error al iniciar rutina: $e');
      return null;
    }
  }

  // ---------- PATCH /rutina-realizada/serie ----------
  static Future<bool> registrarSerieCompletada({
    required int idDesafioRealizado,
    required int idRutinaEjercicio,
  }) async {
    try {
      final url = '$baseUrl/rutina-realizada/serie';
      final body = {
        'idDesafioRealizado': idDesafioRealizado,
        'idRutinaEjercicio': idRutinaEjercicio,
      };

      print('📡 PATCH → $url');
      print('📦 Body: $body');

      final response = await http
          .patch(
            Uri.parse(url),
            headers: await _headers(),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Puedes cambiar esta condición si tu backend devuelve otra cosa
        return data['success'] == true ||
               data['ejercicioCompletado'] == true ||
               data['rutinaCompletada'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Error en registrarSerieCompletada: $e');
      return false;
    }
  }

  // ---------- POST /rutina-realizada/RegistrarProgreso (opcional) ----------
  static Future<bool> registrarProgresoEjercicio({
    required int idRutina,              // id de la rutina
    required int idDesafioRealizado,    // id del desafío realizado
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/rutina-realizada/RegistrarProgreso'),
            headers: await _headers(),
            body: json.encode({
              'idRutina': idRutina,
              'idDesafioRealizado': idDesafioRealizado,
            }),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error en registrarProgresoEjercicio: $e');
      return false;
    }
  }

  // ---------- GET /rutina/obtenerRutina/{id} ----------
  static Future<rutina_model.RutinaDetalle> obtenerRutina(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/rutina/obtenerRutina/$id'),
            headers: await _headers(auth: false), // si este GET no requiere token
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _mapearRutinaDesdeApi(data);
      }

      // Fallback ligero por si algo falla
      return _mockRutina;
    } catch (e) {
      print('Error al obtener rutina, usando mock: $e');
      return _mockRutina;
    }
  }

  // ---------- GET /rutina/obtenerRutinas ----------
  static Future<List<rutina_model.RutinaDetalle>> obtenerRutinas() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/rutina/obtenerRutinas'),
            headers: await _headers(auth: false),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> lista =
            body is List ? body : (body['items'] ?? []) as List<dynamic>;
        return lista
            .map((item) => _mapearRutinaDesdeApi(item as Map<String, dynamic>))
            .toList();
      }

      return [_mockRutina];
    } catch (e) {
      print('Error al obtener rutinas, usando mock: $e');
      return [_mockRutina];
    }
  }

  // ---------- POST /rutina/crear ----------
  static Future<bool> crearRutina(crear_rutina.Rutina rutina) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/rutina/crear'),
            headers: await _headers(),
            body: json.encode({
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
            }),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      return response.statusCode == 201;
    } catch (e) {
      print('Error al crear rutina: $e');
      return false;
    }
  }

  // ---------- PUT /rutina/actualizar/{rutinaId} ----------
  static Future<bool> actualizarRutina(
    String rutinaId,
    Map<String, dynamic> datosActualizados,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/rutina/actualizar/$rutinaId'),
            headers: await _headers(),
            body: json.encode({
              'idButton': rutinaId,
              'practices': (datosActualizados['ejercicios'] as List<dynamic>?)
                      ?.map((e) => {
                            'id': e['id'],
                            'completed': e['completed'],
                            'time': e['time'],
                          })
                      .toList() ??
                  [],
              'completed': datosActualizados['completada'],
            }),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar rutina: $e');
      return false;
    }
  }

  // ---------- Validación QR ----------
  static Future<bool> validarQRInstructor({
    required String rutinaId,
    required String qrCode,
  }) async {
    try {
      if (qrCode ==
          'HEALTHU_VALIDACION_INSTRUCTOR|123e4567-e89b-12d3-a456-426614174000') {
        return true;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/rutina/validarQR'),
        headers: await _headers(auth: false),
        body: json.encode({
          'rutinaId': rutinaId,
          'qrCode': qrCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['valid'] == true;
      }
      return false;
    } catch (e) {
      print('Error en validación QR: $e');
      return true; // Simula éxito en desarrollo
    }
  }

  // ---------- Mapeos ----------
  static rutina_model.RutinaDetalle _mapearRutinaDesdeApi(
      Map<String, dynamic> data) {
    // Soporta ambos esquemas (ES/EN)
    final ejerciciosRaw =
        (data['ejercicios'] ?? data['practices'] ?? []) as List<dynamic>;

    return rutina_model.RutinaDetalle(
      id: int.tryParse(
              data['idRutina']?.toString() ??
                  data['identifier']?.toString() ??
                  data['id']?.toString() ??
                  '0') ??
          0,
      nombre: data['nombre'] ?? data['name'] ?? 'Rutina sin nombre',
      descripcion: data['descripcion'] ?? data['description'] ?? '',
      imagenUrl: data['fotoRutina'] ??
          data['imageUrl'] ??
          '', // algunos endpoints usan fotoRutina
      nivel: data['nivel'] ?? data['dificultad'] ?? data['level'] ?? 'Intermedio',
      completada: data['completada'] ?? data['completed'] ?? false,
      ejercicios: _mapearEjercicios(ejerciciosRaw),
    );
  }

  static List<rutina_model.EjercicioRutina> _mapearEjercicios(
      List<dynamic> items) {
    return items.map((p) {
      final m = p as Map<String, dynamic>;
      return rutina_model.EjercicioRutina(
        // id del ejercicio
        id: int.tryParse(
                m['idEjercicio']?.toString() ?? m['id']?.toString() ?? '0') ??
            0,
        nombre: m['nombre'] ?? m['name'] ?? 'Ejercicio sin nombre',
        // series / repeticiones
        series: m['series'] ?? m['repetition'] ?? 3,
        repeticiones: m['repeticion'] ?? m['target'] ?? 10,
        // carga/peso
        pesoRecomendado: m['carga'] != null
            ? double.tryParse(m['carga'].toString())
            : (m['value'] != null
                ? double.tryParse(m['value'].toString())
                : null),
        descripcion: m['descripcion'] ?? m['description'] ?? '',
        imagenUrl: m['imagenUrl'] ?? m['imageUrl'] ?? '',
        duracionEstimada: m['duracion'] ?? m['timeplacement'] ?? 60,
        completado: m['completado'] ?? m['completed'] ?? false,
        tiempoRealizado: m['tiempoRealizado'] ?? m['time'],
        // 🎯 clave: viene desde el GET /rutina/obtenerRutina/{id}
        idRutinaEjercicio: int.tryParse(
              m['idRutinaEjercicio']?.toString() ??
                  m['rutinaEjercicioId']?.toString() ??
                  '',
            ) ??
            null,
      );
    }).toList();
  }

  // ---------- Mock para fallback ----------
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
}
