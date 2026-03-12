import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Wraps [sensors_plus] accelerometer events and emits normalized tilt values.
///
/// Values are in the range -1.0 to 1.0, where ±1.0 corresponds to ±9.8 m/s².
class MotionSense {
  StreamSubscription<AccelerometerEvent>? _sub;
  StreamController<(double tiltX, double tiltY)>? _controller;

  static const double _gravity = 9.8;

  /// Stream of `(tiltX, tiltY)` in the range -1.0 to 1.0.
  Stream<(double, double)> get stream {
    _controller ??= StreamController<(double, double)>.broadcast(
      onListen: _start,
      onCancel: _stop,
    );
    return _controller!.stream;
  }

  void _start() {
    _sub = accelerometerEventStream().listen((event) {
      final x = (event.x / _gravity).clamp(-1.0, 1.0);
      final y = (event.y / _gravity).clamp(-1.0, 1.0);
      _controller?.add((x, y));
    });
  }

  void _stop() {
    _sub?.cancel();
    _sub = null;
  }

  /// The magnitude of the current tilt vector (0.0–1.0).
  static double magnitude(double tiltX, double tiltY) =>
      sqrt(tiltX * tiltX + tiltY * tiltY).clamp(0.0, 1.0);

  /// Release resources.
  void dispose() {
    _stop();
    _controller?.close();
    _controller = null;
  }
}
