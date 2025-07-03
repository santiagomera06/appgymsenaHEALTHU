import 'dart:convert';
import 'package:healthu/models/crear_rutina_model.dart' as crear_rutina;
import 'package:http/http.dart' as http;
import '../models/rutina_model.dart' as rutina_model;

class RutinaService {
  static const String baseUrl = 'https://gym-ver2-api-aafaf6c56cad.herokuapp.com'; // Reemplazar con tu URL base

  // Obtener una rutina específica por ID
  static Future<rutina_model.RutinaDetalle> obtenerRutina(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rutina/obtenerRutina/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _mapearRutinaDesdeApi(data);
      } else {
        throw Exception('Error al obtener rutina: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todas las rutinas disponibles
  static Future<List<rutina_model.RutinaDetalle>> obtenerRutinas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rutina/obtenerRutinas'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => _mapearRutinaDesdeApi(item)).toList();
      } else {
        throw Exception('Error al obtener rutinas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar una rutina existente
  static Future<bool> actualizarRutina(
    String rutinaId, 
    Map<String, dynamic> datosActualizados
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/rutina/actualizar/$rutinaId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idButton': rutinaId,
          'practices': datosActualizados['ejercicios']?.map((e) => {
            'id': e.id,
            'completed': e.completado,
            'time': e.tiempoRealizado,
          }).toList(),
          'completed': datosActualizados['completada'],
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar rutina: $e');
    }
  }

  // Validar un código QR con el instructor
  static Future<bool> validarQRInstructor({
    required String rutinaId,
    required String qrCode,
  }) async {
    try {
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
      } else {
        throw Exception('Error en validación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método privado para mapear los datos de la API al modelo
  static rutina_model.RutinaDetalle _mapearRutinaDesdeApi(Map<String, dynamic> data) {
    return rutina_model.RutinaDetalle(
      id: data['identifier']?.toString() ?? '0',
      nombre: data['name'] ?? 'Rutina sin nombre',
      descripcion: data['description'] ?? '',
      imagenUrl: data['imageUrl'] ?? '',
      nivel: data['level'] ?? 'Intermedio',
      completada: data['completed'] ?? false,
      ejercicios: _mapearEjercicios(data['practices'] ?? []).cast<rutina_model.EjercicioRutina>(),
    );
  }

  // Método privado para mapear los ejercicios
  static List<rutina_model.EjercicioRutina> _mapearEjercicios(List<dynamic> practices) {
    return practices.map((practice) {
      return rutina_model.EjercicioRutina(
        id: practice['id']?.toString() ?? '0',
        nombre: practice['name'] ?? 'Ejercicio sin nombre',
        series: practice['repetition'] ?? 3,
        repeticiones: practice['target'] ?? 10,
        pesoRecomendado: practice['value']?.toDouble(),
        descripcion: practice['description'] ?? '',
        imagenUrl: practice['imageUrl'] ?? '',
        duracionEstimada: practice['timeplacement'] ?? 60,
        completado: practice['completed'] ?? false,
        tiempoRealizado: practice['time']?.toInt(),
      );
    }).toList();
  }

  static crearRutina(crear_rutina.Rutina rutina) {}
} 