import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weatheria/core/core_barrel.dart';
import 'package:flutter/services.dart';
import 'package:weatheria/core/service/api_helper.dart';
import 'package:weatheria/core/utils/connectivity/connectivity_listener.dart';
import 'package:weatheria/core/widget/banner.dart';
import 'package:weatheria/features/home/provider/saved_locations_provider.dart';
import 'package:weatheria/features/home/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only set system UI overlay style on mobile platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  try {
    await Hive.initFlutter();
  } catch (error, stackTrace) {
    debugPrint('Hive initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  await _openHiveBoxSafely(savedLocationsBoxName);
  await _openHiveBoxSafely(selectedLocationBoxName);
  
  await ApiHelper.init();

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _openHiveBoxSafely(String boxName) async {
  try {
    if (Hive.isBoxOpen(boxName)) {
      return;
    }
    await Hive.openBox<dynamic>(boxName);
  } catch (error, stackTrace) {
    debugPrint('Hive box "$boxName" failed to open: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weatheria',
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        splashFactory: InkSparkle.splashFactory,
        highlightColor: Colors.transparent,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        splashFactory: InkSparkle.splashFactory,
        highlightColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      builder: (context, child) {
        return Scaffold(
          body: Column(
            children: [
              ConnectionBanner(isVisible: isOffline),
              Expanded(child: child!),
            ],
          ),
        );
      },
    );
  }
}
