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
    // Combinar datos de ambas pantallas
    final datosCompletos = {
      ...widget.datosUsuario,
      ...campos.map((key, value) => MapEntry(key, value.text)),
      "jornada": jornadaSeleccionada ?? '',
      "nivelFisico": nivelFisicoSeleccionado ?? '',
      "fotoPerfil": widget.imagenPerfil?.path ?? '',
    };

    final error = await RegistroService.registrarAprendiz(datosCompletos);

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );
      // Navegar al login después de registro exitoso
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    decoration: decoracionCampo("nivelFisico", Icons.fitness_center),
                    value: nivelFisicoSeleccionado,
                    onChanged: (value) => setState(() => nivelFisicoSeleccionado = value),
                    items: nivelesFisicos.map((nivel) => DropdownMenuItem(
                      value: nivel,
                      child: Text(nivel),
                    )).toList(),
                  ),

                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: decoracionCampo("jornada", Icons.schedule),
                    value: jornadaSeleccionada,
                    onChanged: (value) => setState(() => jornadaSeleccionada = value),
                    items: jornadas.map((j) => DropdownMenuItem(
                      value: j,
                      child: Text(j),
                    )).toList(),
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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