# Changelog

All notable changes to `flutter_nerve` will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## 0.2.0 — 2026-03-12

### Added
- `NerveMonitor` — floating, draggable debug overlay showing all live sensor readings with mini gauges. Tap to collapse to a 🧠 icon.
- `NerveShake` — detects shake gestures via accelerometer magnitude spikes; fires `onShake` callback with configurable threshold & cooldown.
- `NerveSpring` — physics-spring offset animation driven by tiltX/tiltY, creating a natural floating/parallax effect.
- `NerveConnectivity` — pre-built animated banner that slides in when network is `poor` or `none`; fully customizable.
- `NerveFakes` — testing utilities (`withBattery`, `withNetwork`, `withMotion`, `withLight`, `withSound`, `withAllSenses`) for easy `testWidgets` without real hardware.

---

## 0.1.0 — 2025-03-11


### Added
- `NervePulse` — widget that pulses (scales + optional opacity) in sync with ambient sound level.
- `NerveGlow` — widget with an animated glowing border driven by tilt magnitude or a custom mapper.
- `NerveBatteryIcon` — custom-painted animated battery indicator (color-coded, charging bolt overlay).
- `NerveController.withMicrophone()` — async factory that initialises microphone permission & stream in one call.
- `NerveRoot.enableMicrophone` flag — pass `enableMicrophone: true` to have `NerveRoot` manage mic init automatically; no async `main()` required.

### Fixed
- Default `SoundSense()` was a silent stub; example app now uses the real microphone via `enableMicrophone: true`.

---



Initial release 🎉

### Added

**Core**
- `NerveState` — immutable snapshot of all sensor readings (battery, charging,
  network quality, tilt X/Y, ambient light, sound level).
- `NerveController` — aggregates all sense streams into a single reactive
  `ChangeNotifier`. Accepts injected adapters for easy testing.
- `NerveProvider` — `InheritedNotifier<NerveController>` that feeds the widget
  tree; exposes `NerveProvider.of(context)` and `NerveProvider.controllerOf(context)`.
- `NerveRoot` — convenience `StatefulWidget` that owns and initialises a
  `NerveController` automatically.

**Sense Adapters**
- `BatterySense` — polls `battery_plus` on a configurable interval and emits
  `(level 0.0–1.0, isCharging)` pairs.
- `NetworkSense` — wraps `connectivity_plus`, mapping `ConnectivityResult` values
  to a four-tier `NetworkQuality` enum (`none | poor | fair | good`).
- `MotionSense` — wraps `sensors_plus` accelerometer events; normalises raw
  m/s² to -1.0..1.0 tilt values. Includes `MotionSense.magnitude()` helper.
- `LightSense` — wraps the `light` package to emit ambient lux readings.
- `SoundSense` — uses `record` package to sample audio amplitude at a
  configurable rate and normalize it to 0.0–1.0.

**Reactive Widgets**
- `NerveBuilder` — rebuilds its subtree on every `NerveState` change, analogous
  to `AnimatedBuilder`.
- `ReactiveContainer` — animated container whose color, scale, and blur react to
  sensor data via mapper callbacks.
- `NerveScaffold` — full-screen scaffold with configurable background gradient,
  adaptive status-bar style, and optional motion-parallax header.

**Adaptive Theme**
- `NerveTheme` — derives `ThemeData` from the current `NerveState` (e.g. dims
  the palette when battery is low, darkens when ambient light is low).
