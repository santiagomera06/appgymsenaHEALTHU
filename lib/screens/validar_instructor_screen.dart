import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// ignore: unused_import
import 'package:lottie/lottie.dart';
import 'package:healthu/services/rutina_service.dart';
import 'package:healthu/screens/rutinas/actualizar_progreso.dart'; // Asegúrate de importar esta pantalla

class ValidarInstructorScreen extends StatefulWidget {
  final String rutinaId;

  const ValidarInstructorScreen({
    super.key,
    required this.rutinaId,
  });

  @override
  State<ValidarInstructorScreen> createState() => _ValidarInstructorScreenState();
}

class _ValidarInstructorScreenState extends State<ValidarInstructorScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isValidating = false;
  bool _qrScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _validateQRCode(String qrData) async {
    if (_isValidating || _qrScanned) return;

    setState(() => _isValidating = true);

    try {
      final isValid = await RutinaService.validarQRInstructor(
        rutinaId: widget.rutinaId,
        qrCode: qrData,
      );

      if (isValid) {
        setState(() => _qrScanned = true);

        // TODO: Reemplazar estos valores con datos reales
        const String desafioId = 'id_del_desafio_actual';
        const String userId = 'id_del_usuario';
        const int puntosGanados = 100;

        // Mostrar pantalla de progreso
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActualizarProgreso(
              desafioId: desafioId,
              userId: userId,
              puntosGanados: puntosGanados,
            ),
          ),
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context, true); // Retornar éxito
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código QR no válido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
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
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _validateQRCode(barcode.rawValue!);
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
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
