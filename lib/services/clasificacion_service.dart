import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // para debugPrint

class ClasificacionService {
  static Future<List<dynamic>> obtenerTop10Aprendices() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse(ApiConfig.getUrl('/admin/listaAprendicesTop10'));

    debugPrint('🔹 [ClasificacionService] ---> GET $url');
    debugPrint('🔹 Headers: {Accept: application/json, Authorization: Bearer $token}');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      debugPrint(' [ClasificacionService] <--- ${response.statusCode} (${response.reasonPhrase})');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        //  extrae la lista de 'data'
        if (decoded is Map && decoded.containsKey('data')) {
          final list = decoded['data'] as List;
          debugPrint('Total registros recibidos: ${list.length}');
          return list;
        }

        // por compatibilidad
        if (decoded is List) {
          return decoded;
        }

        throw Exception('Formato de respuesta inesperado: $decoded');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint(' Excepción en ClasificacionService: $e');
      rethrow;
    }
  }
}
