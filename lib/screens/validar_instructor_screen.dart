import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:healthu/services/rutina_service.dart';
import 'package:healthu/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthu/screens/home inicio/home_screen.dart';

class ValidarInstructorScreen extends StatefulWidget {
  final String rutinaId;
  final int idDesafioRealizado;

  const ValidarInstructorScreen({
    super.key,
    required this.rutinaId,
    required this.idDesafioRealizado,
  });

  @override
  State<ValidarInstructorScreen> createState() =>
      _ValidarInstructorScreenState();
}

class _ValidarInstructorScreenState extends State<ValidarInstructorScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isValidating = false;
  Usuario? _usuario;
  DateTime? _lastValidationTime;
  int _scanCount = 0;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final nombre = prefs.getString('nombre') ?? 'Usuario';
    final fotoUrl = prefs.getString('fotoUrl') ?? '';
    final nivelActual = prefs.getString('nivelActual') ?? 'Principiante';

    setState(() {
_usuario = Usuario(
  id: 0,   // ✅ int
  nombre: nombre,
  email: email ?? '',
  fotoUrl: fotoUrl,
  nivelActual: nivelActual,
);

    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _validateQRCode(String qrData) async {
    _scanCount++;
    debugPrint(' Escaneo número: $_scanCount');

    //  throttle: no dejar validar más de 1 QR cada 5 segundos
    if (_lastValidationTime != null &&
        DateTime.now().difference(_lastValidationTime!) <
            const Duration(seconds: 5)) {
      debugPrint(' Ignorado: ya se validó un QR hace menos de 5 segundos');
      return;
    }

    if (_isValidating) {
      debugPrint('Ya se está validando, espera...');
      return;
    }

    setState(() {
      _isValidating = true;
      _lastValidationTime = DateTime.now();
    });

    try {
      await cameraController.stop();

      final idDesafio = widget.idDesafioRealizado;
      debugPrint(
          '📤 Enviando al backend -> codigoQR="$qrData", idDesafioRealizado=$idDesafio');

      final resultado = await RutinaService.validarQR(
        codigoQR: qrData, // tal cual, sin parseo
        idDesafioRealizado: idDesafio,
      );

      if (!mounted) return;

      if (resultado != null && resultado.containsKey('caloriasTotales')) {
        debugPrint(' Validación exitosa: $resultado');

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Validación exitosa'),
            content: Text(resultado['mensaje']?.toString() ?? '¡Buen trabajo!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        if (_usuario != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  HomeScreen(usuario: _usuario!, indiceInicial: 2),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        //  Error desde backend
        final errorMsg =
            resultado?['mensaje']?.toString() ?? 'QR inválido. Intenta nuevamente.';
        debugPrint(' Error backend: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint(' Error al validar QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error de conexión: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
        await Future.delayed(const Duration(milliseconds: 500));
        await cameraController.start();
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
                return Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: state == TorchState.on ? Colors.yellow : Colors.grey,
                );
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                return Icon(
                  state == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                );
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
              for (final barcode in capture.barcodes) {
                final raw = barcode.rawValue;
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
                color: Colors.black.withValues(alpha: 0.5),
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
