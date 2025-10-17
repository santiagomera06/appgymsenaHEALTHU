import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthu/services/frecuencia_service.dart';


class MedicionFrecuenciaScreen extends StatefulWidget {
  const MedicionFrecuenciaScreen({super.key});

  @override
  State<MedicionFrecuenciaScreen> createState() =>
      _MedicionFrecuenciaScreenState();
}

class _MedicionFrecuenciaScreenState extends State<MedicionFrecuenciaScreen> {
  int? bpm;
  List<SensorValue> data = [];
  int secondsLeft = 40; // ✅ Cambiado a 40 segundos
  bool measuring = false;
  Timer? _timer;
  bool _cameraInitialized = false;
  
  // 🔹 NUEVAS VARIABLES PARA MEJOR PRECISIÓN
  List<int> stableBpmReadings = [];
  String signalQuality = 'Coloca tu dedo en la cámara';
  double signalStrength = 0.0;
  
  bool isSignalStable = false;
  int consecutiveStableReadings = 0;
  int requiredStableReadings = 3;

  // NUEVO: Método mejorado para iniciar medición
  void _startMeasurement() async {
    if (measuring) return;
    
    // Resetear estado primero
    setState(() {
      measuring = true;
      secondsLeft = 40; //  40 segundos
      bpm = null;
      data.clear();
      stableBpmReadings.clear();
      signalQuality = 'Inicializando cámara...';
      signalStrength = 0.0;
      isSignalStable = false;
      consecutiveStableReadings = 0;
      _cameraInitialized = false;
    });

    //  Pequeño delay para permitir que la UI se actualice
    await Future.delayed(const Duration(milliseconds: 100));

    // Inicializar cámara de forma asíncrona
    _initializeCameraAsync();
  }

  //  NUEVO: Inicialización asíncrona de la cámara
  void _initializeCameraAsync() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      setState(() {
        _cameraInitialized = true;
        signalQuality = 'Buscando señal...';
      });
      
      // Iniciar timer después de que la cámara esté lista
      _startMeasurementTimer();
    });
  }

  // NUEVO: Timer mejorado para 40 segundos
  void _startMeasurementTimer() {
    _timer?.cancel(); // Cancelar timer previo si existe
    
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      
      setState(() => secondsLeft--);
      
      if (secondsLeft <= 0) {
        t.cancel();
        _finishMeasurement();
      }
    });
  }

  // NUEVO: Finalizar medición de forma segura
