import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthu/models/usuario.dart';
import '../config/api_config.dart';
import 'package:flutter/foundation.dart';

class UsuarioService {
  static Future<Usuario?> obtenerUsuarioConNivel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception("No hay token guardado");

      final url = Uri.parse('${ApiConfig.baseUrl}/rutina/porAprendiz');
      debugPrint(" Intentando consumir: $url");

      final resp = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      debugPrint(" Status: ${resp.statusCode}");
      debugPrint(" Response body: ${resp.body}");

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);

        String nivel;
        if (data.isNotEmpty) {
          final rutina = data.first;
          nivel = rutina['dificultad'] ?? 'Sin nivel';
          debugPrint(" Nivel encontrado en rutina: $nivel");
        } else {
          nivel = 'Sin nivel';
          debugPrint(" No hay rutinas para este aprendiz");
        }

        return Usuario(
          id: int.tryParse(prefs.getString('id_usuario') ?? '0') ?? 0,
          nombre: prefs.getString('nombre_usuario') ?? 'Usuario',
          email: prefs.getString('email') ?? '',
          fotoUrl: prefs.getString('fotoPerfil') ?? '',
          nivelActual: nivel,
        );
      } else {
        throw Exception("Error ${resp.statusCode}: ${resp.body}");
      }
    } catch (e) {
      debugPrint("❌ Error en UsuarioService.obtenerUsuarioConNivel: $e");
      return null;
    }
  }
}
