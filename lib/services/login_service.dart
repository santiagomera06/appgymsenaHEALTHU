import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class LoginService {
  final String _base = ApiConfig.baseUrl;

  Future<String?> login(String email, String contrasena) async {
    try {
      final uri = Uri.parse('$_base/auth/login');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'emailUsuario': email, 'contrasenaUsuario': contrasena}),
      );

      if (resp.statusCode != 200) {
        if (resp.statusCode == 401) return 'Credenciales incorrectas.';
        return 'Error ${resp.statusCode}: ${resp.body}';
      }

      print('🔐 LOGIN RESP BODY => ${resp.body}');
      final body = jsonDecode(resp.body);

      final token = body['token'] ??
          body['data']?['token'] ??
          body['usuario']?['token'];

      if (token == null || token.toString().isEmpty) {
        print('⚠️ Token no recibido en login');
        return 'Token no recibido.';
      }
      print('TOKEN recibido (recortado): ${token.toString().substring(0, 12)}...');

      // 1) Extraer id_persona / id_usuario del JWT
      final payload = _decodeJwtPayload(token.toString());
      print(' JWT payload: $payload');

      int? idPersona =
          _toInt(payload['id_persona']) ?? _toInt(payload['idPersona']);
      final int? idUsuario =
          _toInt(payload['id_usuario']) ?? _toInt(payload['idUsuario']);

      print('idPersona (JWT): $idPersona | idUsuario (JWT): $idUsuario');

      // 2) Respaldo: si el body trae idPersona
      idPersona ??= _pickIdPersona(body);
      print(' idPersona (login/body): $idPersona');

      // 3) Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.toString());
      await prefs.setString('email', email);
      await prefs.remove('id_persona');

      if (idPersona != null) {
        await prefs.setInt('id_persona', idPersona); // SIEMPRE int
        print(' Guardado id_persona (int): $idPersona');
      } else {
        print(' No se pudo resolver id_persona del JWT ni del body.');
      }

      if (idUsuario != null) {
        await prefs.setInt('id_usuario', idUsuario);
        print(' Guardado id_usuario: $idUsuario');
      }

      return null; 
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('id_persona');
    await prefs.remove('id_usuario');
    await prefs.remove('email');
    print(' Sesión cerrada, prefs limpiadas.');
  }

  // helper

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

  int? _pickIdPersona(Map<String, dynamic> body) {
    final cands = [
      body['idPersona'],
      body['data']?['idPersona'],
      body['usuario']?['idPersona'],
      body['persona']?['idPersona'],
      body['user']?['idPersona'],
    ];
    for (final c in cands) {
      final n = _toInt(c);
      if (n != null) return n;
    }
    return null;
  }
}
