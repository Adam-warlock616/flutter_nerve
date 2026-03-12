import 'package:flutter/widgets.dart';
import 'nerve_controller.dart';
import 'models/nerve_state.dart';

/// Root widget that provides a [NerveController] to the widget tree.
///
/// Place this high in your widget tree (typically wrapping `MaterialApp`):
/// ```dart
/// NerveProvider(
///   child: MaterialApp(home: MyHomePage()),
/// )
/// ```
///
/// Access the current [NerveState] anywhere via [NerveProvider.of]:
/// ```dart
/// final state = NerveProvider.of(context);
/// ```
class NerveProvider extends InheritedNotifier<NerveController> {
  /// Creates a [NerveProvider] with an automatically-managed [NerveController].
  NerveProvider({
    super.key,
    NerveController? controller,
    required super.child,
  }) : super(notifier: controller ?? NerveController());

  /// Returns the nearest [NerveState] in the widget tree.
  ///
  /// Throws if no [NerveProvider] ancestor is found.
  static NerveState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<NerveProvider>();
    assert(
      provider != null,
      'NerveProvider.of() called with a context that does not contain a '
      'NerveProvider. Make sure NerveProvider wraps your app.',
    );
    return provider!.notifier!.state;
  }

  /// Returns the [NerveController] from the nearest [NerveProvider].
  static NerveController controllerOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<NerveProvider>();
    assert(
      provider != null,
      'NerveProvider.controllerOf() called outside a NerveProvider.',
    );
    return provider!.notifier!;
  }
}

/// A stateful widget that initialises [NerveController] via [NerveProvider].
///
/// This is the **recommended** entry point — it calls `init()` and `dispose()`
/// automatically.
///
/// ```dart
/// void main() => runApp(const NerveApp());
///
/// class NerveApp extends StatelessWidget {
///   const NerveApp({super.key});
///   @override
///   Widget build(BuildContext context) {
///     return NerveRoot(
///       child: MaterialApp(home: MyHomePage()),
///     );
///   }
/// }
/// ```
class NerveRoot extends StatefulWidget {
  final Widget child;

  /// Optional pre-built controller. If provided, [enableMicrophone] is ignored.
  final NerveController? controller;

  /// When `true` and no [controller] is supplied, [NerveRoot] will
  /// asynchronously call [NerveController.withMicrophone()] which requests
  /// microphone permission and starts the real sound stream automatically.
  ///
  /// The [loadingWidget] is shown while the controller initialises.
  /// Defaults to a blank [SizedBox].
  final bool enableMicrophone;

  /// Widget shown while the async controller is being initialised.
  /// Only relevant when [enableMicrophone] is `true`.
  final Widget loadingWidget;

  const NerveRoot({
    super.key,
    required this.child,
    this.controller,
    this.enableMicrophone = false,
    this.loadingWidget = const SizedBox.shrink(),
  });

  @override
  State<NerveRoot> createState() => _NerveRootState();
}

class _NerveRootState extends State<NerveRoot> {
  // Populated synchronously (when no mic needed) or asynchronously.
  NerveController? _controller;
  bool _owned = false; // whether we should dispose the controller

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _controller!.init();
    } else if (widget.enableMicrophone) {
      _owned = true;
      NerveController.withMicrophone().then((c) {
        c.init();
        if (mounted) setState(() => _controller = c);
      });
    } else {
      _owned = true;
      _controller = NerveController();
      _controller!.init();
    }
  }

  @override
  void dispose() {
    if (_owned) _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    if (ctrl == null) return widget.loadingWidget;
    return NerveProvider(
      controller: ctrl,
      child: widget.child,
    );
  }
}

