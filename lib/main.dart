import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:healthu/screens/inicio%20secion/login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:healthu/styles/app_theme.dart';
import 'package:healthu/models/usuario.dart';
import 'package:healthu/screens/home%20inicio/home_screen.dart';
import 'package:healthu/screens/register/register_aprendiz.dart';
import 'package:healthu/screens/crear%20rutina/crear_rutina_screen.dart';
import 'package:healthu/screens/estadisticas/progreso_estadisticas_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:healthu/screens/dashboard/medicion_frecuencia_screen.dart';
import 'package:healthu/screens/frecuencia/frecuencia_list_screen.dart';


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
      supportedLocales: const [Locale('es', ''), Locale('en', '')],

      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/medicion-frecuencia': (context) => const MedicionFrecuenciaScreen(),
        '/login': (context) => const Login(),
        '/registro': (context) => const RegisterAprendiz(),
        '/home':
            (context) => FutureBuilder<Usuario>(
              future: _obtenerUsuarioDesdeToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const Login();
                } else {
                  return HomeScreen(usuario: snapshot.data!, indiceInicial: 2);
                }
              },
            ),
        '/crear-rutina': (context) => const CrearRutinaScreen(),
        '/progreso-estadisticas':(context) => const ProgresoEstadisticasScreen(),
        '/frecuencia-historial': (context) => const FrecuenciaListScreen(),

      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('Ruta no encontrada: ${settings.name}'),
                ),
              ),
        );
      },
    );
  }

  static Future<Usuario> _obtenerUsuarioDesdeToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('Token no encontrado');

    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Token inválido');

    final payload = utf8.decode(base64Url.decode(base64.normalize(parts[1])));
    final data = json.decode(payload);

 return Usuario(
  id: data['id_usuario'] is int
      ? data['id_usuario']
      : int.tryParse(data['id_usuario'].toString()) ?? 0,
  nombre: data['nombre_usuario'] ?? 'Usuario',
  email: data['sub'],
  fotoUrl: data['foto'] ?? '',
  nivelActual: data['nivelActual'] ?? 'Principiante',
);

  }
}
