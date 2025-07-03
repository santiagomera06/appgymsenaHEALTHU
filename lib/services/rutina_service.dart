import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:healthu/models/crear_rutina_model.dart' as crear_rutina;
import 'package:healthu/models/rutina_model.dart' as rutina_model;

class RutinaService {
  static const String baseUrl = 'https://gym-ver2-api-aafaf6c56cad.herokuapp.com';

  // Rutina mock para fallback
  static final _mockRutina = rutina_model.RutinaDetalle(
    id: 'mock-1',
    nombre: 'Rutina de prueba',
    descripcion: 'Rutina mock para desarrollo',
    imagenUrl: '',
    nivel: 'Principiante',
    completada: false,
    ejercicios: [
      rutina_model.EjercicioRutina(
        id: 'mock-ej-1',
        nombre: 'Sentadillas',
        series: 3,
        repeticiones: 12,
        pesoRecomendado: 5.0,
        descripcion: 'Ejercicio básico para piernas',
        imagenUrl: '',
        duracionEstimada: 5,
      ),
      rutina_model.EjercicioRutina(
        id: 'mock-ej-2',
        nombre: 'Flexiones',
        series: 3,
        repeticiones: 10,
        descripcion: 'Ejercicio para brazos y pecho',
        imagenUrl: '',
        duracionEstimada: 5,
      ),
      rutina_model.EjercicioRutina(
        id: 'mock-ej-3',
        nombre: 'Jumping jacks',
        series: 3,
        repeticiones: 15,
        descripcion: 'Ejercicio cardiovascular',
        imagenUrl: '',
        duracionEstimada: 5,
      ),
    ],
  );

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

  // Crear nueva rutina
  static Future<bool> crearRutina(crear_rutina.Rutina rutina) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rutina/crear'),
        headers: {'Content-Type': 'application/json'},
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
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al crear rutina: $e');
    }
  }

  // Actualizar rutina
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
                'id': e.id,
                'completed': e.completado,
                'time': e.tiempoRealizado,
              }).toList(),
          'completed': datosActualizados['completada'],
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar rutina (simulando éxito): $e');
      return true;
    }
  }

  // Validar QR con instructor (mock + real)
  static Future<bool> validarQRInstructor({
    required String rutinaId,
    required String qrCode,
  }) async {
    try {
      // Validación mock para entorno de desarrollo
      if (qrCode == "HEALTHU_VALIDACION_INSTRUCTOR|123e4567-e89b-12d3-a456-426614174000") {
        return true;
      }

      // Validación real contra API
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
      print('Error en validación QR (simulando éxito en desarrollo): $e');
      return true; // En desarrollo, simula éxito
    }
  }

  // Mapear datos desde API
  static rutina_model.RutinaDetalle _mapearRutinaDesdeApi(Map<String, dynamic> data) {
    return rutina_model.RutinaDetalle(
      id: data['identifier']?.toString() ?? '0',
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
}
