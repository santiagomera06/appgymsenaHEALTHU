import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:healthu/services/pulse_service.dart';

class MedicionFrecuenciaScreen extends StatefulWidget {
  const MedicionFrecuenciaScreen({Key? key}) : super(key: key);

  @override
  State<MedicionFrecuenciaScreen> createState() =>
      _MedicionFrecuenciaScreenState();
}

class _MedicionFrecuenciaScreenState extends State<MedicionFrecuenciaScreen> {
  CameraController? _controller;
  bool _measuring = false;
  int? _bpm;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prepareCamera();
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  Future<void> _prepareCamera() async {
    try {
      if (!await _requestCameraPermission()) {
        if (mounted) setState(() => _error = 'Permiso de cámara denegado');
        return;
      }
      final back = (await availableCameras())
          .firstWhere((c) => c.lensDirection == CameraLensDirection.back);

      _controller =
          CameraController(back, ResolutionPreset.low, enableAudio: false);
      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.torch);
      if (mounted) setState(() {}); 
    } catch (e) {
      if (mounted) setState(() => _error = 'Error al inicializar cámara: $e');
    }
  }

  Future<bool> _requestCameraPermission() async =>
      (await Permission.camera.request()).isGranted;

  Future<void> _disposeCamera() async {
    final old = _controller;
    _controller = null;
    if (mounted) setState(() {});              
    await old?.dispose();
  }

//medicion

  Future<void> _iniciarMedicion() async {
    if (_measuring) return;

    if (_controller == null) await _prepareCamera();
    if (_controller == null) return;

    await _controller!.setFlashMode(FlashMode.torch);

    if (!mounted) return;
    setState(() {
      _measuring = true;
      _error = null;
      _bpm = null;  // limpia resultado previo
    });

    try {
      final r = await PulseService()
          .measurePulse(controller: _controller!, durationSeconds: 8);

      if (!mounted) return;                   
      if (r == null) {
        setState(() {
          _error = 'No se detectaron pulsaciones suficientes.';
          _bpm = null;
        });
      } else {
        setState(() {
          _bpm = r;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _bpm = null;
        });
      }
    } finally {
      if (mounted) setState(() => _measuring = false);
      await _disposeCamera();
    }
  }



  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Medición de Frecuencia')),
        body: Center(child: _buildBody()),
      );

  Widget _buildBody() {
    if (_measuring) return _buildMeasuring();
    if (_error != null) return _buildError();
    if (_bpm != null) return _buildResult();
    if (_controller == null) return _buildIdle();
    return _buildReady();
  }

  Widget _buildMeasuring() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_controller != null) _buildPreview(),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('Midiendo…  !     por favor colocar  el dedo anular o medio  debe tapara toda la camara '),
        ],
      );

  Widget _buildResult() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Tu pulso: $_bpm BPM',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _iniciarMedicion,
            child: const Text('Medir de nuevo'),
          ),
        ],
      );

  Widget _buildError() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _iniciarMedicion,
            child: const Text('Intentar de nuevo'),
          ),
        ],
      );

  Widget _buildIdle() => ElevatedButton(
        onPressed: _iniciarMedicion,
        child: const Text('Iniciar medición'),
      );

  Widget _buildReady() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPreview(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _iniciarMedicion,
            child: const Text('Iniciar medición'),
          ),
        ],
      );

  Widget _buildPreview() {
    if (_controller == null) return const SizedBox.shrink();
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: CameraPreview(_controller!),
    );
  }
}
