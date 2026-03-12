import 'dart:math';
import 'package:flutter/widgets.dart';
import '../nerve_provider.dart';

/// A widget that detects shake gestures by watching [NerveState.tiltX/Y]
/// magnitude spikes from [MotionSense].
///
/// [onShake] fires when the device is shaken (rapid high-magnitude motion),
/// with a [cooldown] to prevent rapid repeated triggers.
///
/// Example:
/// ```dart
/// NerveShake(
///   onShake: () => setState(() => _shakeCount++),
///   child: MyWidget(),
/// )
/// ```
class NerveShake extends StatefulWidget {
  final Widget child;

  /// Callback invoked when a shake is detected.
  final VoidCallback onShake;

  /// Magnitude threshold (0.0–1.0) above which a shake is registered.
  /// Defaults to `0.65` — strong deliberate shakes only.
  final double threshold;

  /// Minimum time between consecutive shake events to avoid rapid-fire.
  /// Defaults to 600 ms.
  final Duration cooldown;

  const NerveShake({
    super.key,
    required this.child,
    required this.onShake,
    this.threshold = 0.65,
    this.cooldown = const Duration(milliseconds: 600),
  });

  @override
  State<NerveShake> createState() => _NerveShakeState();
}

class _NerveShakeState extends State<NerveShake> {
  DateTime _lastFire = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Widget build(BuildContext context) {
    final state = NerveProvider.of(context);
    final magnitude = sqrt(
      state.tiltX * state.tiltX + state.tiltY * state.tiltY,
    ).clamp(0.0, 1.0);

    if (magnitude >= widget.threshold) {
      final now = DateTime.now();
      if (now.difference(_lastFire) >= widget.cooldown) {
        _lastFire = now;
        // Schedule the callback after the current build is complete.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onShake();
        });
      }
    }

    return widget.child;
  }
}
