import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RegisterAprendiz extends StatefulWidget {
  const RegisterAprendiz({super.key});

  @override
  State<RegisterAprendiz> createState() => _RegisterAprendizState();
}

class _RegisterAprendizState extends State<RegisterAprendiz> {
  final Map<String, TextEditingController> campos = {
    "nombreUsuario": TextEditingController(),
    "emailUsuario": TextEditingController(),
    "contrasenaUsuario": TextEditingController(),
    "estado": TextEditingController(text: "Activo"),
    "fotoPerfil": TextEditingController(),
    "apellidos": TextEditingController(),
    "nombres": TextEditingController(),
    "telefono": TextEditingController(),
    "identificacion": TextEditingController(),
    "fechaNacimiento": TextEditingController(),
    "ficha": TextEditingController(),
    "estatura": TextEditingController(),
    "peso": TextEditingController(),
    "horasAcumuladas": TextEditingController(text: "0"),
    "puntosAcumulados": TextEditingController(text: "0"),
    "nivelFisico": TextEditingController(),
  };

  String? jornadaSeleccionada;
  File? imagenSeleccionada;

  final url = Uri.parse('https://gym-ver2-api-aafaf6c56cad.herokuapp.com/auth/register');

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagenSeleccionada = File(pickedFile.path);
        campos['fotoPerfil']!.text = pickedFile.path;
      });
    }
  }

  Future<void> registrar() async {
    final datos = {
      ...campos.map((key, value) => MapEntry(key, value.text)),
      "jornada": jornadaSeleccionada ?? '',
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
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

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Registrar Aprendiz'),
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
                  GestureDetector(
                    onTap: seleccionarImagen,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: imagenSeleccionada != null
                          ? FileImage(imagenSeleccionada!)
                          : null,
                      child: imagenSeleccionada == null
                          ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  crearCampo("nombreUsuario", Icons.person),
                  crearCampo("emailUsuario", Icons.email),
                  crearCampo("contrasenaUsuario", Icons.lock),
                  crearCampo("estado", Icons.check_circle),
                  crearCampo("apellidos", Icons.person_outline),
                  crearCampo("nombres", Icons.person_2),
                  crearCampo("telefono", Icons.phone),
                  crearCampo("identificacion", Icons.badge),
                  crearCampo("ficha", Icons.book),
                  crearCampo("estatura", Icons.height),
                  crearCampo("peso", Icons.monitor_weight),
                  crearCampo("horasAcumuladas", Icons.timer),
                  crearCampo("puntosAcumulados", Icons.stars),
                  crearCampo("nivelFisico", Icons.fitness_center),

                  const SizedBox(height: 12),
                  TextField(
                    controller: campos['fechaNacimiento'],
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1960),
                        lastDate: DateTime.now(),
                        locale: const Locale('es', ''),
                      );
                      if (picked != null) {
                        campos['fechaNacimiento']!.text =
                            picked.toIso8601String().split('T').first;
                      }
                    },
                    decoration: decoracionCampo("fechaNacimiento", Icons.calendar_today),
                  ),

                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: decoracionCampo("jornada", Icons.schedule),
                    value: jornadaSeleccionada,
                    onChanged: (value) => setState(() => jornadaSeleccionada = value),
                    items: jornadas.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
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
                      'Registrarse',
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
