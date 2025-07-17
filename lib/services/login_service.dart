import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class LoginService {
  final String _url = ApiConfig.getUrl('/auth/login');

  Future<String?> login(String email, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "emailUsuario": email,
          "contrasenaUsuario": contrasena,
        }),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final token = json['token'];

        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          print('TOKEN guardado: $token');
          return null;
        } else {
          return 'Token no recibido.';
        }
      } else if (response.statusCode == 401) {
        return 'Credenciales incorrectas.';
      } else {
        return 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print(' Token eliminado del dispositivo usuario cerro sesión');
  }
}
