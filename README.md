# flutter_nerve

**A sensory-reactive UI engine for Flutter.** Make your app feel the real world — react to battery level, network quality, motion, ambient light, and sound with zero boilerplate.

[![pub.dev](https://img.shields.io/pub/v/flutter_nerve.svg)](https://pub.dev/packages/flutter_nerve)
[![CI](https://github.com/Adam-warlock616/flutter_nerve/actions/workflows/ci.yml/badge.svg)](https://github.com/Adam-warlock616/flutter_nerve/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## Platform Support

| Sensor | Android | iOS | Web | Desktop |
|--------|:-------:|:---:|:---:|:-------:|
| Battery | ✅ | ✅ | ⚠️ partial | ✅ |
| Network | ✅ | ✅ | ✅ | ✅ |
| Motion (accelerometer) | ✅ | ✅ | ❌ | ❌ |
| Ambient Light | ✅ | ⚠️ entitlement | ❌ | ❌ |
| Sound (microphone) | ✅ | ✅ | ❌ | ❌ |

---

## Quick Start

### 1. Add the dependency

```yaml
dependencies:
  flutter_nerve: ^0.2.0
```

### 2. Wrap your app

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NerveRoot(
      enableMicrophone: true,  // requests mic permission automatically
      child: MaterialApp(home: MyHomePage()),
    );
  }
}
```

### 3. Read sensor data anywhere

```dart
// Inside any descendant widget:
final state = NerveProvider.of(context);
print(state.batteryLevel);     // 0.0 – 1.0
print(state.networkQuality);   // NetworkQuality.good / fair / poor / none
print(state.tiltX);            // -1.0 – 1.0
print(state.soundLevel);       // 0.0 – 1.0 (null if unavailable)
print(state.ambientLight);     // lux (null if unavailable)
```

---

## Reactive Widgets

### `NerveBuilder`

Rebuilds on every sensor update — like `AnimatedBuilder` but for device senses:

```dart
NerveBuilder(
  builder: (context, state, child) {
    return Opacity(
      opacity: state.batteryLevel,
      child: child,
    );
  },
  child: const BatteryIcon(),
)
```

### `ReactiveContainer`

A container whose color, scale, and blur are driven by sensor state:

```dart
ReactiveContainer(
  colorMapper: (s) => Color.lerp(Colors.red, Colors.green, s.batteryLevel)!,
  scaleMapper: (s) => 1.0 + MotionSense.magnitude(s.tiltX, s.tiltY) * 0.15,
  child: const FlutterLogo(size: 100),
)
```

### `NervePulse`

Pulses (scales) a child widget in sync with ambient sound level:

```dart
NervePulse(
  maxScale: 1.3,
  pulseOpacity: true,
  child: const Icon(Icons.mic, size: 64),
)
```

### `NerveGlow`

Animates a glowing border driven by tilt magnitude or a custom mapper:

```dart
NerveGlow(
  color: Colors.purpleAccent,
  maxBlurRadius: 24,
  child: const FlutterLogo(size: 80),
)
```

### `NerveBatteryIcon`

Custom-painted animated battery icon — color-coded, ⚡ when charging:

```dart
NerveBatteryIcon(size: 48)
```

### `NerveScaffold`

Full-screen scaffold with sensor-reactive gradient background and motion-parallax header:

```dart
NerveScaffold(
  parallaxDepth: 20,
  showNetworkBanner: true,
  body: MyContent(),
)
```

### `NerveMonitor`

Floating, draggable debug overlay showing all live sensor readings. Tap to collapse to a 🧠 icon. Use inside `kDebugMode` to strip from production:

```dart
NerveMonitor(
  startCollapsed: true,   // starts as a small icon
  child: MyScaffoldBody(),
)
```

### `NerveShake`

Detects shake gestures via accelerometer spikes. Fires `onShake` with cooldown:

```dart
NerveShake(
  threshold: 0.65,         // 0.0–1.0, how strong a shake is required
  cooldown: Duration(milliseconds: 600),
  onShake: () => setState(() => _count++),
  child: myWidget,
)
```

### `NerveSpring`

Applies a physics-spring offset to its child driven by tilt, creating a floating parallax feel:

```dart
NerveSpring(
  depth: 20,    // max pixel offset at full tilt
  child: const FlutterLogo(size: 100),
)
```

### `NerveConnectivity`

Pre-built animated banner that slides in when network is poor or gone:

```dart
NerveConnectivity(
  child: MyContent(),
  // Optional: supply your own banners
  noBanner: MyNoBannerWidget(),
  poorBanner: MyPoorBannerWidget(),
)
```

---

## Testing with `NerveFakes`

Test any widget without real hardware using pre-set sensor controllers:

```dart
testWidgets('shows red theme on low battery', (tester) async {
  final ctrl = NerveFakes.withBattery(0.05);
  await tester.pumpWidget(
    NerveRoot(controller: ctrl, child: MyApp()),
  );
  expect(find.text('Low Battery!'), findsOneWidget);
  ctrl.dispose();
});

// Other factories:
NerveFakes.withNetwork(NetworkQuality.none);
NerveFakes.withMotion(0.5, -0.3);
NerveFakes.withLight(200.0);
NerveFakes.withSound(0.8);
NerveFakes.withAllSenses(batteryLevel: 0.1, charging: false, soundLevel: 0.9);
```

---



## Adaptive Theme

`NerveTheme.resolve()` returns a `ThemeData` that automatically adapts to sensor readings:

| Condition | Effect |
|-----------|--------|
| Battery < 15% | Greyscale palette |
| No network | Red tint |
| Poor network | Orange warning tint |
| Sound level > 70% | Vibrant cyan palette |
| Tilted > 30% | Hue shift |

```dart
NerveBuilder(
  builder: (context, state, _) {
    return MaterialApp(
      theme: NerveTheme.resolve(context, state),
      home: MyHomePage(),
    );
  },
)
```

---

## Custom Sense Adapters

Inject your own sensor streams via the `NerveController` constructor for testing or custom data sources:

```dart
final controller = NerveController(
  battery: MyCustomBatterySense(),
  sound: SoundSense.withStream(myAudioStream),
);

NerveRoot(controller: controller, child: MyApp())
```

---

## Permissions

Add the following to your app (not the package itself):

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used to detect ambient sound level for reactive UI effects.</string>
```

---

## License

MIT — see [LICENSE](LICENSE).
