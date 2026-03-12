import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nerve/flutter_nerve.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake sense adapters — lightweight stubs that emit controlled streams.
// They mirror the real API so NerveController can accept them via DI.
// ─────────────────────────────────────────────────────────────────────────────

class FakeBatterySense extends BatterySense {
  final StreamController<(double, bool)> _ctl = StreamController.broadcast();

  FakeBatterySense();

  @override
  Stream<(double, bool)> get stream => _ctl.stream;

  void emit(double level, bool charging) => _ctl.add((level, charging));

  @override
  void dispose() => _ctl.close();
}

class FakeNetworkSense extends NetworkSense {
  final StreamController<NetworkQuality> _ctl = StreamController.broadcast();

  FakeNetworkSense();

  @override
  Stream<NetworkQuality> get stream => _ctl.stream;

  void emit(NetworkQuality quality) => _ctl.add(quality);

  @override
  Future<void> dispose() async => _ctl.close();
}

class FakeMotionSense extends MotionSense {
  final StreamController<(double, double)> _ctl = StreamController.broadcast();

  FakeMotionSense();

  @override
  Stream<(double, double)> get stream => _ctl.stream;

  void emit(double x, double y) => _ctl.add((x, y));

  @override
  void dispose() => _ctl.close();
}

class FakeLightSense extends LightSense {
  final StreamController<double> _ctl = StreamController.broadcast();

  FakeLightSense();

  @override
  Stream<double> get stream => _ctl.stream;

  void emit(double lux) => _ctl.add(lux);

  @override
  void dispose() => _ctl.close();
}

class FakeSoundSense extends SoundSense {
  final StreamController<double> _ctl = StreamController.broadcast();

  FakeSoundSense();

  @override
  Stream<double> get stream => _ctl.stream;

  void emit(double level) => _ctl.add(level);

  @override
  Future<void> dispose() async => _ctl.close();
}

