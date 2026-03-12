import 'package:flutter/widgets.dart';
import '../nerve_provider.dart';

/// A widget that applies a physics-spring offset to its child driven by
/// the device tilt from [MotionSense].
///
/// The child shifts in the direction of the tilt, creating a natural
/// floating/parallax feel. The offset settles back to zero when the
/// device is held flat.
///
/// Example:
/// ```dart
/// NerveSpring(
///   depth: 20,
///   child: FlutterLogo(size: 100),
/// )
/// ```
class NerveSpring extends StatelessWidget {
  final Widget child;

  /// Maximum pixel offset at full tilt (tiltX or tiltY == 1.0).
  /// Defaults to `16`.
  final double depth;

  /// Animation duration for each tilt update. Defaults to 250 ms.
  final Duration duration;

  /// Animation curve. Defaults to [Curves.easeOut].
  final Curve curve;

  const NerveSpring({
    super.key,
    required this.child,
    this.depth = 16,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    final state = NerveProvider.of(context);
    final dx = state.tiltX * depth;
    final dy = state.tiltY * depth;

    return AnimatedSlide(
      offset: Offset(dx / 200, dy / 200), // fractional units
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}
