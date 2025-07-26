import 'package:flutter/material.dart';
import 'package:healthu/screens/dashboard/pantalla_procesamiento.dart';

class CardDataModel {
  final String title;
  final String value;
  final IconData icon;

  CardDataModel({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class TarjetasDashboard extends StatelessWidget {
  final List<CardDataModel> items;

  const TarjetasDashboard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return GestureDetector(
          onTap: () {
            if (item.title == 'Altura') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantallaProcesamiento(),
                ),
              );
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2 - 24,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(item.icon, size: 36, color: Colors.green),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
