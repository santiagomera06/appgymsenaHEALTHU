import 'package:flutter/material.dart';

/// Modelo de datos para cada tarjeta
class CardDataModel {
  final String title;
  final String value;
  final IconData icon;

  const CardDataModel({
    required this.title,
    required this.value,
    required this.icon,
  });
}

/// Widget que muestra un conjunto de tarjetas de estadísticas
/// Recibe una lista de [CardDataModel] para renderizar dinámicamente
class TarjetasDashboard extends StatelessWidget {
  final List<CardDataModel> items;

  const TarjetasDashboard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items.map((item) {
        return CardItem(
          title: item.title,
          value: item.value,
          icon: item.icon,
        );
      }).toList(),
    );
  }
}

/// Widget que representa una tarjeta individual con icono, valor y título
class CardItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const CardItem({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 100,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Colors.green),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
