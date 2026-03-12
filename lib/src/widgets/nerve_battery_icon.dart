import 'package:flutter/widgets.dart';
import '../nerve_provider.dart';

/// An animated battery icon that visually reflects the current battery level
/// and charging state from [NerveState].
///
/// The icon fills proportionally to [NerveState.batteryLevel] and changes
/// colour automatically: green above 40 %, orange 15–40 %, red below 15 %.
/// A lightning bolt overlay appears when charging.
///
/// Example:
/// ```dart
/// NerveBatteryIcon(size: 48)
/// ```
class NerveBatteryIcon extends StatelessWidget {
  /// Overall size of the icon. The icon maintains a ~1:2 width:height ratio.
  final double size;

  const NerveBatteryIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final state = NerveProvider.of(context);
    final level = state.batteryLevel.clamp(0.0, 1.0);
    final charging = state.isCharging;

    final color = _colorForLevel(level);
    final width = size * 0.55;
    final height = size;
    final tipHeight = height * 0.08;
    final tipWidth = width * 0.4;
    final bodyRadius = width * 0.15;
    final borderWidth = width * 0.08;

    return SizedBox(
      width: width + 2,
      height: height + tipHeight,
      child: CustomPaint(
        painter: _BatteryPainter(
          level: level,
          color: color,
          charging: charging,
          bodyRadius: bodyRadius,
          borderWidth: borderWidth,
          tipHeight: tipHeight,
          tipWidth: tipWidth,
        ),
      ),
    );
  }

  Color _colorForLevel(double level) {
    if (level < 0.15) return const Color(0xFFE53935); // red
    if (level < 0.4) return const Color(0xFFFB8C00); // orange
    return const Color(0xFF43A047); // green
  }
}

class _BatteryPainter extends CustomPainter {
  final double level;
  final Color color;
  final bool charging;
  final double bodyRadius;
  final double borderWidth;
  final double tipHeight;
  final double tipWidth;

  _BatteryPainter({
    required this.level,
    required this.color,
    required this.charging,
    required this.bodyRadius,
    required this.borderWidth,
    required this.tipHeight,
    required this.tipWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyTop = tipHeight;
    final bodyRect = Rect.fromLTWH(
      0,
      bodyTop,
      size.width,
      size.height - bodyTop,
    );
    final bodyRRect =
        RRect.fromRectAndRadius(bodyRect, Radius.circular(bodyRadius));

    // Draw border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(bodyRRect, borderPaint);

    // Draw tip (nub at top)
    final tipLeft = (size.width - tipWidth) / 2;
    final tipPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tipLeft, 0, tipWidth, tipHeight * 1.1),
        Radius.circular(bodyRadius * 0.5),
      ),
      tipPaint,
    );

    // Draw fill level
    final padding = borderWidth * 1.5;
    final fillMaxHeight = bodyRect.height - padding * 2;
    final fillHeight = fillMaxHeight * level;
    final fillTop = bodyRect.bottom - padding - fillHeight;

    final fillRect = Rect.fromLTWH(
      padding,
      fillTop,
      size.width - padding * 2,
      fillHeight,
    );
    final fillRRadius = bodyRadius * 0.6;
    final fillRRect = RRect.fromRectAndCorners(
      fillRect,
      bottomLeft: Radius.circular(fillRRadius),
      bottomRight: Radius.circular(fillRRadius),
      topLeft: level > 0.95 ? Radius.circular(fillRRadius) : Radius.zero,
      topRight: level > 0.95 ? Radius.circular(fillRRadius) : Radius.zero,
    );
    canvas.drawRRect(fillRRect, Paint()..color = color);

    // Draw charging bolt
    if (charging) {
      final boltPaint = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.fill;
      final cx = size.width / 2;
      final cy = bodyRect.top + bodyRect.height / 2;
      final bh = bodyRect.height * 0.45;
      final bw = bh * 0.55;
      final path = Path()
        ..moveTo(cx + bw * 0.1, cy - bh / 2)
        ..lineTo(cx - bw * 0.5, cy + bh * 0.05)
        ..lineTo(cx, cy + bh * 0.05)
        ..lineTo(cx - bw * 0.1, cy + bh / 2)
        ..lineTo(cx + bw * 0.5, cy - bh * 0.05)
        ..lineTo(cx, cy - bh * 0.05)
        ..close();
      canvas.drawPath(path, boltPaint);
    }
  }

  @override
  bool shouldRepaint(_BatteryPainter old) =>
      old.level != level ||
      old.color != color ||
      old.charging != charging;
}
