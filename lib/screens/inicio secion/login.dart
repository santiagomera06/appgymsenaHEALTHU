import 'package:flutter/material.dart';
import 'package:healthu/services/login_service.dart';
import 'package:healthu/models/usuario.dart';
import 'package:healthu/screens/home inicio/home_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usuarioCtrl = TextEditingController();
  final TextEditingController claveCtrl = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    usuarioCtrl.dispose();
    claveCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final email = usuarioCtrl.text.trim();
    final contrasena = claveCtrl.text.trim();

    final token = await LoginService().login(email, contrasena);

    if (!mounted) return;

    if (token != null) {
      try {
        // Decodificar el token
        Map<String, dynamic> decoded = JwtDecoder.decode(token);
        debugPrint("✅ JWT payload: $decoded");

        // Crear objeto Usuario con lo que viene en el token
        final usuario = Usuario(
          id: decoded['id_usuario'].toString(),
          nombre: decoded['nombre_usuario'] ?? '',
          email: decoded['sub'] ?? '',
          fotoUrl: decoded['foto'] ?? '',
          nivelActual: decoded['rol'] ?? '',
        );

        // Guardar datos en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('id_usuario', usuario.id);
        await prefs.setString('id_persona', decoded['id_persona'].toString());
        await prefs.setString('fotoPerfil', usuario.fotoUrl);

        if (!mounted) return;

        // 👉 Ir al home usando la ruta definida en main.dart
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e, st) {
        debugPrint(" Error al procesar token: $e");
        debugPrint("StackTrace: $st");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al procesar datos de sesión")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al iniciar sesión")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.fitness_center, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                'Bienvenido a HEALTHU',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: usuarioCtrl,
                autofillHints: const [AutofillHints.username],
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: claveCtrl,
                obscureText: _obscureText,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _iniciarSesion,
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registro');
                    },
                    child: const Text(
                      'Regístrate ahora',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
