import 'dart:io';
import 'package:flutter/material.dart';
import 'package:healthu/screens/register/register_datos_aprendiz.dart';
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
    "fotoPerfil": TextEditingController(),
    "apellidos": TextEditingController(),
    "nombres": TextEditingController(),
    "telefono": TextEditingController(),
    "identificacion": TextEditingController(),
    "fechaNacimiento": TextEditingController(),
  };

  File? imagenSeleccionada;
  String? estadoSeleccionado = 'Activo';
  String? sexoSeleccionado; // Variable para almacenar el sexo seleccionado
  bool _mostrarContrasena = false;

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

  void _siguientePantalla() {
    // Añadir el estado y sexo seleccionados al mapa de campos
    campos['estado'] = TextEditingController(text: estadoSeleccionado);
    campos['sexo'] = TextEditingController(text: sexoSeleccionado);
    
    // Validar campos obligatorios antes de continuar
    if (campos.values.any((controller) => controller.text.isEmpty) || sexoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterDatosAprendiz(
          datosUsuario: campos.map((key, value) => MapEntry(key, value.text)),
          imagenPerfil: imagenSeleccionada,
        ),
      ),
    );
  }

  InputDecoration decoracionCampo(String label, IconData icono, {bool esContrasena = false}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: Colors.green),
      suffixIcon: esContrasena
          ? IconButton(
              icon: Icon(
                _mostrarContrasena ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _mostrarContrasena = !_mostrarContrasena;
                });
              },
            )
          : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget crearCampo(String key, IconData icono, {bool esContrasena = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: campos[key],
        obscureText: esContrasena && !_mostrarContrasena,
        decoration: decoracionCampo(key, icono, esContrasena: esContrasena),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estados = ['Activo', 'Inactivo'];
    final sexos = ['Masculino', 'Femenino']; // Lista de opciones para sexo

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Registrar Aprendiz - Información Personal'),
        titleTextStyle: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold, 
          color: Colors.white, 
        ),
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
                  crearCampo("nombres", Icons.person_2),
                  crearCampo("apellidos", Icons.person_outline),
                  crearCampo("emailUsuario", Icons.email),
                  crearCampo("contrasenaUsuario", Icons.lock, esContrasena: true),
                  
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: decoracionCampo("estado", Icons.check_circle),
                    value: estadoSeleccionado,
                    onChanged: (value) => setState(() => estadoSeleccionado = value),
                    items: estados.map((estado) => DropdownMenuItem(
                      value: estado,
                      child: Text(estado),
                    )).toList(),
                  ),

                  crearCampo("telefono", Icons.phone),
                  crearCampo("identificacion", Icons.badge),
                  
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: decoracionCampo("sexo", Icons.people),
                    value: sexoSeleccionado,
                    onChanged: (value) => setState(() => sexoSeleccionado = value),
                    items: sexos.map((sexo) => DropdownMenuItem(
                      value: sexo,
                      child: Text(sexo),
                    )).toList(),
                    hint: const Text('Seleccione su sexo'), // Texto cuando no hay selección
                  ),

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

                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _siguientePantalla,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      'Siguiente',
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