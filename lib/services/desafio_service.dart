import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:healthu/models/desafio_model.dart';

class DesafioService {
  static const String baseUrl = 'https://tu-api.com/desafios';

  // Mock data para cuando la API no esté disponible
  static final _mockDesafios = [
    Desafio(
      id: 'mock-1',
      nombre: 'Desafío Principiante',
      descripcion: 'Completa 3 ejercicios básicos',
      desbloqueado: true,
      completado: false,
      puntuacion: 0,
      ejerciciosIds: ['mock-ej-1', 'mock-ej-2', 'mock-ej-3'],
    ),
    Desafio(
      id: 'mock-2',
      nombre: 'Desafío Intermedio',
      descripcion: 'Completa 5 ejercicios avanzados',
      desbloqueado: false,
      completado: false,
      puntuacion: 0,
      ejerciciosIds: [],
    ),
  ];

  static Future<List<Desafio>> obtenerDesafios() async {
    try {
      final response = await http.get(Uri.parse(baseUrl))
        .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Desafio(
          id: json['id'],
          nombre: json['nombre'],
          descripcion: json['descripcion'],
          desbloqueado: json['desbloqueado'],
          completado: json['completado'],
          puntuacion: json['puntuacion'],
          ejerciciosIds: List<String>.from(json['ejerciciosIds']),
        )).toList();
      }

      return _mockDesafios;
    } catch (e) {
      print('Error al obtener desafíos, usando datos mock: $e');
      return _mockDesafios;
    }
  }

  static Future<bool> actualizarDesafio(Desafio desafio) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${desafio.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'completado': desafio.completado,
          'desbloqueado': desafio.desbloqueado,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar desafío: $e');
      return false;
    }
  }

  static Future<int> obtenerPuntuacionUsuario() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/puntuacion'));
      if (response.statusCode == 200) {
        return json.decode(response.body)['puntuacion'];
      }
      return 0;
    } catch (e) {
      print('Error al obtener puntuación: $e');
      return 0;
    }
  }

  static Future<bool> desbloquearSiguienteDesafio(String desafioIdCompletado) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/desbloquear_siguiente'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'desafioId': desafioIdCompletado}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al desbloquear siguiente desafío: $e');
      return false;
    }
  }

  static Future<bool> marcarDesafioCompletado(String desafioId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$desafioId/completar'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error al marcar desafío como completado (simulando éxito): $e');
      return true; // simulamos éxito en caso de error
    }
  }

  static Future<bool> actualizarPuntuacion(String userId, int puntos) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuario/$userId/puntuacion'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'puntos': puntos}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar puntuación: $e');
      return false;
    }
  }
}
