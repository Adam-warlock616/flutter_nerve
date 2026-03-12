import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models/nerve_state.dart';
import 'senses/battery_sense.dart';
import 'senses/network_sense.dart';
import 'senses/motion_sense.dart';
import 'senses/light_sense.dart';
import 'senses/sound_sense.dart';

/// Central aggregator that fuses all sensor streams into [NerveState] updates.
///
/// Usage:
/// ```dart
/// final controller = NerveController();
/// await controller.init();
/// // ... use via NerveProvider, or listen to controller directly
/// controller.dispose();
/// ```
class NerveController extends ChangeNotifier {
  NerveState _state = const NerveState();

  /// The latest sensory snapshot.
  NerveState get state => _state;

  final BatterySense _battery;
  final NetworkSense _network;
  final MotionSense _motion;
  final LightSense _light;
  final SoundSense _sound;

  final List<StreamSubscription<dynamic>> _subs = [];

  /// Creates a [NerveController].
  ///
  /// You can inject custom sense adapters (useful for testing or custom sound
  /// implementations). If omitted, default adapters are used.
  NerveController({
    BatterySense? battery,
    NetworkSense? network,
    MotionSense? motion,
    LightSense? light,
    SoundSense? sound,
  })  : _battery = battery ?? BatterySense(),
        _network = network ?? NetworkSense(),
        _motion = motion ?? MotionSense(),
        _light = light ?? LightSense(),
        _sound = sound ?? SoundSense();

  /// Convenience async factory that initialises [SoundSense] with the real
  /// device microphone before constructing the controller.
  ///
  /// Microphone permission is requested automatically. If denied, the sound
  /// sense falls back to a silent stub — no crash.
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   final controller = await NerveController.withMicrophone();
  ///   runApp(NerveRoot(controller: controller, child: MyApp()));
  /// }
  /// ```
  static Future<NerveController> withMicrophone({
    BatterySense? battery,
    NetworkSense? network,
    MotionSense? motion,
    LightSense? light,
  }) async {
    final sound = await SoundSense.microphone();
    return NerveController(
      battery: battery,
      network: network,
      motion: motion,
      light: light,
      sound: sound,
    );
  }


  /// Subscribe to all sensor streams. Should be called once after construction.
  void init() {
    _subs.addAll([
      _battery.stream.listen((data) {
        final (level, charging) = data;
        _update(_state.copyWith(batteryLevel: level, isCharging: charging));
      }),
      _network.stream.listen((quality) {
        _update(_state.copyWith(networkQuality: quality));
      }),
      _motion.stream.listen((data) {
        final (x, y) = data;
        _update(_state.copyWith(tiltX: x, tiltY: y));
      }),
      _light.stream.listen((lux) {
        _update(_state.copyWith(ambientLight: lux));
      }),
      _sound.stream.listen((level) {
        _update(_state.copyWith(soundLevel: level));
      }),
    ]);
  }

  void _update(NerveState next) {
    if (next == _state) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    _battery.dispose();
    _network.dispose();
    _motion.dispose();
    _light.dispose();
    // SoundSense.dispose() may be async (AudioRecorder.stop) — fire and forget.
    _sound.dispose();
    super.dispose();
  }
}
