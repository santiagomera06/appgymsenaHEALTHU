import 'package:flutter/material.dart';
import 'package:healthu/screens/login.dart';
import 'package:intl/date_symbol_data_local.dart';
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

    final usuarioDemo = Usuario(
      id: '12345678',
      nombre: 'Santiago Mera',
      email: 'santiagomera@example.com',
      fotoUrl: 'https://via.placeholder.com/150',
      nivelActual: 'Avanzado', 
    );

    return MaterialApp(
      title: 'HEALTHU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Login()
    );
  }
}
