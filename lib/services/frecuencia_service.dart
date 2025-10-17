import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class FrecuenciaService {
  static Future<void> guardarFrecuenciaCardiaca(int frecuenciaCardiaca) async {
    final now = DateTime.now();
    final timestamp =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    print('\n [FrecuenciaService] ----> INICIO (${timestamp})');
    print(' Endpoint: ${ApiConfig.baseUrl}/admin/guardarFrecuenciaAprendiz');
    print(' Frecuencia a guardar: $frecuenciaCardiaca BPM');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print(' [FrecuenciaService] No se encontró token en SharedPreferences');
        return;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/admin/guardarFrecuenciaAprendiz');

      print('Headers:');
      print(jsonEncode({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.substring(0, 10)}...'
      }));

      print(' Body enviado: {"frecuenciaCardiaca": $frecuenciaCardiaca}');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "frecuenciaCardiaca": frecuenciaCardiaca,
        }),
      );

      print('[FrecuenciaService] <--- Respuesta recibida');
      print(' Código de estado: ${response.statusCode}');
      print(' Cuerpo: ${response.body}');

      if (response.statusCode == 200) {
        print(' [FrecuenciaService] Frecuencia guardada correctamente en el backend');
      } else {
        print(' [FrecuenciaService] Error al guardar frecuencia (${response.statusCode})');
      }
    } catch (e) {
      print('[FrecuenciaService] Error al conectar con el servidor: $e');
    }

    print('[FrecuenciaService] ----> FIN (${timestamp})\n');
  }

 static Future<List<Map<String, dynamic>>> obtenerFrecuenciasCardiacas() async {
  print('\n[FrecuenciaService] ---> INICIO obtenerFrecuenciasCardiacas()');

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('[FrecuenciaService] No se encontró token.');
      return [];
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/admin/obtenerFrecuenciaCardiaca');
    print('GET: $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('[FrecuenciaService] <--- Respuesta (${response.statusCode})');
    print('Cuerpo: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // ✅ Extraer el valor dentro de "data"
      if (decoded is Map && decoded['data'] != null) {
        final data = decoded['data'];
        // Envolvemos el resultado en una lista para mantener compatibilidad con el FutureBuilder
        return [data];
      }
      return [];
    } else {
      print('[FrecuenciaService] Error ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('[FrecuenciaService] Error al conectar: $e');
    return [];
  } finally {
    print('[FrecuenciaService] ---> FIN\n');
  }
}


}
