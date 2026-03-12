import 'package:flutter/widgets.dart';
import '../models/nerve_state.dart';
import '../nerve_provider.dart';

/// A widget that rebuilds whenever the [NerveState] changes — analogous to
/// [AnimatedBuilder] but for sensory data.
///
/// Example:
/// ```dart
/// NerveBuilder(
///   builder: (context, state, child) {
///     return Opacity(opacity: state.batteryLevel, child: child);
///   },
///   child: const Icon(Icons.battery_full),
/// )
/// ```
class NerveBuilder extends StatelessWidget {
  /// Called on every [NerveState] change, building the reactive subtree.
  final Widget Function(BuildContext context, NerveState state, Widget? child)
      builder;

  /// Optional subtree that does not depend on [NerveState] and will not rebuild.
  final Widget? child;

  const NerveBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final state = NerveProvider.of(context);
    return builder(context, state, child);
  }
}
