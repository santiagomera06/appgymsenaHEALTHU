import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crear_rutina_model.dart';

class RutinaService {
  static const String baseUrlCrear = 'https://gym-ver2-api-aafaf6c56cad.herokuapp.com/rutina/crear';
  static const String baseUrlCompletar = 'https://gym-ver2-api-aafaf6c56cad.herokuapp.com/rutina';

  /// Crea una nueva rutina en el backend.
  static Future<bool> crearRutina(Rutina rutina) async {
    try {
      final jsonData = rutina.toJson();
      print('Enviando datos a la API:');
      print(jsonEncode(jsonData));

      final response = await http.post(
        Uri.parse(baseUrlCrear),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(jsonData),
      ).timeout(const Duration(seconds: 20));

      print('Respuesta del servidor:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error del servidor: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en RutinaService.crearRutina: $e');
      rethrow;
    }
  }

  /// Marca la rutina con [rutinaId] como completada en el backend.
  static Future<bool> completarRutina(String rutinaId) async {
    final url = '$baseUrlCompletar/$rutinaId/completar';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      print('CompletarRutina response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al completar rutina: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en RutinaService.completarRutina: $e');
      rethrow;
    }
  }
}
