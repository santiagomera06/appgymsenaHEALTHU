import 'package:flutter/material.dart';

class CrearRutinaStyles {
  static const TextStyle tituloSeccion = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );

  static const TextStyle textoDestacado = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle textoNormal = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );

  static const Color colorPrimario = Colors.green;
  static const Color colorSecundario = Colors.blueAccent;
  
  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.green),
      ),
    );
  }
}