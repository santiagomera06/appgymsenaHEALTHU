// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// Importa siempre con 'package:' o rutas relativas dentro de 'lib/'
import 'package:healthu/styles/app_theme.dart';
import 'package:healthu/models/usuario.dart';
import 'package:healthu/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Un valor no tiene que ser const si proviene de una clase normal.
    final usuarioDemo = Usuario(
      id: '12345678',
      nombre: 'Santiago Mera',
      email: 'santiagomera@example.com',
      fotoUrl: 'https://via.placeholder.com/150',
    );

    return MaterialApp(
      title: 'HEALTHU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeScreen(usuario: usuarioDemo),
    );
  }
}
