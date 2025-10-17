import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; 

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
    String? imagen;

    // Usar fotoEjercicio como campo principal
    if (json['fotoEjercicio'] != null) {
      final foto = json['fotoEjercicio'].toString();
      if (foto.startsWith('http')) {
        imagen = foto;
      } else {
        imagen = 'http://54.227.38.102:8080/uploads/$foto';
      }
    }
    // Si no hay fotoEjercicio, intentar con "imagen"

    else if (json['imagen'] != null) {
      final foto = json['imagen'].toString();
      if (foto.startsWith('http')) {
        imagen = foto;
      } else {
        imagen = 'http://54.227.38.102:8080/uploads/$foto';
      }
    }

    debugPrint('Ejercicio recibido: ${json['nombre']} | foto: $imagen');

    return Ejercicio(
      idEjercicio: json['idEjercicio'] ?? 0,
      nombre: json['nombre'] ?? 'Ejercicio sin nombre',
      descripcion: json['descripcion'] ?? '',
      imagen: imagen,
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
    String tipoOriginal = json['dificultad']?.toString() ?? 'General';

    debugPrint(
      ' Rutina recibida: ${json['nombre']} | dificultad: $tipoOriginal',
    );
    debugPrint('Foto de rutina: ${json['fotoRutina']}');

    // Normalizamos dificultad
    String tipo = tipoOriginal.toLowerCase();
    if (tipo.contains('principiante')) {
      tipo = 'Principiante';
    } else if (tipo.contains('intermedio')) {
      tipo = 'Intermedio';
    } else if (tipo.contains('avanzado')) {
      tipo = 'Avanzado';
    } else {
      tipo = 'General';
    }

    // Procesamos foto de rutina
    String? imagen;
    if (json['fotoRutina'] != null) {
      final foto = json['fotoRutina'].toString();
      if (foto.startsWith('http')) {
        imagen = foto;
      } else {
        imagen = 'http://54.227.38.102:8080/uploads/$foto';
      }
    }

    return Rutina(
      idRutina: json['idRutina'] ?? 0,
      nombre: json['nombre'] ?? 'Rutina sin nombre',
      descripcion: json['descripcion'] ?? '',
      imagen: imagen,
      tipo: tipo,
      ejercicios:
          (json['ejercicios'] as List?)
              ?.map((e) => Ejercicio.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RutinasGeneralesService {
  static const String baseUrl = 'http://54.227.38.102:8080';
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
