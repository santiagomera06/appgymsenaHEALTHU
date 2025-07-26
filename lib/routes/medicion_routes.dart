import 'package:flutter/material.dart';
import '../screens/dashboard/medicion_altura_screen.dart';

Map<String, WidgetBuilder> getMedicionRoutes() {
  return {
    '/medicion-altura': (context) => const MedicionAlturaScreen(),
  };
}
