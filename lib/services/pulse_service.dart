
import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';


class _Sample {
  final DateTime time;
  final double value;
  _Sample(this.time, this.value);

  @override
  String toString() =>
      '(${time.toIso8601String()}, ${value.toStringAsFixed(2)})';
}


class PulseService {

  static const double _kVarMin = 8.0;     // variación mínima (luma)
  static const double _kVarMax = 120.0;   // variación máxima aceptable
  static const double _kMedMax = 140.0;   // mediana máxima (luma)

  Future<int?> measurePulse({
    required CameraController controller,
    int durationSeconds = 15,
  }) async {
    print(' Midiendo pulso durante $durationSeconds s…');

    if (!controller.value.isInitialized) {
      print(' El CameraController no está inicializado');
      return null;
    }

    await controller.setFlashMode(FlashMode.torch);

  //captura
    final samples = <_Sample>[];
    int count = 0;

    print('⏳ 1 s de estabilización…');
    await Future.delayed(const Duration(seconds: 1));

    try {
      await controller.startImageStream((CameraImage img) {
        final luma = _averageLuma(img);
        samples.add(_Sample(DateTime.now(), luma));
        print('Sample #${++count}: ${samples.last}');
      });
      print('🎥 Stream iniciado…');
    } catch (e) {
      print(' Error al iniciar stream: $e');
      return null;
    }

    await Future.delayed(Duration(seconds: durationSeconds));

    try {
      await controller.stopImageStream();
      if (!controller.value.isPreviewPaused) await controller.pausePreview();
      await controller.setFlashMode(FlashMode.off);
      print('Stream detenido (preview en pausa, flash off)');
    } catch (e) {
      print(' Error al detener stream: $e');
    }

    print('Captura finalizada. Total: ${samples.length} muestras');


    if (!_isSignalGood(samples)) {
      print('⚠️ Señal demasiado débil/ruidosa → se aborta.');
      return null;
    }

    final stable = _discardInitialSamples(samples);
    if (stable.length < 2) return null;


    final detrend = _detrend(stable);
    final smooth  = _movingAverage(detrend, 5);
    final band    = _bandPassFilter(smooth);
    final peaks   = _detectPeaksImproved(band);
//regla de picos
    final variation = _signalVariation(stable);
    final minPeaks  = variation >= 15.0 ? 3 : 4; // 3 latidos si señal fuerte
    if (peaks.length < minPeaks) {
      print('⚠️ Sólo ${peaks.length} picos (mín $minPeaks) → sin resultado');
      return null;
    }


    final intervals = <double>[];
    for (var i = 1; i < peaks.length; i++) {
      intervals.add(
        peaks[i].time.difference(peaks[i - 1].time).inMilliseconds.toDouble(),
      );
    }

    const minI = 300.0;  
    const maxI = 2000.0;
    final valid = intervals.where((i) => i >= minI && i <= maxI).toList();

    final minRR = minPeaks - 1;
    if (valid.length < minRR) {
      print('⚠️ Sólo ${valid.length} RR válidos (mín $minRR) → sin resultado');
      return null;
    }

    /* ───────── Cálculo BPM ───────── */
    final avgMs = valid.reduce((a, b) => a + b) / valid.length;
    final bpm   = (60000 / avgMs).round();
    final ok    = bpm >= 40 && bpm <= 200;

    print(ok
        ? '❤️ BPM calculado: $bpm'
        : '⚠️ BPM $bpm fuera de rango fisiológico');

    return ok ? bpm : null;
  }



//variacion de la señal
  double _signalVariation(List<_Sample> s) {
    if (s.isEmpty) return 0;
    final vals = s.map((e) => e.value);
    return vals.reduce(max) - vals.reduce(min);
  }
//si  la variacion cumple 
  bool _isSignalGood(List<_Sample> samples) {
    if (samples.length < 50) return false; 

    final vals = samples.map((s) => s.value).toList()..sort();
    final variation = vals.last - vals.first;
    final median    = vals[vals.length >> 1];

    print('📊 Var= ${variation.toStringAsFixed(1)}, '
          'Med= ${median.toStringAsFixed(1)}');

    final okVar = variation >= _kVarMin && variation <= _kVarMax;
    final okMed = median    <= _kMedMax;

    return okVar && okMed;
  }

