import 'package:flutter/material.dart';
import 'package:healthu/models/crear_rutina_model.dart';
import 'package:healthu/styles/crear_rutina_styles.dart';

class CrearRutinaCard extends StatelessWidget {
  final EjercicioRutina ejercicio;
  final VoidCallback onDelete;
  final String? nombreEjercicio;
  final String? imagenUrl; // Nuevo parámetro para la URL de la imagen del ejercicio

  const CrearRutinaCard({
    super.key,
    required this.ejercicio,
    required this.onDelete,
    this.nombreEjercicio,
    this.imagenUrl, // Parámetro opcional para la imagen
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Contenedor de la imagen del ejercicio
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                image: imagenUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imagenUrl!),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) => const Icon(Icons.fitness_center),
                      )
                    : null,
              ),
              child: imagenUrl == null
                  ? const Icon(Icons.fitness_center, 
                      color: Colors.green, 
                      size: 30)
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Información del ejercicio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del ejercicio
                  Text(
                    nombreEjercicio?.isNotEmpty == true
                        ? nombreEjercicio!
                        : 'Ejercicio #${ejercicio.idEjercicio}',
                    style: CrearRutinaStyles.textoDestacado,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Primera fila de datos (Series y Reps)
                  Row(
                    children: [
                      _buildInfoItem(
                        icon: Icons.repeat,
                        value: '${ejercicio.series} series',
                      ),
                      const SizedBox(width: 15),
                      _buildInfoItem(
                        icon: Icons.repeat_one,
                        value: '${ejercicio.repeticion} reps',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Segunda fila de datos (Carga y Duración)
                  Row(
                    children: [
                      if (ejercicio.carga > 0)
                        _buildInfoItem(
                          icon: Icons.fitness_center,
                          value: '${ejercicio.carga} kg',
                        ),
                      if (ejercicio.carga > 0) const SizedBox(width: 15),
                      if (ejercicio.duracion > 0)
                        _buildInfoItem(
                          icon: Icons.timer,
                          value: '${ejercicio.duracion} seg',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botón de eliminar
            IconButton(
              icon: const Icon(Icons.delete, 
                  color: Colors.red, 
                  size: 28),
              onPressed: onDelete,
              tooltip: 'Eliminar ejercicio', // Texto al mantener presionado
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir items de información
  Widget _buildInfoItem({required IconData icon, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: CrearRutinaStyles.textoNormal.copyWith(
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}