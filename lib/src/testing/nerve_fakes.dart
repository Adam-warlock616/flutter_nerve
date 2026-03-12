import 'dart:async';
import '../models/nerve_state.dart';
import '../nerve_controller.dart';
import '../senses/battery_sense.dart';
import '../senses/network_sense.dart';
import '../senses/motion_sense.dart';
import '../senses/light_sense.dart';
import '../senses/sound_sense.dart';

/// Testing utilities for [flutter_nerve].
///
/// Use [NerveFakes] to create a [NerveController] with pre-set sensor values,
/// making it trivial to write `testWidgets` tests without needing real hardware.
///
/// Example:
/// ```dart
/// testWidgets('low battery shows red theme', (tester) async {
///   final ctrl = NerveFakes.withBattery(0.05);
///   await tester.pumpWidget(
///     NerveRoot(controller: ctrl, child: MyApp()),
///   );
///   expect(find.text('Low Battery!'), findsOneWidget);
///   ctrl.dispose();
/// });
/// ```
class NerveFakes {
  NerveFakes._();

  /// Controller initialized with a specific [batteryLevel] (0.0–1.0)
  /// and optional [charging] state. All other senses use silent stubs.
  static NerveController withBattery(
    double batteryLevel, {
    bool charging = false,
  }) {
    return _makeController(
        battery: _ConstBatterySense(batteryLevel, charging));
  }

  /// Controller initialized with a specific [NetworkQuality].
  /// All other senses use silent stubs.
  static NerveController withNetwork(NetworkQuality quality) {
    return _makeController(network: _ConstNetworkSense(quality));
  }

  /// Controller initialized with specific tilt values.
  /// All other senses use silent stubs.
  static NerveController withMotion(double tiltX, double tiltY) {
    return _makeController(motion: _ConstMotionSense(tiltX, tiltY));
  }

  /// Controller initialized with a specific ambient [lux] level.
  static NerveController withLight(double lux) {
    return _makeController(light: _ConstLightSense(lux));
  }

  /// Controller initialized with a specific [soundLevel] (0.0–1.0).
  static NerveController withSound(double soundLevel) {
    return _makeController(sound: _ConstSoundSense(soundLevel));
  }

  /// Controller initialized with all sensor values specified.
  ///
  /// Omitted senses default to silent stubs (i.e., no emissions).
  static NerveController withAllSenses({
    double batteryLevel = 1.0,
    bool charging = false,
    NetworkQuality networkQuality = NetworkQuality.good,
    double tiltX = 0.0,
    double tiltY = 0.0,
    double? ambientLight,
    double? soundLevel,
  }) {
    return _makeController(
      battery: _ConstBatterySense(batteryLevel, charging),
      network: _ConstNetworkSense(networkQuality),
      motion: _ConstMotionSense(tiltX, tiltY),
      light: ambientLight != null ? _ConstLightSense(ambientLight) : null,
      sound: soundLevel != null ? _ConstSoundSense(soundLevel) : null,
    );
  }

  static NerveController _makeController({
    BatterySense? battery,
    NetworkSense? network,
    MotionSense? motion,
    LightSense? light,
    SoundSense? sound,
  }) {
    final ctrl = NerveController(
      battery: battery,
      network: network,
      motion: motion,
      light: light,
      sound: sound,
    );
    ctrl.init();
    return ctrl;
  }
}

// ─── Private constant sense stubs ────────────────────────────────────────────

class _ConstBatterySense extends BatterySense {
  final double _level;
  final bool _charging;
  _ConstBatterySense(this._level, this._charging);

  @override
  Stream<(double, bool)> get stream =>
      Stream.value((_level.clamp(0.0, 1.0), _charging));

  @override
  void dispose() {}
}

class _ConstNetworkSense extends NetworkSense {
  final NetworkQuality _quality;
  _ConstNetworkSense(this._quality);

  @override
  Stream<NetworkQuality> get stream => Stream.value(_quality);

  @override
  void dispose() {}
}

class _ConstMotionSense extends MotionSense {
  final double _x, _y;
  _ConstMotionSense(this._x, this._y);

  @override
  Stream<(double, double)> get stream => Stream.value((_x, _y));

  @override
  void dispose() {}
}

class _ConstLightSense extends LightSense {
  final double _lux;
  _ConstLightSense(this._lux);

  @override
  Stream<double> get stream => Stream.value(_lux);

  @override
  void dispose() {}
}

class _ConstSoundSense extends SoundSense {
  final double _level;
  _ConstSoundSense(this._level);

  @override
  Stream<double> get stream => Stream.value(_level.clamp(0.0, 1.0));

  @override
  Future<void> dispose() async {}
}
