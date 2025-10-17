import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthu/config/api_config.dart';

class RutinasService {
  static Future<bool> crearRutina({
    required Map<String, dynamic> datos,
    File? foto,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = ApiConfig.getUrl('/rutina/crear');
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      // 🔹 Agregar el JSON correctamente con tipo application/json
      final jsonFile = http.MultipartFile.fromString(
        'datos',
        jsonEncode(datos),
        contentType: MediaType('application', 'json'),
      );
      request.files.add(jsonFile);

      // 🔹 Agregar la imagen si existe
      if (foto != null) {
        final mimeType = foto.path.toLowerCase().endsWith('.png')
            ? 'image/png'
            : 'image/jpeg';

        request.files.add(await http.MultipartFile.fromPath(
          'fotoRutina',
          foto.path,
          contentType: MediaType.parse(mimeType),
        ));

        print('[RutinasService] 🖼️ Imagen detectada: ${foto.path}');
        print('[RutinasService] 🧾 Tipo MIME: $mimeType');
      } else {
        print('[RutinasService] ⚠️ No se envía imagen (fotoRutina es null)');
      }

      // 🔹 Headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // 🔹 Logs
      print('\n═══════════════════════════════════════');
      print('[RutinasService] 🚀 Enviando solicitud a: $url');
      print('[RutinasService] 🧠 Datos JSON: ${jsonEncode(datos)}');
      print('═══════════════════════════════════════\n');

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      print('📡 [RutinasService] → Código: ${response.statusCode}');
      print('📦 [RutinasService] → Respuesta del servidor: $respStr');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [RutinasService] Rutina creada correctamente');
        return true;
      } else {
        print('❌ [RutinasService] Error al crear rutina: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('⚠️ [RutinasService] Excepción al crear rutina: $e');
      return false;
    }
  }
}
