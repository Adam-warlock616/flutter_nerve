import 'dart:math';
import 'package:flutter/material.dart';
import '../nerve_provider.dart';
import '../models/nerve_state.dart';

/// A floating, draggable debug overlay that shows live [NerveState] readings.
///
/// Place it at the top of your widget tree (inside a [Stack] or by wrapping
/// your app body). It can be collapsed to a small icon to stay out of the way.
///
/// Example:
/// ```dart
/// NerveMonitor(
///   child: MyApp(),
/// )
/// ```
///
/// > 💡 Strip from production builds using `kDebugMode`:
/// > ```dart
/// > if (kDebugMode) NerveMonitor(child: body) else body
/// > ```
class NerveMonitor extends StatefulWidget {
  final Widget child;

  /// Initial position of the monitor panel. Defaults to top-right.
  final Offset initialOffset;

  /// Whether the monitor starts collapsed. Defaults to `false`.
  final bool startCollapsed;

  const NerveMonitor({
    super.key,
    required this.child,
    this.initialOffset = const Offset(8, 60),
    this.startCollapsed = false,
  });

  @override
  State<NerveMonitor> createState() => _NerveMonitorState();
}

class _NerveMonitorState extends State<NerveMonitor> {
  late Offset _offset;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
    _collapsed = widget.startCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    final state = NerveProvider.of(context);
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: _offset.dx,
          top: _offset.dy,
          child: GestureDetector(
            onPanUpdate: (d) =>
                setState(() => _offset += d.delta),
            child: _MonitorPanel(
              state: state,
              collapsed: _collapsed,
              onToggle: () => setState(() => _collapsed = !_collapsed),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonitorPanel extends StatelessWidget {
  final NerveState state;
  final bool collapsed;
  final VoidCallback onToggle;

  const _MonitorPanel({
    required this.state,
    required this.collapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: collapsed ? 44 : 200,
        decoration: BoxDecoration(
          color: const Color(0xDD1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x4400E5FF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4400E5FF),
              blurRadius: 12,
            ),
          ],
        ),
        child: collapsed ? _CollapsedIcon() : _ExpandedContent(state: state),
      ),
    );
  }
}

class _CollapsedIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: Text('🧠', style: TextStyle(fontSize: 22)),
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final NerveState state;

  const _ExpandedContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final bat = state.batteryLevel;
    final tiltMag = sqrt(
      state.tiltX * state.tiltX + state.tiltY * state.tiltY,
    ).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              const Text(
                'NerveMonitor',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              const Text(
                '▾',
                style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Row(
            label: '🔋 Battery',
            value:
                '${(bat * 100).toInt()}%  ${state.isCharging ? "⚡" : ""}',
            barValue: bat,
            barColor: bat < 0.15
                ? const Color(0xFFE53935)
                : bat < 0.4
                    ? const Color(0xFFFB8C00)
                    : const Color(0xFF43A047),
          ),
          _Row(
            label: '📶 Network',
            value: state.networkQuality.name,
            barValue: _netProgress(state.networkQuality),
            barColor: const Color(0xFF40C4FF),
          ),
          _Row(
            label: '📐 Tilt',
            value:
                'X:${state.tiltX.toStringAsFixed(2)} Y:${state.tiltY.toStringAsFixed(2)}',
            barValue: tiltMag,
            barColor: const Color(0xFFCE93D8),
          ),
          _Row(
            label: '💡 Light',
            value: state.ambientLight != null
                ? '${state.ambientLight!.toInt()} lux'
                : 'N/A',
            barValue: state.ambientLight != null
                ? (state.ambientLight! / 10000).clamp(0.0, 1.0)
                : 0,
            barColor: const Color(0xFFFFD54F),
          ),
          _Row(
            label: '🎤 Sound',
            value: state.soundLevel != null
                ? '${(state.soundLevel! * 100).toInt()}%'
                : 'N/A',
            barValue: state.soundLevel ?? 0,
            barColor: const Color(0xFFFF7043),
          ),
        ],
      ),
    );
  }

  double _netProgress(NetworkQuality q) => switch (q) {
        NetworkQuality.none => 0.0,
        NetworkQuality.poor => 0.25,
        NetworkQuality.fair => 0.6,
        NetworkQuality.good => 1.0,
      };
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final double barValue;
  final Color barColor;

  const _Row({
    required this.label,
    required this.value,
    required this.barValue,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Color(0xAAFFFFFF), fontSize: 9)),
              Text(value,
                  style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: barValue.clamp(0.0, 1.0),
              backgroundColor: barColor.withValues(alpha: 0.15),
              color: barColor,
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
