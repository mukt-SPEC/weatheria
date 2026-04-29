import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weatheria/core/core_barrel.dart';
import 'package:flutter/services.dart';
import 'package:weatheria/core/utils/connectivity/connectivity_listener.dart';
import 'package:weatheria/core/widget/banner.dart';
import 'package:weatheria/features/home/provider/saved_locations_provider.dart';
import 'package:weatheria/features/home/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(savedLocationsBoxName);
  await Hive.openBox<dynamic>(selectedLocationBoxName);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home:,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: HomeScreen(),
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
