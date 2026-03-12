import 'package:flutter/widgets.dart';
import '../models/nerve_state.dart';
import '../nerve_provider.dart';
import '../senses/motion_sense.dart';

/// A widget that wraps its child in an animated glowing border whose
/// intensity tracks the device tilt magnitude from [MotionSense].
///
/// At rest (no tilt) the glow is invisible. Tilting the device makes the
/// glow brighten. You can also drive the glow from a custom mapper.
///
/// Example:
/// ```dart
/// NerveGlow(
///   color: Colors.purpleAccent,
///   maxBlurRadius: 24,
///   child: FlutterLogo(size: 80),
/// )
/// ```
class NerveGlow extends StatelessWidget {
  /// The child widget to wrap with a glow.
  final Widget child;

  /// Base glow color. Defaults to white.
  final Color color;

  /// Maximum blur radius (spread) of the glow at full tilt. Defaults to `20`.
  final double maxBlurRadius;

  /// Maximum spread radius of the glow at full tilt. Defaults to `4`.
  final double maxSpreadRadius;

  /// Optional corner radius of the glow boundary. Set to half the child size
  /// for circular glows. Defaults to `12`.
  final double borderRadius;

  /// Override tilt-based intensity with a custom mapper.
  final double Function(NerveState)? intensityMapper;

  /// Duration of glow animation steps. Defaults to 200 ms.
  final Duration duration;

  const NerveGlow({
    super.key,
    required this.child,
    this.color = const Color(0xFFFFFFFF),
    this.maxBlurRadius = 20,
    this.maxSpreadRadius = 4,
    this.borderRadius = 12,
    this.intensityMapper,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final state = NerveProvider.of(context);
    final intensity = intensityMapper != null
        ? intensityMapper!(state).clamp(0.0, 1.0)
        : MotionSense.magnitude(state.tiltX, state.tiltY);

    final blur = maxBlurRadius * intensity;
    final spread = maxSpreadRadius * intensity;

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6 * intensity),
            blurRadius: blur,
            spreadRadius: spread,
          ),
        ],
      ),
      child: child,
    );
  }
}
