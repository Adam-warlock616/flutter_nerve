import 'package:flutter/material.dart';
import '../models/nerve_state.dart';
import '../nerve_provider.dart';
import '../nerve_theme.dart';

/// A [Scaffold] that reacts to the current [NerveState]:
/// - Dims saturation when battery is low
/// - Applies a subtle parallax translation based on device tilt
/// - Shows a network quality banner when connectivity is degraded
class NerveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  /// If true, shows a slim banner at the top when network quality is
  /// [NetworkQuality.poor] or [NetworkQuality.none].
  final bool showNetworkBanner;

  /// Maximum pixel offset for the tilt parallax effect on the body.
  final double parallaxDepth;

  const NerveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.showNetworkBanner = true,
    this.parallaxDepth = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final state = NerveProvider.of(context);
    final theme = NerveTheme.resolve(context, state);

    final saturation = state.batteryLevel < 0.15 ? 0.0 : 1.0;
    final parallaxX = state.tiltX * parallaxDepth;
    final parallaxY = state.tiltY * parallaxDepth;

    final networkOk = state.networkQuality == NetworkQuality.good ||
        state.networkQuality == NetworkQuality.fair;

    Widget bodyContent = body ?? const SizedBox.shrink();

    // Parallax transform
    bodyContent = AnimatedSlide(
      offset: Offset(parallaxX / 400, parallaxY / 400),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: bodyContent,
    );

    // Greyscale effect on low battery
    if (saturation < 1.0) {
      bodyContent = ColorFiltered(
        colorFilter: ColorFilter.matrix(_saturationMatrix(saturation)),
        child: bodyContent,
      );
    }

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor:
            backgroundColor ?? theme.scaffoldBackgroundColor,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: Column(
          children: [
            if (showNetworkBanner && !networkOk)
              _NetworkBanner(quality: state.networkQuality),
            Expanded(child: bodyContent),
          ],
        ),
      ),
    );
  }

  static List<double> _saturationMatrix(double sat) {
    final r = 0.2126 * (1 - sat);
    final g = 0.7152 * (1 - sat);
    final b = 0.0722 * (1 - sat);
    return [
      r + sat, g,       b,       0, 0,
      r,       g + sat, b,       0, 0,
      r,       g,       b + sat, 0, 0,
      0,       0,       0,       1, 0,
    ];
  }
}

class _NetworkBanner extends StatelessWidget {
  final NetworkQuality quality;
  const _NetworkBanner({required this.quality});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (quality) {
      NetworkQuality.none => ('No internet connection', const Color(0xFFB71C1C)),
      NetworkQuality.poor => ('Poor connection', const Color(0xFFE65100)),
      _ => ('Connecting…', const Color(0xFFF57F17)),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
