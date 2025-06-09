import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crear_rutina_model.dart';

class RutinaService {
  static const String baseUrl = 'https://gym-ver2-api-aafaf6c56cad.herokuapp.com/rutina/crear';

  static Future<bool> crearRutina(Rutina rutina) async {
    try {
      // Convertir la rutina a JSON
      final jsonData = rutina.toJson();
      
      // Log para depuración
      print('Enviando datos a la API:');
      print(jsonEncode(jsonData));

      // Realizar la petición POST
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(jsonData),
      ).timeout(const Duration(seconds: 20));

      // Log de la respuesta
      print('Respuesta del servidor:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      // Verificar el código de estado
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
}