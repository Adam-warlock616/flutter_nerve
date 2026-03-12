import 'dart:ui';
import 'package:flutter/widgets.dart';
import '../models/nerve_state.dart';
import '../nerve_provider.dart';

/// A [Container] whose color, scale, and blur react to [NerveState].
///
/// Example — color shifts with battery, scale grows with tilt magnitude:
/// ```dart
/// ReactiveContainer(
///   colorMapper: (state) => Color.lerp(Colors.red, Colors.green, state.batteryLevel)!,
///   scaleMapper: (state) => 1.0 + MotionSense.magnitude(state.tiltX, state.tiltY) * 0.1,
///   child: const FlutterLogo(size: 100),
/// )
/// ```
class ReactiveContainer extends StatelessWidget {
  /// Override to map state → background color. Defaults to transparent.
  final Color Function(NerveState)? colorMapper;

  /// Override to map state → uniform scale factor. Defaults to 1.0.
  final double Function(NerveState)? scaleMapper;

  /// Override to map state → blur sigma (applied as [BackdropFilter]). Defaults to 0.
  final double Function(NerveState)? blurMapper;

  /// Duration for animating changes. Defaults to 300 ms.
  final Duration animationDuration;

  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final double? width;
  final double? height;
  final Widget? child;

  const ReactiveContainer({
    super.key,
    this.colorMapper,
    this.scaleMapper,
    this.blurMapper,
    this.animationDuration = const Duration(milliseconds: 300),
    this.alignment = Alignment.center,
    this.padding,
    this.constraints,
    this.width,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final state = NerveProvider.of(context);

    final color = colorMapper?.call(state) ?? const Color(0x00000000);
    final scale = scaleMapper?.call(state) ?? 1.0;
    final blur = blurMapper?.call(state) ?? 0.0;

    Widget content = AnimatedContainer(
      duration: animationDuration,
      color: color,
      alignment: alignment,
      padding: padding,
      constraints: constraints,
      width: width,
      height: height,
      child: _maybeBlur(blur, child),
    );

    if (scale != 1.0) {
      content = AnimatedScale(
        scale: scale,
        duration: animationDuration,
        child: content,
      );
    }

    return content;
  }

  Widget? _maybeBlur(double sigma, Widget? child) {
    if (sigma <= 0 || child == null) return child;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child,
      ),
    );
  }
}
