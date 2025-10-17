import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class LoginService {
  final String _base = ApiConfig.baseUrl;

  Future<String?> login(String email, String contrasena) async {
    try {
      final uri = Uri.parse('$_base/auth/login');
      final bodyReq = {
        'emailUsuario': email,
        'contrasenaUsuario': contrasena,
      };

      print('\n═══════════════════════════════════════');
      print('[LoginService] 🚀 Enviando a: $uri');
      print('[LoginService] 📦 Body: ${jsonEncode(bodyReq)}');
      print('═══════════════════════════════════════\n');

      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bodyReq),
      );

      print('[LoginService] → Código: ${resp.statusCode}');
      print('[LoginService] → Respuesta: ${resp.body}');

      if (resp.statusCode != 200) {
        // Mostrar mensaje más claro
        if (resp.statusCode == 401) {
          print('⚠️ Credenciales inválidas');
        } else {
          print('❌ Error al iniciar sesión: código ${resp.statusCode}');
        }
        return null;
      }

      final body = jsonDecode(resp.body);
      final token = body['token'];

      if (token == null || token.toString().isEmpty) {
        print('⚠️ Token no recibido en la respuesta.');
        return null;
      }

      print('🔑 TOKEN recibido (recortado): ${token.toString().substring(0, 12)}...');

      // Guardar token y correo en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.toString());
      await prefs.setString('email', email);

      // Decodificar JWT (opcional)
      final payload = _decodeJwtPayload(token.toString());
      final idPersona = _toInt(payload['id_persona']);
      final idUsuario = _toInt(payload['id_usuario']);

      if (idPersona != null) await prefs.setInt('id_persona', idPersona);
      if (idUsuario != null) await prefs.setInt('id_usuario', idUsuario);

      print('✅ Login exitoso. Datos guardados en SharedPreferences');
      return token.toString();
    } catch (e) {
      print('⚠️ Error de conexión o excepción: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('👋 Sesión cerrada. Preferencias eliminadas.');
  }

  // ===== Helpers =====

  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = parts[1];
      var normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      final decoded = utf8.decode(base64.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    return int.tryParse('$v');
  }
}
