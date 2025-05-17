import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/desafio_model.dart';
import '../screens/desafios_screen.dart';
import '../screens/ejercicios_principiante_screen.dart';

class DesafiosRoutes {
  static const String desafios = '/desafios';
  static const String ejercicios = '/ejercicios';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case desafios:
        return MaterialPageRoute(builder: (_) => const DesafiosScreen());
      case ejercicios:
        final desafio = settings.arguments as Desafio;
        return MaterialPageRoute(
          builder: (_) => EjerciciosPrincipianteScreen(
            nombreDesafio: desafio.nombre,
            desafio: desafio,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Future<void> guardarProgresoDesafios(List<Desafio> desafios) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final desafiosCompletados = desafios
          .where((d) => d.completado)
          .map((d) => d.id)
          .toList()
          .join(',');
      await prefs.setString('desafios_completados', desafiosCompletados);
    } catch (e) {
      debugPrint('Error guardando progreso: $e');
    }
  }

  static Future<List<Desafio>> cargarProgresoDesafios(
      List<Desafio> desafiosBase) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completados = prefs.getString('desafios_completados')?.split(',') ?? [];
      
      return desafiosBase.map((desafio) {
        final estaCompletado = completados.contains(desafio.id);
        final indiceActual = desafiosBase.indexWhere((d) => d.id == desafio.id);
        
        final estaDesbloqueado = estaCompletado || 
            (indiceActual == 0) ||
            (indiceActual > 0 && 
             completados.contains(desafiosBase[indiceActual - 1].id));
        
        return desafio.copyWith(
          completado: estaCompletado,
          desbloqueado: estaDesbloqueado,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error cargando progreso: $e');
      // Si hay error, retornamos los desafíos base con el primer desbloqueado
      return desafiosBase.asMap().entries.map((entry) {
        final index = entry.key;
        final desafio = entry.value;
        return desafio.copyWith(
          desbloqueado: index == 0,
          completado: false,
        );
      }).toList();
    }
  }
}