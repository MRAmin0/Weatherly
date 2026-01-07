import 'package:connectivity_plus/connectivity_plus.dart';
// تغییر ۱: ایمپورت پکیج جدید (Plus)
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum NetworkStatus { online, offline, vpn }

class NetworkService {
  static Future<bool> hasInternet() async {
    final status = await checkNetworkStatus();
    return status == NetworkStatus.online;
  }

  static Future<NetworkStatus> checkNetworkStatus() async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity.contains(ConnectivityResult.vpn)) {
      return NetworkStatus.vpn;
    }

    if (connectivity.isEmpty ||
        connectivity.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }

    final hasNet = await InternetConnection().hasInternetAccess;
    return hasNet ? NetworkStatus.online : NetworkStatus.offline;
  }
}
