import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:healthu/models/desafio_model.dart';

class DesafioService {
  static const String baseUrl = 'https://tu-api.com/desafios';

  static Future<List<Desafio>> obtenerDesafios() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Desafio(
          id: json['id'],
          nombre: json['nombre'],
          descripcion: json['descripcion'],
          desbloqueado: json['desbloqueado'],
          completado: json['completado'],
          puntuacion: json['puntuacion'],
          ejerciciosIds: List<String>.from(json['ejerciciosIds']),
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener desafíos: $e');
      return [];
    }
  }

  static Future<bool> actualizarDesafio(Desafio desafio) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${desafio.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'completado': desafio.completado,
          'desbloqueado': desafio.desbloqueado,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar desafío: $e');
      return false;
    }
  }

  static Future<int> obtenerPuntuacionUsuario() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/puntuacion'));
      if (response.statusCode == 200) {
        return json.decode(response.body)['puntuacion'];
      }
      return 0;
    } catch (e) {
      print('Error al obtener puntuación: $e');
      return 0;
    }
  }
}