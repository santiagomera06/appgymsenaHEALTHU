import 'dart:convert';
import 'package:http/http.dart' as http;

class Ejercicio {
  final int idEjercicio;
  final String nombre;
  final String descripcion;
  final String? imagen;
  final int? series;
  final int? repeticiones;

  Ejercicio({
    required this.idEjercicio,
    required this.nombre,
    required this.descripcion,
    this.imagen,
    this.series,
    this.repeticiones,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    return Ejercicio(
      idEjercicio: json['idEjercicio'] ?? 0,
      nombre: json['nombre'] ?? 'Ejercicio sin nombre',
      descripcion: json['descripcion'] ?? '',
      imagen: json['imagen'],
      series: json['series'],
      repeticiones: json['repeticiones'],
    );
  }
}

class Rutina {
  final int idRutina;
  final String nombre;
  final String descripcion;
  final String? imagen;
  final String tipo;
  final List<Ejercicio> ejercicios;

  Rutina({
    required this.idRutina,
    required this.nombre,
    required this.descripcion,
    this.imagen,
    required this.tipo,
    required this.ejercicios,
  });

  factory Rutina.fromJson(Map<String, dynamic> json) {
    return Rutina(
      idRutina: json['idRutina'] ?? 0,
      nombre: json['nombre'] ?? 'Rutina sin nombre',
      descripcion: json['descripcion'] ?? '',
      imagen: json['imagen'],
      tipo: json['tipo'] ?? 'General',
      ejercicios: (json['ejercicios'] as List?)
              ?.map((e) => Ejercicio.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RutinasGeneralesService {
  static const String baseUrl = 'https://gym-ver2-api-aafaf6c56cad.herokuapp.com';
  static const String rutinasEndpoint = '/rutina/obtenerRutinas';

  Future<List<Rutina>> obtenerRutinas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$rutinasEndpoint'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((rutina) => Rutina.fromJson(rutina)).toList();
      } else {
        throw Exception('Error al cargar las rutinas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}