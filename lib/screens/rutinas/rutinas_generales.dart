import 'package:flutter/material.dart';
import 'package:healthu/screens/rutinas/detalle_rutina.dart';
import 'package:healthu/screens/desafios/desafios_screen.dart';
import 'package:healthu/screens/Dashboard/dashboard_screen.dart';
import 'package:healthu/models/usuario.dart';

import 'package:healthu/services/rutinas_generales_service.dart';
import 'package:healthu/models/rutina_model.dart';
import 'package:healthu/widgets/bottom_nav_bar.dart';

class RutinasGenerales extends StatefulWidget {
  const RutinasGenerales({super.key});

  @override
  State<RutinasGenerales> createState() => _RutinasGeneralesState();
}

class _RutinasGeneralesState extends State<RutinasGenerales> {
  String nivelSeleccionado = 'Todos';
  List<Rutina> _rutinas = [];
  bool _cargando = true;

  int _selectedIndex = 1;
  
  get usuario => null; // ✅ Estás en la pestaña de Rutinas

  void _onTap(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Desafíos
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DesafiosScreen()),
        );
        break;
      case 1: // Rutinas
        // Ya estás aquí, no necesitas hacer nada
        break;
         case 2:
      // Solo necesitas esto para ir al DashboardScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            usuario: Usuario(
              id: '0',
              nombre: 'Invitado',
              email: 'invitado@correo.com',
              fotoUrl: 'https://via.placeholder.com/150',
              nivelActual: 'Principiante', // Ajusta el valor según corresponda
            ),
          ),
        ),
      );
      break;
    
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarRutinas();
  }

  void _cargarRutinas() async {
    try {
      final servicio = RutinasGeneralesService();
      final rutinas = await servicio.obtenerRutinas();
      setState(() {
        _rutinas = rutinas;
        _cargando = false;
      });
    } catch (e) {
      print('Error cargando rutinas: $e');
      setState(() {
        _cargando = false;
      });
    }
  }

  void _mostrarMenuNivel() async {
    final seleccion = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 120, 10, 0),
      items: [
        const PopupMenuItem(value: 'Todos', child: Text('Todos los niveles')),
        const PopupMenuItem(value: 'Principiante', child: Text('Principiante')),
        const PopupMenuItem(value: 'Intermedio', child: Text('Intermedio')),
        const PopupMenuItem(value: 'Avanzado', child: Text('Avanzado')),
      ],
    );

    if (seleccion != null) {
      setState(() {
        nivelSeleccionado = seleccion;
      });
    }
  }

  Color _obtenerColorNivel(String? nivel) {
    switch (nivel) {
      case 'Principiante':
        return Colors.green;
      case 'Intermedio':
        return Colors.orange;
      case 'Avanzado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  RutinaDetalle _convertirARutinaDetalle(Rutina rutina) {
    return RutinaDetalle(
      id: rutina.idRutina,
      nombre: rutina.nombre,
      descripcion: rutina.descripcion,
      imagenUrl: rutina.imagen ?? '',
      nivel: rutina.tipo,
      completada: false,
      ejercicios: rutina.ejercicios.map((e) {
        return EjercicioRutina(
          id: e.idEjercicio,
          nombre: e.nombre,
          descripcion: e.descripcion,
          imagenUrl: e.imagen ?? '',
          series: e.series ?? 3,
          repeticiones: e.repeticiones ?? 10,
          duracionEstimada: 60,
          pesoRecomendado: null,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rutinasFiltradas = nivelSeleccionado == 'Todos'
        ? _rutinas
        : _rutinas.where((r) => r.tipo == nivelSeleccionado).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas Generales'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarMenuNivel,
            tooltip: 'Filtrar por nivel',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rutinasFiltradas.length,
              itemBuilder: (context, index) {
                final rutina = rutinasFiltradas[index];
                final rutinaDetalle = _convertirARutinaDetalle(rutina);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleRutinaScreen(rutina: rutinaDetalle),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rutina.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Chip(
                                backgroundColor: _obtenerColorNivel(rutina.tipo),
                                label: Text(
                                  rutina.tipo,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(rutina.descripcion),
                          const SizedBox(height: 10),
                          rutina.imagen != null && rutina.imagen!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    rutina.imagen!,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 160,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.fitness_center, size: 50),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.fitness_center, size: 50),
                                ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetalleRutinaScreen(rutina: rutinaDetalle),
                                ),
                              );
                            },
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Ver detalles'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: HealthuBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
