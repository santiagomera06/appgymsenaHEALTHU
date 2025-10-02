import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class DesafioService {
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Crea headers con autenticación
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'User-Agent': 'PostmanRuntime/7.32.0',
      'Connection': 'keep-alive',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

static Future<Map<String, dynamic>?> obtenerDesafioActual() async {
  try {
    final headers = await _getAuthHeaders();

    // ✅ Construimos la URL
    final url = ApiConfig.getUrl('/desafios/obtenerDesafioActual');
    print("➡️ Intentando consumir: $url");
    print("➡️ Headers: $headers");

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 60));

    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // 👇 Log extra para calorías si están presentes
      if (data is Map && data.containsKey("caloriasTotales")) {
        print("🔥 Calorías totales recibidas: ${data['caloriasTotales']}");
      } else {
        print("⚠️ Este endpoint no trae caloríasTotales");
      }

      return data;
    } else {
      print('❌ Error obtenerDesafioActual: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('❌ Error al obtener desafío actual: $e');
    return null;
  }
}



/// 🔹 Nuevo método para traer lista de desafíos del usuario
static Future<List<Map<String, dynamic>>> obtenerDesafiosPorUsuario() async {
  try {
    final headers = await _getAuthHeaders();
    final url = ApiConfig.getUrl('/desafios/desafiosRealizadosPorUsuario');

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 60));

    print('➡️ GET $url');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((e) {
          final map = Map<String, dynamic>.from(e);

          // 🔹 Manejar calorías anidadas en kilocalorias
          if (map.containsKey('caloriasTotales')) {
            final calorias = map['caloriasTotales'];

            if (calorias is Map && calorias.containsKey('kilocalorias')) {
              map['caloriasTotales'] = calorias['kilocalorias'];
            } else if (calorias is num) {
              map['caloriasTotales'] = calorias;
            } else {
              map['caloriasTotales'] = 0.0;
            }
          } else {
            map['caloriasTotales'] = 0.0;
          }

          return map;
        }).toList();
      }
    } else {
      print('❌ Error obtenerDesafiosPorUsuario: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error al obtenerDesafiosPorUsuario: $e');
  }
  return [];
}



  static Future<Map<String, dynamic>?> iniciarRutinaDesafio(
    int idDesafio,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final url = ApiConfig.getUrl('/rutina-realizada/desafio/$idDesafio');

      final response = await http
          .patch(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty && response.body != 'null') {
          try {
            final responseData = json.decode(response.body);

            if (responseData is Map<String, dynamic>) {
              if (responseData.containsKey('idDesafioRealizado')) {
                print(
                  ' idDesafioRealizado: ${responseData['idDesafioRealizado']}',
                );
              }
            }
            return responseData;
          } catch (e) {
            return {
              'mensaje': response.body,
              'success': true,
              'statusCode': response.statusCode,
            };
          }
        } else {
          return {
            'mensaje': 'Respuesta vacía pero exitosa',
            'success': true,
            'statusCode': response.statusCode,
          };
        }
      } else {
        print(' Error iniciarRutinaDesafio: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(' Error al iniciar rutina desafío: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> registrarProgreso({
    required int idRutina,
    required int idDesafioRealizado,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final requestBody = {
        'idRutina': idRutina,
        'idDesafioRealizado': idDesafioRealizado,
      };

      final url = ApiConfig.getUrl('/progreso/RegistrarProgreso');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {'respuesta': response.body, 'success': true};
        }
      } else {
        print(' Error registrarProgreso: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(' Error al registrar progreso: $e');
      return null;
    }
  }

  /// Registra el inicio de la rutina en el endpoint POST /rutina-realizada/RegistrarProgreso
  static Future<Map<String, dynamic>?> registrarInicioRutina({
    required int idRutina,
    required int idDesafioRealizado,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = {
        'idRutina': idRutina,
        'idDesafioRealizado': idDesafioRealizado,
      };
      final url = ApiConfig.getUrl('/rutina-realizada/RegistrarProgreso');
      print('POST $url');
      print('Body: $body');

      final response = await http
          .post(Uri.parse(url), headers: headers, body: json.encode(body))
          .timeout(const Duration(seconds: 60));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Error registrarInicioRutina: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error en registrarInicioRutina: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> actualizarSerie({
    required int idDesafioRealizado,
    required int idRutinaEjercicio,
  }) async {
    print(
      ' Validando IDs: DesafioRealizado=$idDesafioRealizado, RutinaEjercicio=$idRutinaEjercicio',
    );

    final headers = await _getAuthHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}/rutina-realizada/serie');

    final requestBody = jsonEncode({
      "idDesafioRealizado": idDesafioRealizado,
      "idRutinaEjercicio": idRutinaEjercicio,
    });

    final response = await http.patch(url, headers: headers, body: requestBody);

    print(' PATCH → $url');
    print('Body: $requestBody');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } catch (e) {
        print(' Error parseando respuesta: $e');
        return null;
      }
    }

    return null;
  }

  static Future<List<Map<String, dynamic>>> obtenerEjerciciosRealizados({
    required int idDesafioRealizado,
  }) async {
    final headers = await _getAuthHeaders();
    final url = ApiConfig.getUrl(
      '/rutina-realizada/detalle/$idDesafioRealizado',
    );
    final res = await http.get(Uri.parse(url), headers: headers);

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    final lista =
        (data is List)
            ? data
            : (data['ejercicios'] ?? data['items'] ?? []) as List<dynamic>;

    return lista.cast<Map<String, dynamic>>();
  }


  static Future<Map<String, int>> obtenerConteoEstados(int idUsuario) async {
    final lista = await obtenerDesafiosPorUsuario();

    int finalizados = 0;
    int enProgreso = 0;

    for (var d in lista) {
      if (d["estado"] == "Finalizado") {
        finalizados++;
      } else if (d["estado"] == "En progreso") {
        enProgreso++;
      }
    }

    return {"finalizados": finalizados, "enProgreso": enProgreso};
  }

  /// 🔹 Obtiene las calorías agrupadas por día a partir de los desafíos realizados
static Future<Map<String, double>> obtenerCaloriasPorDia() async {
  try {
    final headers = await _getAuthHeaders();
    final url = ApiConfig.getUrl('/desafios/desafiosRealizadosPorUsuario');

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        final Map<String, double> caloriasPorDia = {};

        for (var item in data) {
          final fechaRaw = item['fechaInicioDesafio'] ?? item['fechaFinDesafio'];
          final calorias = (item['caloriasTotales'] ?? 0).toDouble();

          if (fechaRaw != null) {
            final fecha = DateTime.parse(fechaRaw);
            final dia = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";

            caloriasPorDia[dia] = (caloriasPorDia[dia] ?? 0) + calorias;
          }
        }

        return caloriasPorDia;
      }
    } else {
      print('❌ Error obtenerCaloriasPorDia: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error al obtenerCaloriasPorDia: $e');
  }

  return {};
}

