import 'package:flutter/material.dart';
import 'package:healthu/services/login_service.dart';
import 'package:healthu/services/usuario_service.dart';
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

  /// 🔹 Mapea la dificultad que viene del backend a un nivel más amigable
  String _mapNivel(String? dificultad) {
    switch (dificultad?.toLowerCase()) {
      case 'principiante':
        return 'Básico';
      case 'intermedio':
        return 'Medio';
      case 'avanzado':
        return 'Avanzado';
      default:
        return 'Básico';
    }
  }

  Future<void> _iniciarSesion() async {
    final email = usuarioCtrl.text.trim();
    final contrasena = claveCtrl.text.trim();

    final token = await LoginService().login(email, contrasena);

    if (!mounted) return;

    if (token != null) {
      try {
        // ✅ Decodificar token
        Map<String, dynamic> decoded = JwtDecoder.decode(token);
        debugPrint("✅ JWT payload: $decoded");

        // Guardar token y datos mínimos en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('id_usuario', decoded['id_usuario'].toString());
        await prefs.setString('id_persona', decoded['id_persona'].toString());
        await prefs.setString('fotoPerfil', decoded['foto'] ?? '');
        await prefs.setString('nombre_usuario', decoded['nombre_usuario'] ?? '');
        await prefs.setString('email', decoded['sub'] ?? '');

        if (!mounted) return;

        // 🔹 Llamamos al endpoint /rutina/porAprendiz para traer nivel real
        final usuario = await UsuarioService.obtenerUsuarioConNivel();

        if (usuario != null) {
          // Mapear dificultad a nivel actual
          final nivelMapped = _mapNivel(usuario.nivelActual);
          final usuarioConNivel = usuario.copyWith(nivelActual: nivelMapped);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  HomeScreen(usuario: usuarioConNivel, indiceInicial: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al obtener datos del usuario")),
          );
        }
      } catch (e, st) {
        debugPrint("❌ Error al procesar token o nivel: $e");
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
              // 🔹 Aquí reemplazamos el ícono por el logo
              Image.asset(
                'assets/images/healthu_logo.png',
                height: 180,
                fit: BoxFit.contain,
              ),
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
