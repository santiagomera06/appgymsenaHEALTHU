import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthu/services/rutinas_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:healthu/config/api_config.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:healthu/screens/rutinas/rutinas_generales.dart'; 

class CrearRutinaScreen extends StatefulWidget {
  const CrearRutinaScreen({super.key});

  @override
  State<CrearRutinaScreen> createState() => _CrearRutinaScreenState();
}

class _CrearRutinaScreenState extends State<CrearRutinaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  File? _foto;
  String _enfoque = 'FULL_BODY';
  String _dificultad = 'Principiante';
  int _cantidadEjercicios = 1;

  List<Map<String, dynamic>> _ejercicios = [];
  List<Map<String, dynamic>> _ejerciciosDisponibles = [];

  @override
  void initState() {
    super.initState();
    _inicializarEjercicios();
    _cargarEjerciciosDisponibles();
  }

  void _inicializarEjercicios() {
    _ejercicios = List.generate(_cantidadEjercicios, (i) {
      return {
        'idEjercicio': null,
        'series': '',
        'repeticiones': '',
        'carga': '',
        'duracion': '',
      };
    });
  }

  Future<void> _cargarEjerciciosDisponibles() async {
    try {
      final url = ApiConfig.getUrl('/ejercicio/obtenerEjercicios');
      final resp = await http.get(Uri.parse(url));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          setState(() {
            _ejerciciosDisponibles =
                List<Map<String, dynamic>>.from(data);
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error cargando ejercicios: $e');
    }
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _foto = File(pickedFile.path));
  }

  void _mostrarDialogo({
    required DialogType tipo,
    required String titulo,
    required String mensaje,
    VoidCallback? onOk,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: tipo,
      animType: AnimType.scale,
      title: titulo,
      desc: mensaje,
      btnOkOnPress: onOk,
      btnOkColor: tipo == DialogType.success
          ? Colors.green
          : tipo == DialogType.error
              ? Colors.red
              : Colors.orange,
      width: 330,
      dismissOnTouchOutside: false,
    ).show();
  }

  Future<void> _crearRutina() async {
    if (!_formKey.currentState!.validate()) return;

    if (_foto == null) {
      _mostrarDialogo(
        tipo: DialogType.warning,
        titulo: 'Falta la imagen ',
        mensaje: 'Selecciona una foto para la rutina antes de continuar.',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _mostrarDialogo(
        tipo: DialogType.warning,
        titulo: 'Sesión requerida ',
        mensaje: 'Debes iniciar sesión para crear una rutina.',
      );
      return;
    }

    final ejerciciosConvertidos = _ejercicios.map((e) {
      return {
        'idEjercicio': e['idEjercicio'] ?? 0,
        'series': int.tryParse(e['series'].toString()) ?? 0,
        'repeticion': int.tryParse(e['repeticiones'].toString()) ?? 0,
        'carga': int.tryParse(e['carga'].toString()) ?? 0,
        'duracion': int.tryParse(e['duracion'].toString()) ?? 0,
      };
    }).toList();

    final datos = {
      'nombre': _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'enfoque': _enfoque,
      'dificultad': _dificultad.toUpperCase(),
      'puntajeRutina': 0,
      'ejercicios': ejerciciosConvertidos,
    };

    final ok = await RutinasService.crearRutina(datos: datos, foto: _foto!);

    if (ok) {
      _mostrarDialogo(
        tipo: DialogType.success,
        titulo: '¡Rutina creada! ',
        mensaje: 'Tu rutina se ha guardado exitosamente.\nSerás redirigido a la lista de rutinas.',
        onOk: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const RutinasGenerales()),
            (route) => false,
          );
        },
      );
    } else {
      _mostrarDialogo(
        tipo: DialogType.error,
        titulo: 'Error al crear rutina',
        mensaje: 'Ocurrió un problema al guardar tu rutina.\nIntenta nuevamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Rutina'),
        backgroundColor: Colors.green,
      ),
      body: _ejerciciosDisponibles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre de la rutina'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      maxLines: 2,
                      validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    _foto == null
                        ? OutlinedButton.icon(
                            onPressed: _seleccionarFoto,
                            icon: const Icon(Icons.photo_camera),
                            label: const Text('Seleccionar foto de rutina'),
                          )
                        : Column(
                            children: [
                              Image.file(_foto!, height: 150),
                              TextButton(
                                onPressed: _seleccionarFoto,
                                child: const Text('Cambiar imagen'),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _enfoque,
                      decoration: const InputDecoration(labelText: 'Enfoque de la rutina'),
                      items: const [
                        DropdownMenuItem(value: 'FULL_BODY', child: Text('Full Body')),
                        DropdownMenuItem(value: 'TREN_SUPERIOR', child: Text('Tren Superior')),
                        DropdownMenuItem(value: 'TREN_INFERIOR', child: Text('Tren Inferior')),
                      ],
                      onChanged: (v) => setState(() => _enfoque = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _dificultad,
                      decoration: const InputDecoration(labelText: 'Dificultad'),
                      items: const [
                        DropdownMenuItem(value: 'Principiante', child: Text('Principiante')),
                        DropdownMenuItem(value: 'Intermedio', child: Text('Intermedio')),
                        DropdownMenuItem(value: 'Avanzado', child: Text('Avanzado')),
                      ],
                      onChanged: (v) => setState(() => _dificultad = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _cantidadEjercicios,
                      decoration: const InputDecoration(labelText: 'Cantidad de ejercicios'),
                      items: List.generate(
                        5,
                        (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1} ejercicios')),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _cantidadEjercicios = v!;
                          _inicializarEjercicios();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    for (int i = 0; i < _cantidadEjercicios; i++)
                      _buildEjercicioCard(i),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _crearRutina,
                      icon: const Icon(Icons.save),
                      label: const Text('Crear Rutina'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEjercicioCard(int index) {
    final ejercicio = _ejercicios[index];
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ejercicio ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Selecciona un ejercicio'),
              value: ejercicio['idEjercicio'],
              items: [
                const DropdownMenuItem(value: null, child: Text('-- Selecciona --')),
                ..._ejerciciosDisponibles.map((e) => DropdownMenuItem(
                      value: e['idEjercicio'],
                      child: Text(e['nombreEjercicio'] ?? 'Sin nombre'),
                    ))
              ],
              onChanged: (v) => setState(() => ejercicio['idEjercicio'] = v),
              validator: (v) => v == null ? 'Seleccione un ejercicio' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Series'),
              keyboardType: TextInputType.number,
              onChanged: (v) => ejercicio['series'] = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Repeticiones'),
              keyboardType: TextInputType.number,
              onChanged: (v) => ejercicio['repeticiones'] = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Carga (Kg)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => ejercicio['carga'] = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Duración (Seg)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => ejercicio['duracion'] = v,
            ),
          ],
        ),
      ),
    );
  }
}
