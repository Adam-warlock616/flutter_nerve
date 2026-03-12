import 'package:flutter/material.dart';
import 'package:flutter_nerve/flutter_nerve.dart';

void main() {
  runApp(const NerveExampleApp());
}

class NerveExampleApp extends StatelessWidget {
  const NerveExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // enableMicrophone: true → NerveRoot requests mic permission and starts
    // the real SoundSense stream automatically, no async boilerplate needed.
    return NerveRoot(
      enableMicrophone: true,
      child: NerveBuilder(
        builder: (context, state, _) {
          final theme = NerveTheme.resolve(context, state);
          return MaterialApp(
            title: 'flutter_nerve demo',
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const _DemoPage(),
          );
        },
      ),
    );
  }
}


class _DemoPage extends StatelessWidget {
  const _DemoPage();

  @override
  Widget build(BuildContext context) {
    return NerveScaffold(
      showNetworkBanner: false, // we use NerveConnectivity below instead
      parallaxDepth: 16,
      appBar: AppBar(
        title: const Text(
          'flutter_nerve',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: const NerveConnectivity(
        child: _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return NerveMonitor(
      startCollapsed: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroCard(),
            const SizedBox(height: 20),
            const _SenseDashboard(),
            const SizedBox(height: 20),
            const _WidgetShowcase(),
            const SizedBox(height: 20),
            const _ThemeShowcase(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Hero card with tilt parallax ─────────────────────────────────────────────

class _HeroCard extends StatefulWidget {
  const _HeroCard();

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  int _shakeCount = 0;

  @override
  Widget build(BuildContext context) {
    return NerveShake(
      onShake: () => setState(() => _shakeCount++),
      child: NerveBuilder(
        builder: (context, state, _) {
          final tiltX = state.tiltX;
          final tiltY = state.tiltY;
          final cs = Theme.of(context).colorScheme;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment(-tiltX, -tiltY),
                end: Alignment(tiltX + 0.3, tiltY + 0.3),
                colors: [cs.primary, cs.secondary, cs.tertiary],
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: Offset(tiltX * 8, tiltY * 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Parallax inner orb
                Positioned(
                  left: 60 + tiltX * 20,
                  top: 40 + tiltY * 20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  right: 30 - tiltX * 12,
                  bottom: 20 - tiltY * 12,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // NerveSpring gives the icon a floating parallax feel
                      NerveSpring(
                        depth: 12,
                        child: Icon(
                          _shakeCount > 0 ? Icons.celebration : Icons.sensors,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _shakeCount > 0
                            ? 'Shaken $_shakeCount time${_shakeCount == 1 ? '' : 's'}! 🎉'
                            : 'Sensory-Reactive UI',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _shakeCount > 0
                            ? 'Keep shaking!'
                            : 'Tilt: (${tiltX.toStringAsFixed(2)}, ${tiltY.toStringAsFixed(2)})',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


// ── Widget Showcase ────────────────────────────────────────────────────────────

class _WidgetShowcase extends StatelessWidget {
  const _WidgetShowcase();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Widgets',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // NerveBatteryIcon
              Column(
                children: [
                  const NerveBatteryIcon(size: 48),
                  const SizedBox(height: 8),
                  Text('NerveBatteryIcon',
                      style: TextStyle(
                          fontSize: 10, color: cs.onSurfaceVariant)),
                ],
              ),
              // NervePulse
              Column(
                children: [
                  NervePulse(
                    maxScale: 1.4,
                    pulseOpacity: true,
                    child: Icon(Icons.mic,
                        size: 48, color: cs.primary),
                  ),
                  const SizedBox(height: 8),
                  Text('NervePulse',
                      style: TextStyle(
                          fontSize: 10, color: cs.onSurfaceVariant)),
                ],
              ),
              // NerveGlow
              Column(
                children: [
                  NerveGlow(
                    color: cs.primary,
                    maxBlurRadius: 28,
                    borderRadius: 40,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withValues(alpha: 0.2),
                      ),
                      child: Icon(Icons.sensors,
                          size: 28, color: cs.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('NerveGlow',
                      style: TextStyle(
                          fontSize: 10, color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tilt your phone to see NerveGlow react • make noise for NervePulse',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Sense Dashboard ───────────────────────────────────────────────────────────


class _SenseDashboard extends StatelessWidget {
  const _SenseDashboard();

  @override
  Widget build(BuildContext context) {
    return NerveBuilder(
      builder: (context, state, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Sensors',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _SenseCard(
                  icon: Icons.battery_std,
                  label: 'Battery',
                  value: '${(state.batteryLevel * 100).toInt()}%',
                  subtitle: state.isCharging ? '⚡ Charging' : 'Discharging',
                  progress: state.batteryLevel,
                  color: _batteryColor(state.batteryLevel),
                ),
                _SenseCard(
                  icon: Icons.wifi,
                  label: 'Network',
                  value: _networkLabel(state.networkQuality),
                  subtitle: state.networkQuality.name.toUpperCase(),
                  progress: _networkProgress(state.networkQuality),
                  color: _networkColor(state.networkQuality),
                ),
                _SenseCard(
                  icon: Icons.screen_rotation,
                  label: 'Motion',
                  value:
                      '${(MotionSense.magnitude(state.tiltX, state.tiltY) * 100).toInt()}%',
                  subtitle:
                      'X:${state.tiltX.toStringAsFixed(2)} Y:${state.tiltY.toStringAsFixed(2)}',
                  progress:
                      MotionSense.magnitude(state.tiltX, state.tiltY),
                  color: Colors.purple,
                ),
                _SenseCard(
                  icon: Icons.mic,
                  label: 'Sound',
                  value: state.soundLevel != null
                      ? '${(state.soundLevel! * 100).toInt()}%'
                      : 'N/A',
                  subtitle: 'Ambient Level',
                  progress: state.soundLevel ?? 0.0,
                  color: Colors.indigo,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _networkLabel(NetworkQuality q) => switch (q) {
        NetworkQuality.none => '✗',
        NetworkQuality.poor => '▁',
        NetworkQuality.fair => '▃',
        NetworkQuality.good => '▇',
      };

  double _networkProgress(NetworkQuality q) => switch (q) {
        NetworkQuality.none => 0.0,
        NetworkQuality.poor => 0.25,
        NetworkQuality.fair => 0.6,
        NetworkQuality.good => 1.0,
      };

  Color _batteryColor(double level) {
    if (level < 0.15) return Colors.red;
    if (level < 0.4) return Colors.orange;
    return Colors.green;
  }

  Color _networkColor(NetworkQuality q) => switch (q) {
        NetworkQuality.none => Colors.red,
        NetworkQuality.poor => Colors.orange,
        NetworkQuality.fair => Colors.yellow.shade700,
        NetworkQuality.good => Colors.green,
      };
}

class _SenseCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final double progress;
  final Color color;

  const _SenseCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.15),
              color: color,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Theme Showcase ────────────────────────────────────────────────────────────

class _ThemeShowcase extends StatelessWidget {
  const _ThemeShowcase();

  @override
  Widget build(BuildContext context) {
    return NerveBuilder(
      builder: (context, state, _) {
        final cs = Theme.of(context).colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adaptive Theme',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer,
                    cs.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ThemeRule(
                    active: state.batteryLevel < 0.15,
                    label: 'Low battery — greyscale palette',
                  ),
                  _ThemeRule(
                    active: state.networkQuality == NetworkQuality.none,
                    label: 'No network — red tint',
                  ),
                  _ThemeRule(
                    active: state.networkQuality == NetworkQuality.poor,
                    label: 'Poor network — orange warning',
                  ),
                  _ThemeRule(
                    active: (state.soundLevel ?? 0) > 0.7,
                    label: 'High sound — vibrant cyan',
                  ),
                  _ThemeRule(
                    active: state.tiltX.abs() > 0.3,
                    label: 'Tilted — hue shift',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ReactiveContainer(
              colorMapper: (s) => Color.lerp(
                cs.primaryContainer,
                cs.tertiaryContainer,
                s.batteryLevel,
              )!,
              scaleMapper: (s) =>
                  1.0 + MotionSense.magnitude(s.tiltX, s.tiltY) * 0.08,
              animationDuration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome),
                  const SizedBox(width: 8),
                  Text(
                    'ReactiveContainer — tilt me!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeRule extends StatelessWidget {
  final bool active;
  final String label;

  const _ThemeRule({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? Colors.greenAccent : Colors.white24,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontWeight:
                  active ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
