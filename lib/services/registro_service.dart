import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistroService {
  static const String _baseUrl = 'https://gym-ver2-api-aafaf6c56cad.herokuapp.com';

  static Future<String?> registrarAprendiz(Map<String, dynamic> datos) async {
    final url = Uri.parse('$_baseUrl/auth/register');

    try {
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        return null; // Sin error
      } else {
        return 'Error: ${respuesta.body}';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }
}
