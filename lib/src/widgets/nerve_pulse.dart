import 'package:flutter/widgets.dart';
import '../nerve_provider.dart';

/// A widget that continuously pulses (scales) in sync with the ambient sound level.
///
/// At silence the widget renders at normal size; at maximum volume it grows to
/// [maxScale]. Optionally, the opacity can also track the sound level.
///
/// Example:
/// ```dart
/// NervePulse(
///   maxScale: 1.3,
///   child: Icon(Icons.mic, size: 64),
/// )
/// ```
class NervePulse extends StatelessWidget {
  /// The child widget to pulse.
  final Widget child;

  /// Maximum scale factor reached at `soundLevel == 1.0`. Defaults to `1.2`.
  final double maxScale;

  /// Whether the opacity should also track sound level. Defaults to `false`.
  final bool pulseOpacity;

  /// Duration of each scale/opacity animation step.
  final Duration duration;

  const NervePulse({
    super.key,
    required this.child,
    this.maxScale = 1.2,
    this.pulseOpacity = false,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  Widget build(BuildContext context) {
    final state = NerveProvider.of(context);
    final level = state.soundLevel ?? 0.0;
    final scale = 1.0 + (maxScale - 1.0) * level;
    final opacity = pulseOpacity ? (0.4 + 0.6 * level).clamp(0.0, 1.0) : 1.0;

    return AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      child: AnimatedScale(
        scale: scale,
        duration: duration,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}
