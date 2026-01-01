import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  ConnectivityResult _connectionType = ConnectivityResult.none;

  bool get isConnected => _isConnected;
  ConnectivityResult get connectionType => _connectionType;

  bool get isWifi => _connectionType == ConnectivityResult.wifi;
  bool get isMobile => _connectionType == ConnectivityResult.mobile;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _connectionType = result;
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return _isConnected;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
