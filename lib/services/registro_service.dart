import 'dart:io';
import 'package:http/http.dart' as http;


class RegistroService {
  static Future<String?> registrarAprendiz(
    Map<String, dynamic> datos,
    File? imagen,
  ) async {
    try {
      var uri = Uri.parse('http://54.227.38.102:8080/auth/register'); 
      var request = http.MultipartRequest('POST', uri);
      datos.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      if (imagen != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'fotoPerfil', 
            imagen.path,
          ),
        );
      } else {}
      var response = await request.send();
      var body = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      } else {
        return 'Ocurrió un error: $body';
      }
    } catch (e) {
      return 'Error al conectar con el servidor: $e';
    }
  }
}
