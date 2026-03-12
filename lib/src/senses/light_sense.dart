import 'dart:async';
import 'package:light/light.dart';

/// Wraps the `light` package to stream ambient lux values.
///
/// Android reads the hardware light sensor directly. iOS requires a SensorKit
/// entitlement from Apple (see the `light` package README for setup).
///
/// Basic usage:
/// ```dart
/// NerveRoot(
///   controller: NerveController(light: LightSense()),
///   child: MyApp(),
/// )
/// ```
///
/// Or inject any custom lux stream via [LightSense.withStream].
class LightSense {
  final Stream<double> _backing;
  StreamSubscription<int>? _sub;

  /// Creates a [LightSense] that reads from the hardware ambient light sensor.
  LightSense() : _backing = _buildLightStream();

  /// Creates a [LightSense] backed by a custom stream of lux values (≥ 0).
  LightSense.withStream(Stream<double> luxStream) : _backing = luxStream;

  static Stream<double> _buildLightStream() {
    late StreamController<double> controller;
    StreamSubscription<int>? sub;

    controller = StreamController<double>.broadcast(
      onListen: () async {
        try {
          final light = Light();
          // Request authorization (no-op on Android; required on iOS).
          await light.requestAuthorization();
          sub = light.lightSensorStream.listen(
            (int lux) => controller.add(lux.toDouble()),
            onError: controller.addError,
            onDone: controller.close,
          );
        } catch (e) {
          // Sensor unavailable on this platform — stream stays silent.
          controller.close();
        }
      },
      onCancel: () {
        sub?.cancel();
        sub = null;
      },
    );

    return controller.stream;
  }

  /// Stream of ambient light in lux. May not emit on platforms without
  /// a light sensor or when iOS entitlement is missing.
  Stream<double> get stream => _backing;

  /// Release resources.
  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
