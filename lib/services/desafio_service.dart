import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class DesafioService {
  /// Obtiene el token de autenticación guardado
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Crea headers con autenticación
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'User-Agent': 'PostmanRuntime/7.32.0',
      'Connection': 'keep-alive',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>?> obtenerDesafioActual() async {
    try {
      final headers = await _getAuthHeaders();
      final url = ApiConfig.getUrl('/desafios/obtenerDesafioActual');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(' Error obtenerDesafioActual: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(' Error al obtener desafío actual: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> iniciarRutinaDesafio(
    int idDesafio,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final url = ApiConfig.getUrl('/rutina-realizada/desafio/$idDesafio');

      final response = await http
          .patch(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty && response.body != 'null') {
          try {
            final responseData = json.decode(response.body);

            if (responseData is Map<String, dynamic>) {
              if (responseData.containsKey('idDesafioRealizado')) {
                print(
                  ' idDesafioRealizado: ${responseData['idDesafioRealizado']}',
                );
              }
            }
            return responseData;
          } catch (e) {
            return {
              'mensaje': response.body,
              'success': true,
              'statusCode': response.statusCode,
            };
          }
        } else {
          return {
            'mensaje': 'Respuesta vacía pero exitosa',
            'success': true,
            'statusCode': response.statusCode,
          };
        }
      } else {
        print(' Error iniciarRutinaDesafio: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(' Error al iniciar rutina desafío: $e');
      return null;
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

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {'respuesta': response.body, 'success': true};
        }
      } else {
        print(' Error registrarProgreso: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(' Error al registrar progreso: $e');
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

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error actualizarSerie: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al actualizar serie: $e');
      return null;
    }
  }
}
