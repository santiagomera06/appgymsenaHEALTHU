import 'dart:io';
import 'package:flutter/material.dart';
import 'package:healthu/services/registro_service.dart';

class RegisterDatosAprendiz extends StatefulWidget {
  final Map<String, String> datosUsuario;
  final File? imagenPerfil;

  const RegisterDatosAprendiz({
    super.key,
    required this.datosUsuario,
    required this.imagenPerfil,
  });

  @override
  State<RegisterDatosAprendiz> createState() => _RegisterDatosAprendizState();
}

class _RegisterDatosAprendizState extends State<RegisterDatosAprendiz> {
  final Map<String, TextEditingController> campos = {
    "estatura": TextEditingController(),
    "peso": TextEditingController(),
    "ficha": TextEditingController(),
    "horasAcumuladas": TextEditingController(text: "0"),
    "puntosAcumulados": TextEditingController(text: "0"),
  };

  String? jornadaSeleccionada;
  String? nivelFisicoSeleccionado;

  Future<void> registrar() async {
    final raw = widget.datosUsuario["fechaNacimiento"]!.trim();
    final dt = DateTime.parse(raw);

    // 👉 Formato compatible con LocalDateTime (sin Z, sin milisegundos)
    String fechaFormateada = "${dt.year.toString().padLeft(4, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.day.toString().padLeft(2, '0')}T00:00:00";

    print(' Fecha formateada enviada al backend: $fechaFormateada');

    final datosCompletos = {
      "nombreUsuario": widget.datosUsuario["nombreUsuario"]?.trim() ?? '',
      "emailUsuario": widget.datosUsuario["emailUsuario"]?.trim() ?? '',
      "contrasenaUsuario": widget.datosUsuario["contrasenaUsuario"]?.trim() ?? '',
      "apellidos": widget.datosUsuario["apellidos"]?.trim() ?? '',
      "nombres": widget.datosUsuario["nombres"]?.trim() ?? '',
      "telefono": widget.datosUsuario["telefono"]?.trim() ?? '',
      "identificacion": widget.datosUsuario["identificacion"]?.trim() ?? '',
      "fechaNacimiento": fechaFormateada, // 👈 ahora correcto para LocalDateTime
      "estado": widget.datosUsuario["estado"]?.trim() ?? 'Activo',
      "sexo": widget.datosUsuario["sexo"]?.trim() ?? '',
      "estatura": campos["estatura"]?.text.trim() ?? '0',
      "peso": campos["peso"]?.text.trim() ?? '0',
      "ficha": campos["ficha"]?.text.trim() ?? '0',
      "horasAcumuladas": campos["horasAcumuladas"]?.text.trim() ?? '0',
      "puntosAcumulados": campos["puntosAcumulados"]?.text.trim() ?? '0',
      "jornada": jornadaSeleccionada ?? '',
      "nivelFisico": nivelFisicoSeleccionado ?? '',
    };

    datosCompletos.forEach((key, value) {
      print("$key: $value");
    });

    final error = await RegistroService.registrarAprendiz(
      datosCompletos,
      widget.imagenPerfil,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso. Ahora inicia sesión.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  InputDecoration decoracionCampo(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: Colors.green),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget crearCampo(String key, IconData icono) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: campos[key],
        decoration: decoracionCampo(key, icono),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jornadas = ['Mañana', 'Tarde', 'Noche'];
    final nivelesFisicos = ['Principiante', 'Intermedio', 'Avanzado'];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Registrar Aprendiz - Datos Físicos'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (widget.imagenPerfil != null)
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: FileImage(widget.imagenPerfil!),
                    ),
                  const SizedBox(height: 20),

                  crearCampo("estatura", Icons.height),
                  crearCampo("peso", Icons.monitor_weight),
                  crearCampo("ficha", Icons.book),
                  crearCampo("horasAcumuladas", Icons.timer),
                  crearCampo("puntosAcumulados", Icons.stars),

                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: decoracionCampo(
                      "nivelFisico",
                      Icons.fitness_center,
                    ),
                    value: nivelFisicoSeleccionado,
                    onChanged: (value) =>
                        setState(() => nivelFisicoSeleccionado = value),
                    items: nivelesFisicos
                        .map(
                          (nivel) => DropdownMenuItem(
                            value: nivel,
                            child: Text(nivel),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: decoracionCampo("jornada", Icons.schedule),
                    value: jornadaSeleccionada,
                    onChanged: (value) =>
                        setState(() => jornadaSeleccionada = value),
                    items: jornadas
                        .map(
                          (j) => DropdownMenuItem(value: j, child: Text(j)),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: registrar,
                    icon: const Icon(Icons.check),
                    label: const Text(
                      'Completar Registro',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
