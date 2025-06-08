import 'package:flutter/material.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Column(
            children: [
              const Text(
                'SenaHealthU',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 20),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            EncabezadoMenuLateral(),
            OpcionMenu(icono: Icons.home, texto: 'Inicio', ruta: '/'),
            OpcionMenu(icono: Icons.person, texto: 'Perfil', ruta: '/perfil'),
            Divider(),
            OpcionMenu(
              icono: Icons.logout,
              texto: 'Cerrar sesión',
              ruta: '/login',
              cerrarSesion: true,
            ),
          ],
        ),
      ),
body: ListView(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
  children: [
    // Botón decorativo debajo del AppBar
    Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.greenAccent,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Text(
          'Nivel',
          style: TextStyle(
            color: Color.fromARGB(255, 112, 109, 109),
            fontSize: 14,
          ),
        ),
      ),
    ),
    const SizedBox(height: 24), // Espacio debajo del botón
    const TarjetaNivel(
      titulo: 'principiante',
      experiencia: 'menos de 6 meses\nde experiencia',
      imagen: 'assets/images/principiante.png',
    ),
    const SizedBox(height: 16),
    const TarjetaNivel(
      titulo: 'intermedio',
      experiencia: 'más de 6 meses y\nmenos de 2 años',
      imagen: 'assets/images/intermedio.png',
    ),
    const SizedBox(height: 16),
    const TarjetaNivel(
      titulo: 'Avanzado',
      experiencia: 'Más de 2 años',
      imagen: 'assets/images/avanzado.png',
    ),
  ],
),

    );
  }
}

// Tarjetas de nivel
class TarjetaNivel extends StatelessWidget {
  final String titulo;
  final String experiencia;
  final String imagen;

  const TarjetaNivel({
    super.key,
    required this.titulo,
    required this.experiencia,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Container(width: 30, height: 2, color: Colors.green),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'experiencia',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      experiencia,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Image.asset(imagen, width: 40, height: 40, fit: BoxFit.contain),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Encabezado del menú lateral
class EncabezadoMenuLateral extends StatelessWidget {
  const EncabezadoMenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return const DrawerHeader(
      decoration: BoxDecoration(color: Colors.green),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/perfil.png'),
            radius: 30,
          ),
          SizedBox(height: 10),
          Text(
            'Aprendiz SENA',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            'aprendiz@sena.edu.co',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Opción del menú
class OpcionMenu extends StatelessWidget {
  final IconData icono;
  final String texto;
  final String ruta;
  final bool cerrarSesion;

  const OpcionMenu({
    super.key,
    required this.icono,
    required this.texto,
    required this.ruta,
    this.cerrarSesion = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono),
      title: Text(texto),
      onTap: () {
        Navigator.pop(context);
        if (cerrarSesion) {
          Navigator.pushReplacementNamed(context, ruta);
        } else {
          Navigator.pushNamed(context, ruta);
        }
      },
    );
  }
}