static Future<void> debugCaloriasTotales() async {
  try {
    final headers = await _getAuthHeaders();
    final url = ApiConfig.getUrl('/desafios/desafiosRealizadosPorUsuario');

    final response = await http.get(Uri.parse(url), headers: headers);

    print("➡️ GET $url");
    print("⬅️ Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      double totalCalorias = 0;

      if (data is List) {
        for (var item in data) {
          final id = item['idDesafioRealizado'];
          final estado = item['estado'];
          final calorias = (item['caloriasTotales'] ?? 0).toDouble();

          print("🔥 Desafío $id | Estado: $estado | Calorías: $calorias kcal");

          totalCalorias += calorias;
        }

        print("✅ Total de calorías quemadas por el usuario: $totalCalorias kcal");
      }
    } else {
      print("❌ Error al obtener calorías: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error en debugCaloriasTotales: $e");
  }
}
/// 🔹 Obtiene el total de calorías y puntos de todos los desafíos realizados por el usuario
static Future<Map<String, double>> obtenerTotalesUsuario() async {
  try {
    final headers = await _getAuthHeaders();
    final url = ApiConfig.getUrl('/desafios/desafiosRealizadosPorUsuario');

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      double totalCalorias = 0;
      double totalPuntos = 0;

      if (data is List) {
        for (var item in data) {
          final calorias = (item['caloriasTotales'] ?? 0).toDouble();
          final puntos = (item['puntosObtenidos'] ?? 0).toDouble();

          totalCalorias += calorias;
          totalPuntos += puntos;
        }
      }

      print("🔥 Totales calculados → Calorías: $totalCalorias kcal | Puntos: $totalPuntos");

      return {
        "calorias": totalCalorias,
        "puntos": totalPuntos,
      };
    } else {
      print("❌ Error obtenerTotalesUsuario: ${response.statusCode}");
      return {"calorias": 0, "puntos": 0};
    }
  } catch (e) {
    print("❌ Error en obtenerTotalesUsuario: $e");
    return {"calorias": 0, "puntos": 0};
  }
}
/// 🔹 Obtiene calorías quemadas por día (solo desafíos finalizados)
static Future<Map<String, double>> obtenerCaloriasQuemadasPorDia() async {
  try {
    final headers = await _getAuthHeaders();
    final url = ApiConfig.getUrl('/desafios/desafiosRealizadosPorUsuario');

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final Map<String, double> caloriasPorDia = {};

      if (data is List) {
        for (var item in data) {
          final estado = item['estado'] ?? '';
          final caloriasRaw = item['caloriasTotales'];
          final fechaRaw = item['fechaFinDesafio'];

          if (estado == 'Finalizado' && caloriasRaw != null && fechaRaw != null) {
            final calorias = (caloriasRaw as num).toDouble();
            final fecha = DateTime.parse(fechaRaw);

            // Formato YYYY-MM-DD
            final dia =
                "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";

            caloriasPorDia[dia] = (caloriasPorDia[dia] ?? 0) + calorias;
          }
        }
      }

      print("🔥 Calorías agrupadas por día: $caloriasPorDia");
      return caloriasPorDia;
    } else {
      print("❌ Error obtenerCaloriasQuemadasPorDia: ${response.statusCode}");
      return {};
    }
  } catch (e) {
    print("❌ Error en obtenerCaloriasQuemadasPorDia: $e");
    return {};
  }
}
}
