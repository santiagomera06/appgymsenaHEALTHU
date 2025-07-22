import 'package:flutter/material.dart';
import 'package:healthu/models/desafio_model.dart';
import 'package:healthu/routes/desafios_routes.dart';
import 'package:healthu/routes/crear_rutina_routes.dart';
import 'package:healthu/screens/rutinas/rutinas_generales.dart';
import 'package:healthu/services/desafio_service.dart';

class DesafiosScreen extends StatefulWidget {
  const DesafiosScreen({super.key});

  @override
  State<DesafiosScreen> createState() => _DesafiosScreenState();
}

class _DesafiosScreenState extends State<DesafiosScreen> {
  int puntuacionActual = 2500;
  final int objetivo = 5000;
  List<Desafio> desafios = [];
  bool isLoading = true;
  int? _tappedIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        _cargarDesafios();
      }
    });
  }

  Future<void> _cargarDesafios() async {
    try {
      final desafioActual = await DesafioService.obtenerDesafioActual();

      if (desafioActual != null) {
        if (desafioActual['mensaje'] != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mostrarMensaje('¡Primer desafío inicializado automáticamente!');
          });
        }

        await _integrarDesafioDelBackend(desafioActual);
      }

      final List<Desafio> desafiosBase = [
        Desafio(
          id: '1',
          nombre: 'Desafio 1',
          descripcion: 'Rutina principiante',
          desbloqueado: true,
          completado: false,
          ejerciciosIds: ['1', '2', '3'],
        ),
        Desafio(
          id: '2',
          nombre: 'Desafio 2',
          descripcion: 'Rutina principiante',
          desbloqueado: false,
          completado: false,
          ejerciciosIds: ['4', '5', '6'],
        ),
        Desafio(
          id: '3',
          nombre: 'Desafio 3',
          descripcion: 'Rutina intermedio',
          desbloqueado: false,
          completado: false,
          ejerciciosIds: ['7', '8', '9'],
        ),
        Desafio(
          id: '4',
          nombre: 'Desafio 4',
          descripcion: 'Rutina intermedio',
          desbloqueado: false,
          completado: false,
          ejerciciosIds: ['10', '11', '12'],
        ),
        Desafio(
          id: '5',
          nombre: 'Desafio 5',
          descripcion: 'Rutina avanzada',
          desbloqueado: false,
          completado: false,
          ejerciciosIds: ['1', '2', '3'],
        ),
        Desafio(
          id: '6',
          nombre: 'Desafio 6',
          descripcion: 'Rutina avanzada',
          desbloqueado: false,
          completado: false,
          ejerciciosIds: ['4', '5', '6'],
        ),
        Desafio(
          id: '7',
          nombre: 'Desafio 7',
          descripcion: 'Rutina expertaa',
          desbloqueado: true,
          completado: false,
          ejerciciosIds: ['10', '11', '12'],
        ),
        Desafio(
          id: '8',
          nombre: 'Desafio 8',
          descripcion: 'Rutina expertaa',
          desbloqueado: false,
          completado: false,
          ejerciciosIds: ['10', '11', '12'],
        ),
      ];

      final cargados = await DesafiosRoutes.cargarProgresoDesafios(
        desafiosBase,
      );
      setState(() {
        desafios = cargados;
        isLoading = false;
      });
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _scrollToLastUnlocked();
      }
    } catch (e) {
      print(' Error cargando desafíos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _integrarDesafioDelBackend(
    Map<String, dynamic> desafioBackend,
  ) async {
    try {
      final numeroDesafio = desafioBackend['numeroDesafio'] as int?;
      final estadoDesafio = desafioBackend['estadoDesafio'] as String?;
      final puntosAcumulados = desafioBackend['puntosAcumulados'] as int? ?? 0;

      if (puntosAcumulados > 0) {
        setState(() {
          puntuacionActual = puntosAcumulados;
        });
      }

      if (estadoDesafio == 'En progreso') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mostrarMensaje('Tienes el Desafío $numeroDesafio en progreso');
        });
      }
    } catch (e) {
      print(' Error integrando datos del backend: $e');
    }
  }

  Future<void> _probarRegistrarProgreso() async {
    try {
      _mostrarMensaje('📈 Probando registrar progreso...');

      const int idRutina = 1;
      const int idDesafioRealizado = 3;

      final resultado = await DesafioService.registrarProgreso(
        idRutina: idRutina,
        idDesafioRealizado: idDesafioRealizado,
      );

      if (resultado != null) {
        _mostrarMensaje(' ¡Progreso registrado correctamente!');
      } else {
        _mostrarMensaje(' No se pudo registrar el progreso');
      }
    } catch (e) {
      print(' Error en prueba de progreso: $e');
      _mostrarMensaje(' Error: $e');
    }
  }

  void _scrollToLastUnlocked() {
    if (!_scrollController.hasClients) return;

    final index = desafios.lastIndexWhere(
      (d) => d.desbloqueado && !d.completado,
    );
    if (index != -1) {
      _scrollController.animateTo(
        (index ~/ 3) * 150.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
    );
  }

  void _navegarACrearRutina() {
    Navigator.pushNamed(context, CrearRutinaRoutes.crearRutina);
  }

  @override
  Widget build(BuildContext context) {
    final porcentaje = (puntuacionActual / objetivo).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        title: const Text(
          'Desafíos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _probarRegistrarProgreso,
            icon: const Icon(Icons.analytics, color: Colors.green),
            tooltip: 'Probar Registrar Progreso',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                ),
              )
              : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Barra de progreso
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progreso Semanal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$puntuacionActual/$objetivo',
                                style: const TextStyle(
                                  color: Color(0xFF007AFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: porcentaje,
                            backgroundColor: const Color(0xFF3A3A3C),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF007AFF),
                            ),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(porcentaje * 100).toInt()}% completado',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón de crear rutina
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navegarACrearRutina,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Crear Rutina Personal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grid de desafíos
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: desafios.length,
                      itemBuilder: (context, index) {
                        final desafio = desafios[index];
                        final isPressed = _tappedIndex == index;

                        return GestureDetector(
                          onTapDown:
                              (_) => setState(() => _tappedIndex = index),
                          onTapUp: (_) => setState(() => _tappedIndex = null),
                          onTapCancel:
                              () => setState(() => _tappedIndex = null),
                          onTap:
                              desafio.desbloqueado
                                  ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const RutinasGenerales(),
                                      ),
                                    );
                                  }
                                  : null,
                          child: AnimatedScale(
                            scale: isPressed ? 0.95 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    desafio.completado
                                        ? const Color(0xFF34C759)
                                        : desafio.desbloqueado
                                        ? const Color(0xFF2C2C2E)
                                        : const Color(0xFF1C1C1E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      desafio.completado
                                          ? const Color(0xFF34C759)
                                          : desafio.desbloqueado
                                          ? const Color(0xFF3A3A3C)
                                          : Colors.grey.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow:
                                    desafio.desbloqueado
                                        ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    desafio.completado
                                        ? Icons.check_circle
                                        : desafio.desbloqueado
                                        ? Icons.fitness_center
                                        : Icons.lock,
                                    color:
                                        desafio.completado
                                            ? Colors.white
                                            : desafio.desbloqueado
                                            ? const Color(0xFF007AFF)
                                            : Colors.grey,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    desafio.nombre,
                                    style: TextStyle(
                                      color:
                                          desafio.desbloqueado
                                              ? Colors.white
                                              : Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    desafio.descripcion,
                                    style: TextStyle(
                                      color:
                                          desafio.desbloqueado
                                              ? Colors.grey
                                              : Colors.grey.withOpacity(0.5),
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
