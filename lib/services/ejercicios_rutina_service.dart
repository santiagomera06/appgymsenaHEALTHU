import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/ejercicio_rutina.dart';

class EjerciciosRutinaService {
  static Future<List<EjercicioRutina>> obtenerPorRutina(int idRutina) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/rutinas/$idRutina/ejercicios');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final resp = await http.get(url, headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }

    final data = json.decode(resp.body);
    if (data is List) {
      return data
          .map((e) => EjercicioRutina.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final list = (data['items'] ?? data['data'] ?? []) as List;
    return list
        .map((e) => EjercicioRutina.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
