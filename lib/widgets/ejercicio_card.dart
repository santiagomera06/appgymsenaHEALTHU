import 'package:flutter/material.dart';
import 'package:healthu/models/ejercicio_model.dart';
import 'package:healthu/styles/ejercicios_styles.dart';

class EjercicioCard extends StatelessWidget {
  final Ejercicio ejercicio;
  final VoidCallback onTap;

  const EjercicioCard({
    super.key,
    required this.ejercicio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: EjerciciosStyles.colorSecundario.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  image: ejercicio.imagenUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(ejercicio.imagenUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: ejercicio.imagenUrl.isEmpty
                    ? const Icon(Icons.fitness_center, size: 40)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ejercicio.nombre,
                      style: EjerciciosStyles.titulo.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ejercicio.descripcion,
                      style: EjerciciosStyles.detalle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${ejercicio.duracion} seg',
                          style: EjerciciosStyles.duracion,
                        ),
                        const Spacer(),
                        Icon(Icons.local_fire_department, 
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${ejercicio.calorias} cal',
                          style: EjerciciosStyles.detalle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}