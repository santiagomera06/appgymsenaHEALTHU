import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/boton_en_imagen.dart';
import '../widgets/barra_navegacion.dart';
import '../widgets/temporizador.dart';
import '../services/rutinas_generales_service.dart';

class RutinasGenerales extends StatefulWidget {
  const RutinasGenerales({super.key});

  @override
  State<RutinasGenerales> createState() => _RutinasGeneralesState();
}

class _RutinasGeneralesState extends State<RutinasGenerales> {
  late Future<List<Rutina>> _rutinasFuture;
  final RutinasGeneralesService _rutinasService = RutinasGeneralesService();

  @override
  void initState() {
    super.initState();
    _cargarRutinas();
  }
  

  void _cargarRutinas() {
    setState(() {
      _rutinasFuture = _rutinasService.obtenerRutinas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas Generales'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarRutinas,
            tooltip: 'Actualizar rutinas',
          ),
        ],
      ),
      body: FutureBuilder<List<Rutina>>(
        future: _rutinasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 20),
                  Text(
                    'Error al cargar rutinas\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _cargarRutinas,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 50),
                  SizedBox(height: 20),
                  Text('No hay rutinas disponibles'),
                ],
              ),
            );
          }

          final rutinas = snapshot.data!;

          return ListView.builder(
            itemCount: rutinas.length,
            itemBuilder: (context, index) {
              final rutina = rutinas[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rutina.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: rutina.imagen != null
                                  ? CachedNetworkImage(
                                      imageUrl: rutina.imagen!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[300],
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.fitness_center, size: 40),
                                            SizedBox(height: 8),
                                            Text('Imagen no disponible', 
                                                style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.fitness_center, size: 50),
                                      ),
                                    ),
                            ),
                          ),
                          if (rutina.tipo.isNotEmpty)
                            BotonEnImagen(texto: rutina.tipo),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(rutina.descripcion),
                      const SizedBox(height: 10),
                      ExpansionTile(
                        title: const Text(
                          'Ver ejercicios',
                          style: TextStyle(fontSize: 16),
                        ),
                        children: rutina.ejercicios.map((ejercicio) => ListTile(
                          leading: const Icon(Icons.fitness_center, 
                              color: Colors.green),
                          title: Text(ejercicio.nombre),
                          subtitle: Text(
                            '${ejercicio.series ?? 'N/A'} x ${ejercicio.repeticiones ?? 'N/A'} rep',
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemporizadorPage(
                                titulo: rutina.nombre,
                                segundos: 300,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Iniciar rutina'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BarraNavegacion(indiceActual: 0),
    );
  }
}