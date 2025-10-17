import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:healthu/services/login_service.dart';
import 'package:healthu/services/usuario_service.dart';
import 'package:healthu/screens/home inicio/home_screen.dart';
import 'package:healthu/widgets/login_widgets.dart'; // ✅ ahora viene de la carpeta widgets
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final usuarioCtrl = TextEditingController();
  final claveCtrl = TextEditingController();
  bool _obscureText = true;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  late final Animation<double> _fadeAnim =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void dispose() {
    usuarioCtrl.dispose();
    claveCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _mapNivel(String? d) {
    switch (d?.toLowerCase()) {
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

  void _mostrarError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ]),
        ),
      );

  Future<void> _iniciarSesion() async {
    final email = usuarioCtrl.text.trim();
    final contrasena = claveCtrl.text.trim();
    final token = await LoginService().login(email, contrasena);

    if (!mounted) return;
    if (token == null) return _mostrarError("Correo o contraseña incorrectos");

    try {
      final decoded = JwtDecoder.decode(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs
        ..setString('token', token)
        ..setString('id_usuario', decoded['id_usuario'].toString())
        ..setString('id_persona', decoded['id_persona'].toString())
        ..setString('fotoPerfil', decoded['foto'] ?? '')
        ..setString('nombre_usuario', decoded['nombre_usuario'] ?? '')
        ..setString('email', decoded['sub'] ?? '');

      final usuario = await UsuarioService.obtenerUsuarioConNivel();
      if (usuario == null) return _mostrarError("Error al obtener datos del usuario");

      final mapped = usuario.copyWith(nivelActual: _mapNivel(usuario.nivelActual));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(usuario: mapped, indiceInicial: 2)),
      );
    } catch (_) {
      _mostrarError("Error al procesar datos de sesión");
    }
  }

  @override
  Widget build(BuildContext context) {
    final alto = MediaQuery.of(context).size.height;
    final ancho = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            LoginHeader(alto: alto),
            Expanded(
              child: LoginForm(
                ancho: ancho,
                usuarioCtrl: usuarioCtrl,
                claveCtrl: claveCtrl,
                obscureText: _obscureText,
                onTogglePassword: () => setState(() => _obscureText = !_obscureText),
                onLogin: _iniciarSesion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
