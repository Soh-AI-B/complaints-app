import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Future<List<ConnectivityResult>> get connectionType;
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  @override
  Future<List<ConnectivityResult>> get connectionType async {
    return await connectivity.checkConnectivity();
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return connectivity.onConnectivityChanged;
  }

  // Check if connection is stable (not slow)
  Future<bool> isConnectionStable() async {
    final results = await connectivity.checkConnectivity();

    // Check if any of the connections are stable
    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
          return true;
        case ConnectivityResult.ethernet:
          return true;
        case ConnectivityResult.mobile:
          return true; // Assume mobile connection is stable
        case ConnectivityResult.none:
          continue;
        case ConnectivityResult.bluetooth:
          continue; // Usually slower
        case ConnectivityResult.vpn:
          return true; // Assume VPN connection is stable
        case ConnectivityResult.other:
          continue; // Unknown connection type
      }
    }
    return false;
  }

  // Get connection type as string
  Future<String> getConnectionTypeString() async {
    final results = await connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (results.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    } else if (results.contains(ConnectivityResult.other)) {
      return 'Other';
    } else {
      return 'No Connection';
    }
  }

  // Check if connection is metered (mobile data)
  Future<bool> isConnectionMetered() async {
    final results = await connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }
}
