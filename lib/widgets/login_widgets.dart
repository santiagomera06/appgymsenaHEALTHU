import 'dart:ui';
import 'package:flutter/material.dart';

/// 🔹 Cabecera superior con logo y curva inferior
class LoginHeader extends StatelessWidget {
  final double alto;
  const LoginHeader({super.key, required this.alto});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: alto * 0.38, color: Colors.white),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 100, color: const Color(0xFFB9F6CA)),
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/healthu_logo.png',
                height: alto * 0.20,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              const Text(
                "Bienvenido a HEALTHU",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 🔹 Formulario con tarjeta translúcida
class LoginForm extends StatelessWidget {
  final double ancho;
  final TextEditingController usuarioCtrl;
  final TextEditingController claveCtrl;
  final bool obscureText;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.ancho,
    required this.usuarioCtrl,
    required this.claveCtrl,
    required this.obscureText,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB9F6CA), Color(0xFF00C853)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoginCard(context),
            const SizedBox(height: 40),
            const Text(
              'HealthU · Cuidamos tu bienestar físico y mental',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: ancho * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(usuarioCtrl, 'Correo electrónico', Icons.email_outlined),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 20),
                _buildRegisterLink(context),
              ],
            ),
          ),
        ),
      );

  Widget _buildTextField(TextEditingController c, String hint, IconData icon) => TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF00C853)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _buildPasswordField() => TextField(
        controller: claveCtrl,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: 'Contraseña',
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00C853)),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: onTogglePassword,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _buildLoginButton() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF64DD17)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: onLogin,
          child: const Text(
            'Ingresar',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget _buildRegisterLink(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('¿No tienes cuenta?', style: TextStyle(color: Colors.black54)),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/registro'),
            child: const Text(
              'Regístrate',
              style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
}

/// 🔹 Clipper para la curva decorativa inferior
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 30)
      ..quadraticBezierTo(size.width / 4, size.height, size.width / 2, size.height - 30)
      ..quadraticBezierTo(size.width * 3 / 4, size.height - 60, size.width, size.height - 30)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
