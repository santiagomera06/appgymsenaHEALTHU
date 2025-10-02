import 'package:flutter/material.dart';
import 'package:healthu/models/desafio_model.dart';
import 'package:healthu/screens/rutinas/rutinas_generales.dart';
import 'package:healthu/services/desafio_service.dart';

class DesafiosScreen extends StatefulWidget {
  const DesafiosScreen({super.key});

  @override
  State<DesafiosScreen> createState() => _DesafiosScreenState();
}

class _DesafiosScreenState extends State<DesafiosScreen> {
  int puntuacionActual = 0;
  final int objetivo = 5000;
  List<Desafio> desafios = [];
  int? _tappedIndex;
  final ScrollController _scrollController = ScrollController();

  late Future<void> _futureDesafios; // Future para que solo cargue una vez

  @override
  void initState() {
    super.initState();
    _futureDesafios = _cargarDesafios(); //se guarda y se reutiliza
  }

  Future<void> _cargarDesafios() async {
    try {
      print("Ejecutando _cargarDesafios()");

      final desafioActual = await DesafioService.obtenerDesafioActual();
      print("Desafío actual recibido: $desafioActual");

      final listaUsuario = await DesafioService.obtenerDesafiosPorUsuario();
      print(" Lista de desafíos del usuario: $listaUsuario");

final List<Desafio> desafiosBase = [
  Desafio(id: '1', nombre: 'Desafio 1', desbloqueado: false, completado: false),
  Desafio(id: '2', nombre: 'Desafio 2', desbloqueado: false, completado: false),
  Desafio(id: '3', nombre: 'Desafio 3', desbloqueado: false, completado: false),
  Desafio(id: '4', nombre: 'Desafio 4', desbloqueado: false, completado: false),
  Desafio(id: '5', nombre: 'Desafio 5', desbloqueado: false, completado: false),
  Desafio(id: '6', nombre: 'Desafio 6', desbloqueado: false, completado: false),
  Desafio(id: '7', nombre: 'Desafio 7', desbloqueado: false, completado: false),
  Desafio(id: '8', nombre: 'Desafio 8', desbloqueado: false, completado: false),
];


      // Marcar desafíos desbloqueados / completados
      for (var d in listaUsuario) {
        final numero = d['idDesafio'] as int?;
        final estado = (d['estado'] ?? '').toString().toLowerCase();

        if (numero != null && numero <= desafiosBase.length) {
          final idx = numero - 1;

          desafiosBase[idx] = desafiosBase[idx].copyWith(
            desbloqueado: true,
            completado: estado == 'completado' || estado == 'finalizado',
          );
        }
      }

      if (desafioActual != null && desafioActual['puntosAcumulados'] != null) {
        puntuacionActual = desafioActual['puntosAcumulados'];
      }

      desafios = desafiosBase;

      // 🔹 esperar un poco y luego scrollear al último desbloqueado
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) _scrollToLastUnlocked();
    } catch (e) {
      print(' Error cargando desafíos: $e');
    }
  }

  void _scrollToLastUnlocked() {
    if (!_scrollController.hasClients) return;
    final index = desafios.lastIndexWhere((d) => d.desbloqueado && !d.completado);
    if (index != -1) {
      _scrollController.animateTo(
        (index ~/ 3) * 150.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body: FutureBuilder(
        future: _futureDesafios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
              ),
            );
          }

          return SingleChildScrollView(
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

                // Grid de desafíos
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      onTapDown: (_) => setState(() => _tappedIndex = index),
                      onTapUp: (_) => setState(() => _tappedIndex = null),
                      onTapCancel: () => setState(() => _tappedIndex = null),
                      onTap: desafio.desbloqueado
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RutinasGenerales(),
                                ),
                              );
                            }
                          : null,
                      child: AnimatedScale(
                        scale: isPressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          decoration: BoxDecoration(
                            color: desafio.completado
                                ? const Color(0xFF34C759)
                                : desafio.desbloqueado
                                    ? const Color(0xFF2C2C2E)
                                    : const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: desafio.completado
                                  ? const Color(0xFF34C759)
                                  : desafio.desbloqueado
                                      ? const Color(0xFF3A3A3C)
                                      : Colors.grey.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    desafio.desbloqueado
                                        ? Icons.fitness_center
                                        : Icons.lock,
                                    color: desafio.completado
                                        ? Colors.white
                                        : desafio.desbloqueado
                                            ? const Color(0xFF007AFF)
                                            : Colors.grey,
                                    size: 32,
                                  ),
                                  if (desafio.completado)
                                    const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.greenAccent,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                desafio.nombre,
                                style: TextStyle(
                                  color: desafio.desbloqueado
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
                                  color: desafio.desbloqueado
                                      ? Colors.grey
                                      : Colors.grey.withValues(alpha: 0.5),
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
