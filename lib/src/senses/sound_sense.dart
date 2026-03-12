import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:record/record.dart';

/// Captures microphone amplitude using [AudioRecorder] from the `record` package
/// and emits a normalized RMS level (0.0–1.0).
///
/// To use, call [SoundSense.microphone] (factory) and add it to [NerveController]:
/// ```dart
/// NerveRoot(
///   controller: NerveController(
///     sound: await SoundSense.microphone(),
///   ),
///   child: MyApp(),
/// )
/// ```
///
/// Alternatively, inject any `Stream<double>` with [SoundSense.withStream].
class SoundSense {
  final Stream<double> _backing;
  final AudioRecorder? _recorder;

  SoundSense._(this._backing, [this._recorder]);

  /// Creates a [SoundSense] that emits 0.0 constantly (silent stub).
  SoundSense()
      : _backing = const Stream.empty(),
        _recorder = null;

  /// Creates a [SoundSense] backed by a custom stream of RMS levels (0.0–1.0).
  SoundSense.withStream(Stream<double> rawStream)
      : _backing = rawStream.map((v) => v.clamp(0.0, 1.0)),
        _recorder = null;

  /// Creates a [SoundSense] that reads from the device microphone via [record].
  ///
  /// The microphone stream is sampled at 16 kHz mono PCM-16. Callers must
  /// ensure that microphone permission is granted before calling this method.
  ///
  /// The [windowMs] parameter is the RMS averaging window in milliseconds.
  static Future<SoundSense> microphone({
    int sampleRate = 16000,
    int windowMs = 100,
  }) async {
    final recorder = AudioRecorder();

    if (!await recorder.hasPermission()) {
      recorder.dispose();
      // Return silent stub if permission is denied
      return SoundSense();
    }

    final pcmStream = await recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
      ),
    );

    final samplesPerWindow = (sampleRate * windowMs / 1000).round();
    // Buffer and compute RMS per window
    final controller = StreamController<double>.broadcast();
    final buffer = <int>[];

    pcmStream.listen(
      (Uint8List chunk) {
        // PCM 16-bit little-endian: 2 bytes per sample
        for (int i = 0; i + 1 < chunk.length; i += 2) {
          final sample = chunk[i] | (chunk[i + 1] << 8);
          // Convert unsigned to signed
          buffer.add(sample > 32767 ? sample - 65536 : sample);
        }
        while (buffer.length >= samplesPerWindow) {
          final window = buffer.sublist(0, samplesPerWindow);
          buffer.removeRange(0, samplesPerWindow);
          final rms = _rms(window);
          controller.add(rms);
        }
      },
      onDone: controller.close,
      onError: controller.addError,
    );

    return SoundSense._(controller.stream, recorder);
  }

  /// Computes root mean square and normalises to 0.0–1.0.
  static double _rms(List<int> samples) {
    if (samples.isEmpty) return 0.0;
    double sum = 0;
    for (final s in samples) {
      sum += s * s;
    }
    final rms = sqrt(sum / samples.length);
    return (rms / 32768.0).clamp(0.0, 1.0);
  }

  /// Normalize an arbitrary amplitude to 0.0–1.0 using log scaling.
  static double normalizeAmplitude(double rawAmplitude) {
    if (rawAmplitude <= 0) return 0.0;
    return (log(rawAmplitude + 1) / log(32768)).clamp(0.0, 1.0);
  }

  /// Stream of ambient sound level from 0.0 (silent) to 1.0 (loud).
  Stream<double> get stream => _backing;

  /// Release resources.
  Future<void> dispose() async {
    final r = _recorder;
    if (r != null) {
      await r.stop();
      r.dispose();
    }
  }
}