  List<_Sample> _discardInitialSamples(List<_Sample> s) =>
      s.sublist(min(30, s.length));

  /* ---------- Procesado de señal ---------- */

  /// Promedio de luminancia para YUV420 / BGRA8888
  double _averageLuma(CameraImage img) {
    try {
      if (img.format.group == ImageFormatGroup.yuv420) {
        final bytes = img.planes[0].bytes; 
        var sum = 0;
        for (final b in bytes) sum += b;
        return sum / bytes.length;
      } else {
       
        final bytes = img.planes[0].bytes;
        var sum = 0;
        for (var i = 0; i < bytes.length; i += 4) {
          final b = bytes[i], g = bytes[i + 1], r = bytes[i + 2];
          sum += (0.2126 * r + 0.7152 * g + 0.0722 * b).round();
        }
        return sum / (bytes.length ~/ 4);
      }
    } catch (e) {
      print('⚠️ Error calculando luminancia: $e');
      return 0.0;
    }
  }

  List<_Sample> _detrend(List<_Sample> data) {
    const w = 30;
    final out = <_Sample>[];
    for (var i = 0; i < data.length; i++) {
      final seg = data.sublist(
          max(0, i - w ~/ 2), min(data.length, i + w ~/ 2));
      final avg = seg.map((s) => s.value).reduce((a, b) => a + b) / seg.length;
      out.add(_Sample(data[i].time, data[i].value - avg));
    }
    return out;
  }

  List<_Sample> _movingAverage(List<_Sample> d, int w) {
    final out = <_Sample>[];
    for (var i = 0; i < d.length; i++) {
      final seg = d.sublist(
          max(0, i - w ~/ 2), min(d.length, i + w ~/ 2 + 1));
      final avg = seg.map((s) => s.value).reduce((a, b) => a + b) / seg.length;
      out.add(_Sample(d[i].time, avg));
    }
    return out;
  }

  /// Filtro Butterworth paso-banda (0.8–3 Hz @ 30 fps)
  List<_Sample> _bandPassFilter(List<_Sample> data) {
    const b0 = 0.0037, b1 = 0.0, b2 = -0.0074, b3 = 0.0, b4 = 0.0037;
    const a0 = 1.0,    a1 = -3.6239, a2 = 5.0176, a3 = -3.1709, a4 = 0.7773;

    final filtered = <_Sample>[];
    final x = List<double>.filled(5, 0.0);
    final y = List<double>.filled(5, 0.0);

    for (final s in data) {
      for (var k = 4; k > 0; k--) {
        x[k] = x[k - 1];
        y[k] = y[k - 1];
      }
      x[0] = s.value;

      y[0] = (b0 * x[0] + b1 * x[1] + b2 * x[2] + b3 * x[3] + b4 * x[4] -
              a1 * y[1] - a2 * y[2] - a3 * y[3] - a4 * y[4]) / a0;

      filtered.add(_Sample(s.time, y[0]));
    }
    return filtered;
  }

  /// Detector de picos con histéresis simple
  List<_Sample> _detectPeaksImproved(List<_Sample> data) {
    if (data.isEmpty) return [];
    final peaks = <_Sample>[];

    final vals = data.map((s) => s.value).toList()..sort();
    final thr  = vals[vals.length * 3 ~/ 4]; // cuantil 75 %
    final up   = thr * 1.2;
    final down = thr * 0.8;
    var inPeak = false;

    for (var i = 1; i < data.length - 1; i++) {
      final cur  = data[i];
      final prev = data[i - 1];
      final next = data[i + 1];
      final isMax = cur.value > prev.value && cur.value > next.value;

      if (isMax) {
        if (!inPeak && cur.value > up) {
          inPeak = true;
          peaks.add(cur);
        } else if (inPeak && cur.value > down) {
          peaks.add(cur);
        }
      } else if (inPeak && cur.value < down) {
        inPeak = false;
      }
    }
    return peaks;
  }
}