/// Creates a fully-stubbed [NerveController] and returns it together with
/// its individual fake senses.
({
  NerveController controller,
  FakeBatterySense battery,
  FakeNetworkSense network,
  FakeMotionSense motion,
  FakeLightSense light,
  FakeSoundSense sound,
}) makeFakeController() {
  final battery = FakeBatterySense();
  final network = FakeNetworkSense();
  final motion = FakeMotionSense();
  final light = FakeLightSense();
  final sound = FakeSoundSense();
  final controller = NerveController(
    battery: battery,
    network: network,
    motion: motion,
    light: light,
    sound: sound,
  );
  controller.init();
  return (
    controller: controller,
    battery: battery,
    network: network,
    motion: motion,
    light: light,
    sound: sound,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── NerveState ──────────────────────────────────────────────────────────────
  group('NerveState', () {
    test('default state has sensible values', () {
      const state = NerveState();
      expect(state.batteryLevel, 1.0);
      expect(state.isCharging, false);
      expect(state.networkQuality, NetworkQuality.good);
      expect(state.tiltX, 0.0);
      expect(state.tiltY, 0.0);
      expect(state.ambientLight, isNull);
      expect(state.soundLevel, isNull);
    });

    test('copyWith overrides only specified fields', () {
      const original = NerveState(batteryLevel: 0.8, tiltX: 0.3);
      final copy = original.copyWith(batteryLevel: 0.2);
      expect(copy.batteryLevel, 0.2);
      expect(copy.tiltX, 0.3); // unchanged
    });

    test('copyWith preserves null optional fields when not overridden', () {
      const state = NerveState(); // ambientLight & soundLevel are null
      final copy = state.copyWith(batteryLevel: 0.5);
      expect(copy.ambientLight, isNull);
      expect(copy.soundLevel, isNull);
    });

    test('copyWith can set optional double fields', () {
      const state = NerveState();
      final copy = state.copyWith(ambientLight: 300.0, soundLevel: 0.7);
      expect(copy.ambientLight, 300.0);
      expect(copy.soundLevel, 0.7);
    });

    test('equality holds for identical values', () {
      const a = NerveState(
          batteryLevel: 0.5, networkQuality: NetworkQuality.poor);
      const b = NerveState(
          batteryLevel: 0.5, networkQuality: NetworkQuality.poor);
      expect(a, equals(b));
    });

    test('inequality detected on any field change', () {
      const a = NerveState(batteryLevel: 0.5);
      final b = a.copyWith(batteryLevel: 0.4);
      expect(a, isNot(equals(b)));
    });

    test('inequality on optional fields', () {
      const a = NerveState(ambientLight: 100.0);
      const b = NerveState(ambientLight: 200.0);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent with equality', () {
      const a = NerveState(tiltY: 0.7, isCharging: true);
      const b = NerveState(tiltY: 0.7, isCharging: true);
      expect(a.hashCode, b.hashCode);
    });

    test('different states have different hashCodes (collision unlikely)', () {
      const a = NerveState(batteryLevel: 0.1);
      const b = NerveState(batteryLevel: 0.9);
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });

    test('toString contains battery percent', () {
      const state = NerveState(batteryLevel: 0.5, isCharging: true);
      expect(state.toString(), contains('50%'));
      expect(state.toString(), contains('charging: true'));
    });

    test('toString contains network quality', () {
      const state = NerveState(networkQuality: NetworkQuality.poor);
      expect(state.toString(), contains('poor'));
    });
  });

  // ── NetworkQuality ──────────────────────────────────────────────────────────
  group('NetworkQuality', () {
    test('all four tiers exist', () {
      expect(NetworkQuality.values.length, 4);
      expect(
        NetworkQuality.values,
        containsAll([
          NetworkQuality.none,
          NetworkQuality.poor,
          NetworkQuality.fair,
          NetworkQuality.good,
        ]),
      );
    });

    test('none < poor < fair < good in index order', () {
      expect(NetworkQuality.none.index, lessThan(NetworkQuality.poor.index));
      expect(NetworkQuality.poor.index, lessThan(NetworkQuality.fair.index));
      expect(NetworkQuality.fair.index, lessThan(NetworkQuality.good.index));
    });
  });

  // ── MotionSense static helper ───────────────────────────────────────────────
  group('MotionSense.magnitude', () {
    test('zero tilt → magnitude 0', () {
      expect(MotionSense.magnitude(0.0, 0.0), 0.0);
    });

    test('unit X tilt → magnitude 1', () {
      expect(MotionSense.magnitude(1.0, 0.0), 1.0);
    });

    test('3-4-5 triangle → magnitude clamped to 1', () {
      // 0.6² + 0.8² = 1.0 → sqrt = 1.0
      expect(MotionSense.magnitude(0.6, 0.8), closeTo(1.0, 0.0001));
    });

    test('small tilt is proportional', () {
      final m = MotionSense.magnitude(0.3, 0.4);
      expect(m, closeTo(sqrt(0.3 * 0.3 + 0.4 * 0.4), 0.0001));
    });

    test('magnitude is always ≥ 0', () {
      expect(MotionSense.magnitude(-0.5, -0.5), greaterThanOrEqualTo(0.0));
    });
  });

  // ── NerveController ─────────────────────────────────────────────────────────
  group('NerveController', () {
    test('initial state matches NerveState defaults', () {
      final controller = NerveController();
      expect(controller.state, const NerveState());
      controller.dispose();
    });

    test('battery stream updates state', () async {
      final f = makeFakeController();
      f.battery.emit(0.42, true);
      await Future<void>.delayed(Duration.zero);
      expect(f.controller.state.batteryLevel, closeTo(0.42, 0.001));
      expect(f.controller.state.isCharging, isTrue);
      f.controller.dispose();
    });

    test('network stream updates state', () async {
      final f = makeFakeController();
      f.network.emit(NetworkQuality.none);
      await Future<void>.delayed(Duration.zero);
      expect(f.controller.state.networkQuality, NetworkQuality.none);
      f.controller.dispose();
    });

    test('motion stream updates tilt', () async {
      final f = makeFakeController();
      f.motion.emit(0.5, -0.3);
      await Future<void>.delayed(Duration.zero);
      expect(f.controller.state.tiltX, closeTo(0.5, 0.001));
      expect(f.controller.state.tiltY, closeTo(-0.3, 0.001));
      f.controller.dispose();
    });

    test('light stream updates ambientLight', () async {
      final f = makeFakeController();
      f.light.emit(500.0);
      await Future<void>.delayed(Duration.zero);
      expect(f.controller.state.ambientLight, closeTo(500.0, 0.1));
      f.controller.dispose();
    });

    test('sound stream updates soundLevel', () async {
      final f = makeFakeController();
      f.sound.emit(0.8);
      await Future<void>.delayed(Duration.zero);
      expect(f.controller.state.soundLevel, closeTo(0.8, 0.001));
      f.controller.dispose();
    });

    test('notifies listeners when state changes', () async {
      final f = makeFakeController();
      int notifications = 0;
      f.controller.addListener(() => notifications++);
      f.battery.emit(0.3, false);
      await Future<void>.delayed(Duration.zero);
      expect(notifications, 1);
      f.controller.dispose();
    });

    test('does NOT double-notify for identical state', () async {
      final f = makeFakeController();
      int notifications = 0;
      f.controller.addListener(() => notifications++);
      // Same value twice
      f.battery.emit(0.5, false);
      f.battery.emit(0.5, false);
      await Future<void>.delayed(Duration.zero);
      // Second emit is identical → no second notification
      expect(notifications, 1);
      f.controller.dispose();
    });

    test('dispose cancels all subscriptions without throwing', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final f = makeFakeController();
      expect(() => f.controller.dispose(), returnsNormally);
    });

    test('multiple sequential updates accumulate correctly', () async {
      final f = makeFakeController();
      f.battery.emit(0.9, true);
      f.network.emit(NetworkQuality.fair);
      f.motion.emit(0.1, 0.2);
      await Future<void>.delayed(Duration.zero);
      final s = f.controller.state;
      expect(s.batteryLevel, closeTo(0.9, 0.001));
      expect(s.networkQuality, NetworkQuality.fair);
      expect(s.tiltX, closeTo(0.1, 0.001));
      f.controller.dispose();
    });
  });

  // ── Widget Tests ─────────────────────────────────────────────────────────────
  group('NerveBuilder widget', () {
    testWidgets('renders builder output from initial state', (tester) async {
      final f = makeFakeController();
      await tester.pumpWidget(
        NerveProvider(
          controller: f.controller,
          child: Builder(
            builder: (context) => NerveBuilder(
              builder: (ctx, state, child) {
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    'bat:${(state.batteryLevel * 100).toInt()}',
                  ),
                );
              },
            ),
          ),
        ),
      );
      expect(find.text('bat:100'), findsOneWidget);
      f.controller.dispose();
    });

    testWidgets('rebuilds when state changes', (tester) async {
      final f = makeFakeController();
      await tester.pumpWidget(
        NerveProvider(
          controller: f.controller,
          child: Builder(
            builder: (context) => NerveBuilder(
              builder: (ctx, state, child) {
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    'q:${state.networkQuality.name}',
                  ),
                );
              },
            ),
          ),
        ),
      );
      expect(find.text('q:good'), findsOneWidget);

      f.network.emit(NetworkQuality.poor);
      await tester.pumpAndSettle();

      expect(find.text('q:poor'), findsOneWidget);
      f.controller.dispose();
    });

    testWidgets('optional child is passed through', (tester) async {
      final f = makeFakeController();
      const childKey = Key('static-child');
      await tester.pumpWidget(
        NerveProvider(
          controller: f.controller,
          child: NerveBuilder(
            builder: (ctx, state, child) => Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            ),
            child: const SizedBox(key: childKey),
          ),
        ),
      );
      expect(find.byKey(childKey), findsOneWidget);
      f.controller.dispose();
    });
  });

  group('ReactiveContainer widget', () {
    testWidgets('renders with no mappers (all defaults)', (tester) async {
      final f = makeFakeController();
      await tester.pumpWidget(
        NerveProvider(
          controller: f.controller,
          child: const ReactiveContainer(
            width: 100,
            height: 100,
          ),
        ),
      );
      expect(find.byType(ReactiveContainer), findsOneWidget);
      f.controller.dispose();
    });

    testWidgets('colorMapper is called with current state', (tester) async {
      final f = makeFakeController();
      Color? captured;
      await tester.pumpWidget(
        NerveProvider(
          controller: f.controller,
          child: ReactiveContainer(
            width: 100,
            height: 100,
            colorMapper: (state) {
              captured = state.batteryLevel >= 0.5
                  ? const Color(0xFF00FF00)
                  : const Color(0xFFFF0000);
              return captured!;
            },
          ),
        ),
      );
      await tester.pump();
      // Default battery is 1.0 → green
      expect(captured, const Color(0xFF00FF00));
      f.controller.dispose();
    });
  });

  // ── NerveProvider ────────────────────────────────────────────────────────────
  group('NerveProvider', () {
    testWidgets('NerveProvider.of returns current state', (tester) async {
      final f = makeFakeController();
      NerveState? captured;
      await tester.pumpWidget(
        NerveProvider(
          controller: f.controller,
          child: Builder(builder: (ctx) {
            captured = NerveProvider.of(ctx);
            return const SizedBox.shrink();
          }),
        ),
      );
      expect(captured, isNotNull);
      expect(captured!.batteryLevel, 1.0);
      f.controller.dispose();
    });

    testWidgets('NerveProvider.controllerOf returns controller', (tester) async {
      final f = makeFakeController();
      NerveController? captured;
      await tester.pumpWidget(
        NerveProvider(
          controller: f.controller,
          child: Builder(builder: (ctx) {
            captured = NerveProvider.controllerOf(ctx);
            return const SizedBox.shrink();
          }),
        ),
      );
      expect(captured, same(f.controller));
      f.controller.dispose();
    });
  });
}
