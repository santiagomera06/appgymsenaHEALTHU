import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthu/models/crear_rutina_model.dart';
import 'package:healthu/models/ejercicio_model.dart';
import 'package:healthu/services/rutina_service.dart';
import 'package:healthu/styles/crear_rutina_styles.dart';

class CrearRutinaScreen extends StatefulWidget {
  const CrearRutinaScreen({super.key});

  @override
  State<CrearRutinaScreen> createState() => _CrearRutinaScreenState();
}

class _CrearRutinaScreenState extends State<CrearRutinaScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _imagenSeleccionada;
  String _nivelSeleccionado = 'PRINCIPIANTE';
  String _enfoqueSeleccionado = 'TREN_SUPERIOR';

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _numEjerciciosCtrl = TextEditingController();

  List<EjercicioRutinaData> _ejerciciosData = [];
  final List<Ejercicio> _ejerciciosPredefinidos = [
    Ejercicio(id: '1', nombre: 'Sentadillas', descripcion: '', imagenUrl: '', duracion: 0, calorias: 0),
    Ejercicio(id: '2', nombre: 'Press de banca', descripcion: '', imagenUrl: '', duracion: 0, calorias: 0),
    Ejercicio(id: '3', nombre: 'Peso muerto', descripcion: '', imagenUrl: '', duracion: 0, calorias: 0),
    Ejercicio(id: '4', nombre: 'Curl de bíceps', descripcion: '', imagenUrl: '', duracion: 0, calorias: 0),
    Ejercicio(id: '5', nombre: 'Dominadas', descripcion: '', imagenUrl: '', duracion: 0, calorias: 0),
    Ejercicio(id: '6', nombre: 'Fondos', descripcion: '', imagenUrl: '', duracion: 0, calorias: 0),
    Ejercicio(id: '7', nombre: 'Remo con barra', descripcion: '', imagenUrl: '', duracion: 0, calorias: 0),
  ];

  @override
  void initState() {
    super.initState();
    _ejerciciosData.add(EjercicioRutinaData());
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  void _generarCamposEjercicios() {
    final int? num = int.tryParse(_numEjerciciosCtrl.text);
    if (num != null && num > 0) {
      setState(() {
        _ejerciciosData = List.generate(num, (index) => EjercicioRutinaData());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un número válido de ejercicios (mayor que 0)')),
      );
    }
  }

Future<void> _guardarRutina() async {
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor complete todos los campos requeridos')),
    );
    return;
  }

  // Validar que todos los ejercicios tengan datos
  if (_ejerciciosData.isEmpty || _ejerciciosData.any((e) => e.selectedEjercicio == null)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seleccione un ejercicio para cada campo')),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Usar una URL por defecto si no se seleccionó imagen
    String imagenUrl = 'https://via.placeholder.com/150';
    
    // Si se seleccionó una imagen local, podrías subirla a un servidor aquí
    // y obtener la URL real, pero por ahora usamos la de placeholder
    // En producción, deberías implementar la subida real de la imagen
    if (_imagenSeleccionada != null) {
      // Aquí iría el código para subir la imagen y obtener la URL real
      // Por ahora usamos un placeholder diferente para indicar que se seleccionó imagen
      imagenUrl = 'https://via.placeholder.com/150/FF0000/FFFFFF?text=Imagen+Seleccionada';
    }

    final rutina = Rutina(
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      fotoRutina: imagenUrl, // Usamos la URL definida
      enfoque: _enfoqueSeleccionado,
      dificultad: _nivelSeleccionado,
      ejercicios: _ejerciciosData.map((data) {
        return EjercicioRutina(
          idEjercicio: int.parse(data.selectedEjercicio!.id),
          series: int.parse(data.seriesCtrl.text),
          repeticion: int.parse(data.repeticionesCtrl.text),
          carga: data.cargaCtrl.text.isEmpty ? 0 : int.parse(data.cargaCtrl.text),
          duracion: data.duracionCtrl.text.isEmpty ? 0 : int.parse(data.duracionCtrl.text),
        );
      }).toList(),
    );

    // Debug: Mostrar el JSON que se enviará
    print('JSON a enviar: ${jsonEncode(rutina.toJson())}');

    final success = await RutinaService.crearRutina(rutina);
    
    Navigator.of(context).pop(); // Cerrar diálogo de carga
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rutina creada exitosamente')),
      );
      Navigator.of(context).pop(); // Volver atrás
    }
  } catch (e) {
    Navigator.of(context).pop(); // Cerrar diálogo de carga
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al crear rutina: ${e.toString()}'),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _numEjerciciosCtrl.dispose();
    for (var data in _ejerciciosData) {
      data.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Rutina'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de imagen
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imagenSeleccionada != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _imagenSeleccionada!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text('Agregar imagen', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Información básica
              Text('Información básica', style: CrearRutinaStyles.tituloSeccion),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nombreCtrl,
                decoration: CrearRutinaStyles.inputDecoration('Nombre de la rutina'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: CrearRutinaStyles.inputDecoration('Descripción'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _nivelSeleccionado,
                decoration: CrearRutinaStyles.inputDecoration('Nivel de dificultad'),
                items: ['PRINCIPIANTE', 'INTERMEDIO', 'AVANZADO']
                    .map((nivel) => DropdownMenuItem(
                          value: nivel,
                          child: Text(nivel),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _nivelSeleccionado = value!),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _enfoqueSeleccionado,
                decoration: CrearRutinaStyles.inputDecoration('Enfoque de la rutina'),
                items: ['TREN_SUPERIOR', 'TREN_INFERIOR', 'FULL_BODY']
                    .map((enfoque) => DropdownMenuItem(
                          value: enfoque,
                          child: Text(enfoque),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _enfoqueSeleccionado = value!),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              // Sección para pedir el número de ejercicios
              Text('Número de ejercicios', style: CrearRutinaStyles.tituloSeccion),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numEjerciciosCtrl,
                      decoration: CrearRutinaStyles.inputDecoration('¿Cuántos ejercicios desea agregar?'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese un número';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Ingrese un número válido mayor que 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _generarCamposEjercicios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Generación de campos para cada ejercicio
              if (_ejerciciosData.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 10),
                Text('Detalle de ejercicios', style: CrearRutinaStyles.tituloSeccion),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ejerciciosData.length,
                  itemBuilder: (context, index) {
                    final ejercicioData = _ejerciciosData[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ejercicio ${index + 1}', style: CrearRutinaStyles.textoDestacado),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<Ejercicio>(
                          decoration: CrearRutinaStyles.inputDecoration('Nombre del ejercicio'),
                          value: ejercicioData.selectedEjercicio,
                          items: _ejerciciosPredefinidos.map((ejercicio) {
                            return DropdownMenuItem<Ejercicio>(
                              value: ejercicio,
                              child: Text(ejercicio.nombre),
                            );
                          }).toList(),
                          onChanged: (Ejercicio? newValue) {
                            setState(() {
                              ejercicioData.selectedEjercicio = newValue;
                            });
                          },
                          validator: (value) => value == null ? 'Seleccione un ejercicio' : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: ejercicioData.seriesCtrl,
                                decoration: CrearRutinaStyles.inputDecoration('Series'),
                                keyboardType: TextInputType.number,
                                validator: (value) => value == null || value.isEmpty ? 'Obligatorio' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: ejercicioData.repeticionesCtrl,
                                decoration: CrearRutinaStyles.inputDecoration('Repeticiones'),
                                keyboardType: TextInputType.number,
                                validator: (value) => value == null || value.isEmpty ? 'Obligatorio' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: ejercicioData.cargaCtrl,
                                decoration: CrearRutinaStyles.inputDecoration('Carga (kg)'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: ejercicioData.duracionCtrl,
                                decoration: CrearRutinaStyles.inputDecoration('Duración (seg)'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: 20),

              // Botón guardar
              Center(
                child: ElevatedButton(
                  onPressed: _guardarRutina,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Guardar Rutina'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EjercicioRutinaData {
  Ejercicio? selectedEjercicio;
  final TextEditingController seriesCtrl = TextEditingController();
  final TextEditingController repeticionesCtrl = TextEditingController();
  final TextEditingController cargaCtrl = TextEditingController();
  final TextEditingController duracionCtrl = TextEditingController();

  void dispose() {
    seriesCtrl.dispose();
    repeticionesCtrl.dispose();
    cargaCtrl.dispose();
    duracionCtrl.dispose();
  }
}