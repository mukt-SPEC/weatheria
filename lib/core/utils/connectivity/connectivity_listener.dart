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
    loading: () => false,
    error: (_, _) => false,
  );
});
