import 'package:flutter/material.dart';

class TarjetaAltura extends StatelessWidget {
  final String resultadoAltura;
  final VoidCallback onTap;

  const TarjetaAltura({
    super.key,
    required this.resultadoAltura,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.accessibility, size: 32),
        title: const Text('Altura estimada'),
        subtitle: Text(resultadoAltura),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
