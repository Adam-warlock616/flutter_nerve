import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/nerve_state.dart';

/// Wraps [connectivity_plus] and emits a [NetworkQuality] whenever connectivity changes.
class NetworkSense {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  StreamController<NetworkQuality>? _controller;

  /// Stream of [NetworkQuality] values.
  Stream<NetworkQuality> get stream {
    _controller ??= StreamController<NetworkQuality>.broadcast(
      onListen: _start,
      onCancel: _stop,
    );
    return _controller!.stream;
  }

  void _start() {
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      _controller?.add(_toQuality(results));
    });
    // Emit initial state
    _connectivity.checkConnectivity().then((results) {
      _controller?.add(_toQuality(results));
    });
  }

  void _stop() {
    _sub?.cancel();
    _sub = null;
  }

  NetworkQuality _toQuality(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkQuality.none;
    }
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      return NetworkQuality.good;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkQuality.fair;
    }
    if (results.contains(ConnectivityResult.bluetooth) ||
        results.contains(ConnectivityResult.vpn)) {
      return NetworkQuality.poor;
    }
    return NetworkQuality.fair;
  }

  /// Release resources.
  void dispose() {
    _stop();
    _controller?.close();
    _controller = null;
  }
}
