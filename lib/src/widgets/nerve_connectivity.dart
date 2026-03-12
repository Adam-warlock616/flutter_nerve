import 'package:flutter/widgets.dart';
import '../models/nerve_state.dart';
import '../nerve_provider.dart';

/// A pre-built connectivity banner that slides down when the network quality
/// drops to [NetworkQuality.poor] or [NetworkQuality.none].
///
/// Wrap your app body or an individual scaffold body with this widget. A
/// colored banner animates in from the top when connectivity is degraded and
/// dismisses automatically when the connection recovers.
///
/// Example:
/// ```dart
/// NerveConnectivity(
///   child: MyContent(),
/// )
/// ```
class NerveConnectivity extends StatelessWidget {
  final Widget child;

  /// Banner shown when there is no connection at all.
  /// Defaults to a red "No internet connection" banner.
  final Widget? noBanner;

  /// Banner shown on poor connectivity.
  /// Defaults to an orange "Poor connection" banner.
  final Widget? poorBanner;

  const NerveConnectivity({
    super.key,
    required this.child,
    this.noBanner,
    this.poorBanner,
  });

  @override
  Widget build(BuildContext context) {
    final state = NerveProvider.of(context);
    final quality = state.networkQuality;

    final bool showNone = quality == NetworkQuality.none;
    final bool showPoor = quality == NetworkQuality.poor;
    final bool showBanner = showNone || showPoor;

    Widget banner;
    if (showNone) {
      banner = noBanner ??
          _DefaultBanner(
            color: const Color(0xFFB71C1C),
            icon: '✗',
            message: 'No internet connection',
          );
    } else {
      banner = poorBanner ??
          _DefaultBanner(
            color: const Color(0xFFE65100),
            icon: '▲',
            message: 'Poor connection',
          );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: showBanner ? banner : const SizedBox.shrink(),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _DefaultBanner extends StatelessWidget {
  final Color color;
  final String icon;
  final String message;

  const _DefaultBanner({
    required this.color,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon,
              style: const TextStyle(
                  color: Color(0xFFFFFFFF), fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
