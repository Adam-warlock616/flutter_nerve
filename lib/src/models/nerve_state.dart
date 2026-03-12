/// The current sensory snapshot of the device environment.
class NerveState {
  /// Battery level from 0.0 (empty) to 1.0 (full).
  final double batteryLevel;

  /// Whether the device is currently charging.
  final bool isCharging;

  /// Current network connectivity quality.
  final NetworkQuality networkQuality;

  /// Normalized tilt on the X axis (left/right): -1.0 to 1.0.
  final double tiltX;

  /// Normalized tilt on the Y axis (forward/back): -1.0 to 1.0.
  final double tiltY;

  /// Ambient light level in lux. Null if sensor unavailable.
  final double? ambientLight;

  /// Ambient sound level from 0.0 (silent) to 1.0 (loud). Null if unavailable.
  final double? soundLevel;

  const NerveState({
    this.batteryLevel = 1.0,
    this.isCharging = false,
    this.networkQuality = NetworkQuality.good,
    this.tiltX = 0.0,
    this.tiltY = 0.0,
    this.ambientLight,
    this.soundLevel,
  });

  NerveState copyWith({
    double? batteryLevel,
    bool? isCharging,
    NetworkQuality? networkQuality,
    double? tiltX,
    double? tiltY,
    double? ambientLight,
    double? soundLevel,
  }) {
    return NerveState(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      networkQuality: networkQuality ?? this.networkQuality,
      tiltX: tiltX ?? this.tiltX,
      tiltY: tiltY ?? this.tiltY,
      ambientLight: ambientLight ?? this.ambientLight,
      soundLevel: soundLevel ?? this.soundLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NerveState &&
        other.batteryLevel == batteryLevel &&
        other.isCharging == isCharging &&
        other.networkQuality == networkQuality &&
        other.tiltX == tiltX &&
        other.tiltY == tiltY &&
        other.ambientLight == ambientLight &&
        other.soundLevel == soundLevel;
  }

  @override
  int get hashCode => Object.hash(
        batteryLevel,
        isCharging,
        networkQuality,
        tiltX,
        tiltY,
        ambientLight,
        soundLevel,
      );

  @override
  String toString() =>
      'NerveState(battery: ${(batteryLevel * 100).toInt()}%, '
      'charging: $isCharging, network: $networkQuality, '
      'tilt: ($tiltX, $tiltY), light: $ambientLight lux, '
      'sound: $soundLevel)';
}

/// Quality tiers of network connectivity.
enum NetworkQuality {
  /// No network connection at all.
  none,

  /// Very weak or intermittent connection.
  poor,

  /// Moderate connectivity.
  fair,

  /// Strong, reliable connectivity.
  good,
}
