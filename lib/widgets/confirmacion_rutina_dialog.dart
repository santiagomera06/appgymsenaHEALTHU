import 'package:flutter/material.dart';

class ConfirmacionRutinaDialog extends StatelessWidget {
  final VoidCallback? onConfirmar;
  final VoidCallback? onCancelar;

  const ConfirmacionRutinaDialog({
    super.key,
    this.onConfirmar,
    this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '¿Estás listo para iniciar?',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Antes de comenzar la rutina, asegúrate de:'),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Tener el espacio adecuado')),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Contar con el equipo necesario')),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Estar preparado físicamente')),
            ],
          ),
          SizedBox(height: 15),
          Text(
            '¿Estás listo para comenzar la rutina?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancelar?.call();
          },
          child: const Text('No', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmar?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Sí, iniciar rutina'),
        ),
      ],
    );
  }

  static Future<void> mostrar({
    required BuildContext context,
    VoidCallback? onConfirmar,
    VoidCallback? onCancelar,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ConfirmacionRutinaDialog(
            onConfirmar: onConfirmar,
            onCancelar: onCancelar,
          ),
    );
  }
}
