import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:healthu/screens/inicio%20secion/login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:healthu/styles/app_theme.dart';
import 'package:healthu/models/usuario.dart';
import 'package:healthu/screens/home%20inicio/home_screen.dart';
import 'package:healthu/screens/register/register_aprendiz.dart';
import 'package:healthu/screens/crear%20rutina/crear_rutina_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const HealthuApp());
}

class HealthuApp extends StatelessWidget {
  const HealthuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HEALTHU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
        Locale('en', ''),
      ],

      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/registro': (context) => const RegisterAprendiz(),
        '/home': (context) {
          final usuario = ModalRoute.of(context)?.settings.arguments as Usuario?;
          return HomeScreen(
            usuario: usuario ?? _usuarioDemo(),
            indiceInicial: 2,
          );
        },
        '/crear-rutina': (context) => const CrearRutinaScreen(),
      },
      onGenerateRoute: (settings) {
        // Manejar rutas no definidas
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
      },
    );
  }

  Usuario _usuarioDemo() {
    return Usuario(
      id: '12345678',
      nombre: 'Usuario Demo',
      email: 'demo@example.com',
      fotoUrl: 'https://via.placeholder.com/150',
      nivelActual: 'Principiante',
    );
  }
}