void _finishMeasurement() async {
  if (!mounted) return;

  setState(() => measuring = false);
  _calculateFinalBPM();

  if (bpm != null) {
    try {
      await FrecuenciaService.guardarFrecuenciaCardiaca(bpm!);
      if (!mounted) return;

      //  Mostrar SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.favorite, color: Colors.white),
              SizedBox(width: 10),
              Text("Frecuencia cardíaca guardada correctamente"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      debugPrint('✅ Frecuencia ${bpm!} BPM enviada al backend');
    } catch (e) {
      debugPrint('⚠️ Error enviando frecuencia: $e');

      // ❌ Mostrar error visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text("Error al guardar la frecuencia cardíaca"),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future.delayed(const Duration(milliseconds: 500), () {
    if (mounted) {
      _showResultDialog();
    }
  });
}
  // 🔹 NUEVO: Cálculo de BPM final más preciso
  void _calculateFinalBPM() {
    if (stableBpmReadings.isEmpty) {
      bpm = null;
      return;
    }

    // Filtrar valores extremos (fuera de rango humano normal)
    final validReadings = stableBpmReadings.where((reading) => 
        reading >= 40 && reading <= 200).toList();

    if (validReadings.isEmpty) {
      bpm = null;
      return;
    }

    // Calcular promedio de lecturas estables
    final sum = validReadings.reduce((a, b) => a + b);
    bpm = (sum / validReadings.length).round();
  }

  // 🔹 NUEVO: Análisis de calidad de señal en tiempo real
  void _analyzeSignalQuality() {
    if (data.length < 20) {
      setState(() {
        signalQuality = 'Mueve lentamente el dedo sobre la cámara';
        signalStrength = data.length / 20;
      });
      return;
    }

    // Calcular amplitud de la señal
    final values = data.map((v) => v.value).toList();
    final maxVal = values.reduce(max);
    final minVal = values.reduce(min);
    final amplitude = maxVal - minVal;

    // Calcular varianza para detectar ruido
    final mean = values.reduce((a, b) => a + b) / values.length;
    double variance = 0;
    for (var value in values) {
      variance += pow(value - mean, 2);
    }
    variance /= values.length;

    // 🔹 Evaluar calidad de señal
    if (amplitude < 5) {
      setState(() {
        signalQuality = 'Señal débil. Presiona más el dedo';
        signalStrength = amplitude / 10;
        isSignalStable = false;
      });
    } else if (variance > 50) {
      setState(() {
        signalQuality = 'Mucho movimiento. Mantén la mano quieta';
        signalStrength = 0.3;
        isSignalStable = false;
      });
    } else if (amplitude > 20 && variance < 10) {
      setState(() {
        signalQuality = 'Señal excelente ✓';
        signalStrength = 1.0;
        isSignalStable = true;
      });
    } else {
      setState(() {
        signalQuality = 'Señal aceptable';
        signalStrength = 0.7;
        isSignalStable = true;
      });
    }
  }

  // 🔹 NUEVO: Validación de lecturas de BPM
  bool _isValidBPMReading(int newBpm) {
    // Rango fisiológico razonable
    if (newBpm < 40 || newBpm > 200) return false;
    
    // Si ya tenemos lecturas previas, verificar consistencia
    if (stableBpmReadings.isNotEmpty) {
      final average = stableBpmReadings.reduce((a, b) => a + b) / stableBpmReadings.length;
      // Permitir variación máxima de 20 BPM respecto al promedio
      if ((newBpm - average).abs() > 20) return false;
    }
    
    return true;
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Resultado de la Medición"),
        content: bpm != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite, 
                    color: _getBpmColor(bpm!), 
                    size: 64
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Tu frecuencia cardíaca es:",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$bpm BPM",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _getBpmColor(bpm!),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Basado en ${stableBpmReadings.length} lecturas estables",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  _getBpmInterpretation(bpm!),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.orange, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    "No se pudo obtener una medición confiable",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Consejos:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "• Presiona firmemente el dedo\n"
                    "• Mantén la mano quieta\n"
                    "• Evita cambios de luz\n"
                    "• Medición de 40 segundos para mayor precisión", // ✅ Actualizado
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Aceptar"),
          ),
          if (bpm == null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startMeasurement();
              },
              child: const Text("Reintentar"),
            ),
        ],
      ),
    );
  }

  // 🔹 NUEVO: Color según rango de BPM
  Color _getBpmColor(int bpm) {
    if (bpm < 60) return Colors.blue;
    if (bpm >= 60 && bpm <= 100) return Colors.green;
    if (bpm <= 120) return Colors.orange;
    return Colors.red;
  }

  // 🔹 NUEVO: Interpretación del resultado
  Widget _getBpmInterpretation(int bpm) {
    String text;
    Color color;
    
    if (bpm < 60) {
      text = "Frecuencia baja (Bradicardia)";
      color = Colors.blue;
    } else if (bpm <= 100) {
      text = "Frecuencia normal";
      color = Colors.green;
    } else if (bpm <= 120) {
      text = "Frecuencia elevada";
      color = Colors.orange;
    } else {
      text = "Frecuencia alta (Taquicardia)";
      color = Colors.red;
    }
    
    return Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medición de Frecuencia Cardíaca"),
        backgroundColor: Colors.red[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (measuring && _cameraInitialized) // ✅ Solo mostrar cuando la cámara esté lista
              HeartBPMDialog(
                context: context,
                onRawData: (value) {
                  if (!mounted) return;
                  
                  setState(() {
                    data.add(value);
                    // ✅ Limitar datos para evitar sobrecarga
                    if (data.length > 80) data.removeAt(0);
                  });
                  
                  _analyzeSignalQuality();
                  debugPrint("RAW >> index=${data.length} : y=${value.value}");
                },
                onBPM: (value) {
                  if (!mounted) return;
                  
                  if (value > 0 && _isValidBPMReading(value) && isSignalStable) {
                    consecutiveStableReadings++;
                    
                    // 🔹 Solo aceptar lectura después de múltiples lecturas estables
                    if (consecutiveStableReadings >= requiredStableReadings) {
                      setState(() {
                        stableBpmReadings.add(value);
                        bpm = value;
                      });
                      debugPrint("❤️ BPM estable detectado: $value");
                    }
                  } else {
                    consecutiveStableReadings = 0;
                  }
                },
              ),
            
            if (measuring && !_cameraInitialized) // ✅ Mostrar loading mientras inicializa
              const CircularProgressIndicator(),

            const SizedBox(height: 20),

            // 🔹 MEJORADO: Gráfico con indicador de calidad
            _buildChartWithQuality(),

            const SizedBox(height: 20),

            // 🔹 MEJORADO: Información de medición
            _buildMeasurementInfo(),

            const SizedBox(height: 20),

            // 🔹 MEJORADO: Botón con validación
            ElevatedButton.icon(
              onPressed: measuring ? null : _startMeasurement,
              icon: Icon(
                measuring ? Icons.timer : Icons.monitor_heart,
                color: measuring ? Colors.grey : Colors.white,
              ),
              label: Text(
                // ✅ Actualizado a 40 segundos
                measuring ? "Midiendo... $secondsLeft s" : "Iniciar medición (40 segundos)",
                style: TextStyle(color: measuring ? Colors.grey : Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 NUEVO: Gráfico con indicador de calidad visual
  Widget _buildChartWithQuality() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          width: double.infinity,
          child: _buildChart(),
        ),
        const SizedBox(height: 10),
        
        // Indicador de calidad de señal
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSignalStable ? Icons.check_circle : Icons.warning,
              color: isSignalStable ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              signalQuality,
              style: TextStyle(
                color: isSignalStable ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        // Barra de progreso de fuerza de señal
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: signalStrength.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: _getSignalColor(signalStrength),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getSignalColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  // 🔹 MEJORADO: Información de medición
  Widget _buildMeasurementInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          if (bpm != null && measuring)
            Text(
              "Lectura actual: $bpm BPM",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            )
          else if (measuring)
            Text(
              "Analizando señal... $secondsLeft s", //  Ahora muestra 40s inicialmente
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            )
          else
            const Text(
              "Medición de 40 segundos para mayor precisión", 
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          
          if (!measuring) ...[
            const SizedBox(height: 8),
            const Text(
              "• Cubre completamente la cámara con tu dedo\n"
              "• Mantén la mano apoyada y quieta\n"
              "• Evita hablar o moverte durante 40 segundos\n" 
              "• Asegura buena iluminación ambiente",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
          
          if (measuring && stableBpmReadings.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Lecturas estables: ${stableBpmReadings.length}",
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  /// Gráfico desplazándose en vivo (mejorado)
  Widget _buildChart() {
    if (data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text("Esperando señal del dedo..."),
          ],
        ),
      );
    }

    final points = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble()))
        .toList();

    final ys = points.map((p) => p.y).toList();
    final yMin = ys.reduce((a, b) => a < b ? a : b);
    final yMax = ys.reduce((a, b) => a > b ? a : b);
    final pad = ((yMax - yMin).abs() * 0.1) + 1e-6;

    return LineChart(
      LineChartData(
        minY: yMin - pad,
        maxY: yMax + pad,
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: isSignalStable ? Colors.green : Colors.red,
            barWidth: isSignalStable ? 3 : 2,
            dotData: FlDotData(show: false),
            spots: points,
          ),
        ],
      ),
    );
  }
}