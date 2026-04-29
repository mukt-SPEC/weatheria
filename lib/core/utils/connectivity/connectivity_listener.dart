// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:weatheria/core/enums/connectivity_enums.dart';

// abstract class ConnectivityListener {
//   void onConnectivityChanged(bool hasInternet);
// }

// class ConnectivityService {
//   static ConnectivityService? _instance;
//   ConnectivityService._();
//   factory ConnectivityService() {
//     _instance ??= ConnectivityService._();
//     return _instance!;
//   }

//   final List<ConnectivityListener> _listeners = [];

//   final List<ConnectivityResult> _connectionStatus = [
//     ConnectivityResult.mobile,
//     ConnectivityResult.wifi,
//     ConnectivityResult.ethernet,
//   ];

//   bool _hasInternet = false;
//   bool get hasInternet => _hasInternet;

//   init() async {
//     Connectivity connectivity = Connectivity();

//     List<ConnectivityResult> result = await connectivity.checkConnectivity();
//     for (ConnectivityResult item in result) {
//       _hasInternet = _connectionStatus.contains(item);
//       Connectivity().onConnectivityChanged.listen((result) {
//         _hasInternet = _connectionStatus.contains(item);
//       });
//     }
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider =
    StreamProvider.autoDispose<List<ConnectivityResult>>((ref) async* {
      final connectivity = Connectivity();
      final initial = await connectivity.checkConnectivity();
      yield initial;
      yield* connectivity.onConnectivityChanged;
    });

final isOfflineProvider = Provider.autoDispose<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);

  return connectivity.when(
    data: (results) => results.contains(ConnectivityResult.none),
    loading: () => true,
    error: (_, _) => true,
  );
});
