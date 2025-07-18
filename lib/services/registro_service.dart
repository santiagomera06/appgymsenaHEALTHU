import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RegistroService {
  static Future<String?> registrarAprendiz(Map<String, dynamic> datos, File? imagen) async {
    try {
      var uri = Uri.parse('http://54.227.38.102:8080/auth/register'); // Cambia por tu URL real
      var request = http.MultipartRequest('POST', uri);

      // Adjuntamos campos del formulario
      datos.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Adjuntar imagen si existe
      if (imagen != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'fotoPerfil', // Nombre esperado por el backend
          imagen.path,
        ));
        print('📸 Imagen adjuntada: ${imagen.path}');
      } else {
        print('🚫 No se adjunta imagen');
      }

      var response = await request.send();
      var body = await response.stream.bytesToString();
      print('📨 Respuesta del servidor:\nCódigo: ${response.statusCode}\nCuerpo: $body');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // Éxito
      } else {
        return 'Ocurrió un error: $body';
      }
    } catch (e) {
      return 'Error al conectar con el servidor: $e';
    }
  }
}
