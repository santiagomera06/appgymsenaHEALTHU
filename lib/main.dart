import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ NECESARIO para DatePicker en español
import 'package:healthu/screens/login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:healthu/styles/app_theme.dart';
import 'package:healthu/models/usuario.dart';
import 'package:healthu/screens/home_screen.dart';
import 'package:healthu/screens/register_aprendiz.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null); // ✅ Inicializa formato de fecha en español
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

      // ✅ Agregados para localización en español
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('es', ''), // Español
        Locale('en', ''), // Inglés
      ],

      home: const Login(),

      routes: {
        '/registro': (context) => const RegisterAprendiz(),
        '/dashboard': (context) =>
            HomeScreen(usuario: usuarioDemo, indiceInicial: 2),
      },
    );
  }
}
