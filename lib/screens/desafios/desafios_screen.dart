import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
    _cargarDesafios();
  }

  Future<void> _cargarDesafios() async {
    final desafiosBase = <Desafio>[
      Desafio(id: '1', nombre: 'Desafio 1', descripcion: 'Rutina básica para principiantes', desbloqueado: true, completado: false, ejerciciosIds: ['1', '2', '3']),
      Desafio(id: '2', nombre: 'Desafio 2', descripcion: 'Rutina intermedia', desbloqueado: false, completado: false, ejerciciosIds: ['4', '5', '6']),
      Desafio(id: '3', nombre: 'Desafio 3', descripcion: 'Rutina avanzada', desbloqueado: false, completado: false, ejerciciosIds: ['7', '8', '9']),
      Desafio(id: '4', nombre: 'Desafio 4', descripcion: 'Rutina experta', desbloqueado: false, completado: false, ejerciciosIds: ['10', '11', '12']),
      Desafio(id: '5', nombre: 'Desafio 5', descripcion: 'Rutina expertaa', desbloqueado: false, completado: false, ejerciciosIds: ['10', '11', '12']),
      Desafio(id: '6', nombre: 'Desafio 6', descripcion: 'Rutina expertaa', desbloqueado: false, completado: false, ejerciciosIds: ['10', '11', '12']),
      Desafio(id: '7', nombre: 'Desafio 7', descripcion: 'Rutina expertaa', desbloqueado: true, completado: false, ejerciciosIds: ['10', '11', '12']),
      Desafio(id: '8', nombre: 'Desafio 8', descripcion: 'Rutina expertaa', desbloqueado: false, completado: false, ejerciciosIds: ['10', '11', '12']),
    ];

    final cargados = await DesafiosRoutes.cargarProgresoDesafios(desafiosBase);
    setState(() {
      desafios = cargados;
      isLoading = false;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToLastUnlocked();
  }

  void _scrollToLastUnlocked() {
    final index = desafios.lastIndexWhere((d) => d.desbloqueado && !d.completado);
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

  Future<void> _procesarRutinaCompletada(String desafioId) async {
    // Mostrar animación de desbloqueo
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/unlock.json',
              width: 200,
              height: 200,
            ),
            const Text(
              '¡Desafío completado!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    // Actualizar localmente
    setState(() {
      final index = desafios.indexWhere((d) => d.id == desafioId);
      if (index != -1) {
        desafios[index] = desafios[index].copyWith(completado: true);
        if (index < desafios.length - 1) {
          desafios[index + 1] = desafios[index + 1].copyWith(desbloqueado: true);
        }
      }
    });

    // Actualizar en backend
    try {
      await DesafioService.marcarDesafioCompletado(desafioId);
      await DesafioService.desbloquearSiguienteDesafio(desafioId);
      await DesafioService.actualizarPuntuacion('user123', 100);
      setState(() => puntuacionActual += 100);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Progreso actualizado correctamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar progreso: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Santiago Mera', style: TextStyle(fontSize: 16, color: Colors.black)),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navegarACrearRutina,
            tooltip: 'Crear nueva rutina',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPuntuacionYObjetivoRow(),
            const SizedBox(height: 20),
            _buildDesafiosGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildPuntuacionYObjetivoRow() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text('Puntuación'),
                  Text(puntuacionActual.toString()),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text('Objetivo'),
                  Text(objetivo.toString()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesafiosGrid() {
    return GridView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: desafios.length,
      itemBuilder: (context, index) {
        final d = desafios[index];
        final isTapped = _tappedIndex == index;

        return GestureDetector(
          onTap: () async {
            if (!d.desbloqueado) {
              _mostrarMensaje('Debes completar el desafío anterior.');
              return;
            }

            setState(() => _tappedIndex = index);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RutinasGenerales()),
            );

            setState(() => _tappedIndex = null);
            if (result == true) {
              await _procesarRutinaCompletada(d.id);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            transform: (isTapped ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity()),
            decoration: BoxDecoration(
              border: Border.all(color: d.desbloqueado ? Colors.orange : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: isTapped
                  ? [const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]
                  : [],
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEstadoIcono(d),
                const SizedBox(height: 6),
                Text(d.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    d.descripcion,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEstadoIcono(Desafio d) {
    if (d.completado) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 28);
    } else if (d.desbloqueado) {
      return const Icon(Icons.lock_open, color: Colors.orangeAccent, size: 28);
    } else {
      return Icon(Icons.lock, color: Colors.grey.withOpacity(0.5), size: 28);
    }
  }
}
