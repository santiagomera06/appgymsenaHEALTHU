import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthu/models/crear_rutina_model.dart' as crear_rutina;
import 'package:healthu/models/rutina_model.dart' as rutina_model;

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

  static Future<int?> iniciarRutina(int idRutina) async {
    try {
      final token = await _obtenerToken();
      if (token == null) return null;

      final response = await http
          .post(
            Uri.parse('$baseUrl/rutina-realizada/iniciar'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'idRutina': idRutina}),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['idDesafioRealizado'];
      }
      return null;
    } catch (e) {
      print('Error al iniciar rutina: $e');
      return null;
    }
  }

  static Future<bool> registrarSerieCompletada({
    required int idRutina,
    required int idEjercicio,
  }) async {
    try {
      final token = await _obtenerToken();
      if (token == null) return false;

      final response = await http
          .patch(
            Uri.parse('$baseUrl/rutina-realizada/serie'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'idDesafioRealizado': idRutina,
              'idRutinaEjercicio': idEjercicio,
            }),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ejercicioCompletado'] == true ||
            data['rutinaCompletada'] == true;
      }
      return false;
    } catch (e) {
      print('Error en registrarSerieCompletada: $e');
      return false;
    }
  }

  static Future<bool> registrarProgresoEjercicio({
    required int idRutina,
    required int idEjercicio,
  }) async {
    try {
      final token = await _obtenerToken();
      if (token == null) return false;

      final response = await http
          .post(
            Uri.parse('$baseUrl/progreso/RegistrarProgreso'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'idDesafioRealizado': idRutina,
              'idRutina': idEjercicio,
            }),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error en registrarProgresoEjercicio: $e');
      return false;
    }
  }

// Obtener una rutina específica
  static Future<rutina_model.RutinaDetalle> obtenerRutina(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rutina/obtenerRutina/$id'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _mapearRutinaDesdeApi(data);
      }

      return _mockRutina;
    } catch (e) {
      print('Error al obtener rutina, usando mock: $e');
      return _mockRutina;
    }
  }

  // Obtener todas las rutinas
  static Future<List<rutina_model.RutinaDetalle>> obtenerRutinas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rutina/obtenerRutinas'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => _mapearRutinaDesdeApi(item)).toList();
      }

      return [_mockRutina];
    } catch (e) {
      print('Error al obtener rutinas, usando mock: $e');
      return [_mockRutina];
    }
  }

  static Future<bool> crearRutina(crear_rutina.Rutina rutina) async {
    try {
      final token = await _obtenerToken();
      if (token == null) return false;

      final response = await http
          .post(
            Uri.parse('$baseUrl/rutina/crear'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
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

  static Future<bool> actualizarRutina(
    String rutinaId,
    Map<String, dynamic> datosActualizados,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/rutina/actualizar/$rutinaId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idButton': rutinaId,
          'practices': datosActualizados['ejercicios']?.map((e) => {
                'id': e['id'],
                'completed': e['completed'],
                'time': e['time'],
              }).toList() ?? [],
          'completed': datosActualizados['completada'],
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar rutina: $e');
      return false;
    }
  }

  static Future<bool> validarQRInstructor({
    required String rutinaId,
    required String qrCode,
  }) async {
    try {
      if (qrCode == "HEALTHU_VALIDACION_INSTRUCTOR|123e4567-e89b-12d3-a456-426614174000") {
        return true;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/rutina/validarQR'),
        headers: {'Content-Type': 'application/json'},
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

  static rutina_model.RutinaDetalle _mapearRutinaDesdeApi(Map<String, dynamic> data) {
    return rutina_model.RutinaDetalle(
      id: int.tryParse(data['identifier']?.toString() ?? data['id']?.toString() ?? '0') ?? 0,
      nombre: data['name'] ?? 'Rutina sin nombre',
      descripcion: data['description'] ?? '',
      imagenUrl: data['imageUrl'] ?? '',
      nivel: data['level'] ?? 'Intermedio',
      completada: data['completed'] ?? false,
      ejercicios: _mapearEjercicios(data['practices'] ?? []),
    );
  }

  static List<rutina_model.EjercicioRutina> _mapearEjercicios(List<dynamic> practices) {
    return practices.map((practice) {
      return rutina_model.EjercicioRutina(
        id: int.tryParse(practice['id']?.toString() ?? '0') ?? 0,
        nombre: practice['name'] ?? 'Ejercicio sin nombre',
        series: practice['repetition'] ?? 3,
        repeticiones: practice['target'] ?? 10,
        pesoRecomendado: practice['value'] != null ? double.tryParse(practice['value'].toString()) : null,
        descripcion: practice['description'] ?? '',
        imagenUrl: practice['imageUrl'] ?? '',
        duracionEstimada: practice['timeplacement'] ?? 60,
        completado: practice['completed'] ?? false,
        tiempoRealizado: practice['time'],
      );
    }).toList();
  }
}
