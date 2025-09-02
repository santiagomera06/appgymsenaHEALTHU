import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:healthu/services/rutina_service.dart';

class ValidarInstructorScreen extends StatefulWidget {
  // ignore: unused_field
  final String rutinaId; // se mantiene para no romper navegaciones existentes

  const ValidarInstructorScreen({
    super.key,
    required this.rutinaId,
  });

  @override
  State<ValidarInstructorScreen> createState() => _ValidarInstructorScreenState();
}

class _ValidarInstructorScreenState extends State<ValidarInstructorScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isValidating = false;
  bool _qrScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _validateQRCode(String qrData) async {
    if (_isValidating || _qrScanned) return;

    setState(() {
      _isValidating = true;
      _qrScanned = true; // evita múltiples lecturas
    });

    try {
      await cameraController.stop(); // detén la cámara mientras validas

      // ✅ Nuevo servicio: solo mandamos el código QR (sin bearer)
      final ok = await RutinaService.validarQRInstructor(
        qrCode: qrData.trim(),
      );

      if (!mounted) return;

      if (ok) {
        // Diálogo de éxito
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Validación exitosa'),
            content: const Text(
              'La rutina fue validada por el instructor. ¡Buen trabajo!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );

        // Salir al inicio (ajusta si prefieres otra pantalla)
        if (!mounted) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // Reintento
        setState(() => _qrScanned = false);
        await cameraController.start();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código QR no válido. Intenta nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _qrScanned = false);
      await cameraController.start();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar con Instructor'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              for (final b in capture.barcodes) {
                final raw = b.rawValue;
                if (raw != null) {
                  debugPrint('QR leído: $raw');
                  _validateQRCode(raw);
                  break;
                }
              }
            },
          ),
          if (_isValidating)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Escanea el código QR del instructor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
