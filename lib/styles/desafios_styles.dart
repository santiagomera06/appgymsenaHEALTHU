import 'package:flutter/material.dart';
import 'package:healthu/models/desafio_model.dart';

class DesafiosStyles {
  static const TextStyle titulo = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  

  static const TextStyle puntuacionTitulo = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle puntuacionValor = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );

  static const TextStyle label = TextStyle(
    color: Colors.grey,
  );

  static const TextStyle halted = TextStyle(
    color: Colors.orange,
    fontWeight: FontWeight.bold,
  );

  static Color getCardColor(Desafio desafio) {
    if (!desafio.desbloqueado) return Colors.grey[300]!;
    return desafio.completado ? Colors.green : Colors.blue[200]!;
  }
}