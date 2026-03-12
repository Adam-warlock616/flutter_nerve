import 'package:flutter/material.dart';
import 'models/nerve_state.dart';

/// Maps a [NerveState] snapshot to a [ThemeData] override.
///
/// Rules:
/// - Low battery (<15%) → desaturated, muted greys
/// - Poor/no network → warning accent (amber/red tint)
/// - High sound (>0.7) → vibrant, high-contrast accent
/// - Tilt → shifts primary hue slightly (±15°)
abstract final class NerveTheme {
  NerveTheme._();

  /// Returns a [ThemeData] adapted to the given [NerveState].
  ///
  /// Merges with the ambient [Theme] so only the affected properties change.
  static ThemeData resolve(BuildContext context, NerveState state) {
    final base = Theme.of(context);
    final seed = _seedColor(state);
    final brightness = base.brightness;

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
        dynamicSchemeVariant: state.batteryLevel < 0.15
            ? DynamicSchemeVariant.monochrome
            : DynamicSchemeVariant.tonalSpot,
      ),
      brightness: brightness,
      useMaterial3: true,
    );
  }

  /// Picks the seed color based on the most "interesting" sense.
  static Color _seedColor(NerveState state) {
    // Low battery → grey
    if (state.batteryLevel < 0.15) {
      return const Color(0xFF9E9E9E);
    }

    // No / poor network → warning amber-red
    if (state.networkQuality == NetworkQuality.none) {
      return const Color(0xFFB71C1C);
    }
    if (state.networkQuality == NetworkQuality.poor) {
      return const Color(0xFFE65100);
    }

    // High sound → vibrant cyan-lime
    if ((state.soundLevel ?? 0) > 0.7) {
      return const Color(0xFF00E5FF);
    }

    // Tilt shifts hue: tiltX in [-1,1] maps ±15° around base indigo (240°)
    final tiltHueDelta = state.tiltX * 15.0;
    final hue = (240.0 + tiltHueDelta) % 360.0;
    return HSVColor.fromAHSV(1.0, hue, 0.7, 0.8).toColor();
  }
}
