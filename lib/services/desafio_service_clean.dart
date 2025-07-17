import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class DesafioService {
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    print('Token en uso: $token');

    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length >= 2) {
          final payload = parts[1];
          final paddedPayload = payload + '=' * (4 - payload.length % 4);
          final decoded = utf8.decode(base64Decode(paddedPayload));
          print('Datos del token decodificado: $decoded');
        }
      } catch (e) {
        print('Error decodificando token: $e');
      }
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'User-Agent': 'PostmanRuntime/7.32.0',
      'Connection': 'keep-alive',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    print('Headers enviados: $headers');
    return headers;
  }

  static Future<Map<String, dynamic>?> obtenerDesafioActual() async {
    try {
      final headers = await _getAuthHeaders();
      final url = ApiConfig.getUrl('/desafios/obtenerDesafioActual');
      print('GET $url');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error: código ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al obtener desafío actual: $e');
      return null;
    }
  }

  static Future<bool> iniciarRutinaDesafio(int idDesafio) async {
    try {
      final headers = await _getAuthHeaders();
      final url = ApiConfig.getUrl('/rutina-realizada/desafio/$idDesafio');
      print('PATCH $url');

      final response = await http
          .patch(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(' Rutina iniciada exitosamente');
        return true;
      } else {
        print(' Error: código ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error al iniciar rutina: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> registrarProgreso({
    required int idRutina,
    required int idDesafioRealizado,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final requestBody = {
        'idRutina': idRutina,
        'idDesafioRealizado': idDesafioRealizado,
      };

      final url = ApiConfig.getUrl('/progreso/RegistrarProgreso');
      print('POST $url');
      print('Body: $requestBody');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 60));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {'respuesta': response.body, 'success': true};
        }
      } else {
        print(' Error: código ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al registrar progreso: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> actualizarSerie({
    required int idDesafioRealizado,
    required int idRutinaEjercicio,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final requestBody = {
        'idDesafioRealizado': idDesafioRealizado,
        'idRutinaEjercicio': idRutinaEjercicio,
      };

      final url = ApiConfig.getUrl('/rutina-realizada/serie');
      print('POST $url');
      print('Body: $requestBody');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 60));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(' Error: código ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al actualizar serie: $e');
      return null;
    }
  }
}
