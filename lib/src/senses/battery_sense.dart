import 'dart:async';
import 'package:battery_plus/battery_plus.dart';

/// Polls battery state every [pollInterval] and emits `(level, isCharging)` pairs.
class BatterySense {
  final Battery _battery = Battery();
  final Duration pollInterval;

  StreamController<(double, bool)>? _controller;
  Timer? _timer;

  BatterySense({this.pollInterval = const Duration(seconds: 30)});

  /// Stream of `(batteryLevel 0.0–1.0, isCharging)`.
  Stream<(double, bool)> get stream {
    _controller ??= StreamController<(double, bool)>.broadcast(
      onListen: _start,
      onCancel: _stop,
    );
    return _controller!.stream;
  }

  Future<void> _start() async {
    await _emit();
    _timer = Timer.periodic(pollInterval, (_) => _emit());
  }

  Future<void> _emit() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      final charging = state == BatteryState.charging ||
          state == BatteryState.full;
      _controller?.add((level / 100.0, charging));
    } catch (_) {
      // sensor unavailable; skip
    }
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Release resources.
  void dispose() {
    _stop();
    _controller?.close();
    _controller = null;
  }
}
