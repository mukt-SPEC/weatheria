// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weatheria/features/home/provider/saved_locations_provider.dart';
import 'package:weatheria/features/weather/model/hourly_weather.dart';
import 'package:weatheria/features/weather/model/weather.dart';

import '../../../features/weather/model/weekly_weather.dart';
import '../../service/api_helper.dart';

final currentWeatherProvider = FutureProvider.autoDispose<Weather>((ref) async {
  final activeLocation = await ref.watch(activeLocationProvider.future);
  final weather = await ApiHelper.getCurrentWeather(
    lat: activeLocation.lat,
    lon: activeLocation.lon,
  );
  ref.cacheFor(const Duration(minutes: 10));
  return weather;
});

final hourlyWeatherProvider = FutureProvider.autoDispose<HourlyWeather>((
  ref,
) async {
  final activeLocation = await ref.watch(activeLocationProvider.future);
  final weather = await ApiHelper.getHourlyWeather(
    lat: activeLocation.lat,
    lon: activeLocation.lon,
  );
  ref.cacheFor(const Duration(minutes: 30));
  return weather;
});

final weeklyWeatherProvider = FutureProvider.autoDispose<WeeklyWeather>((
  ref,
) async {
  final activeLocation = await ref.watch(activeLocationProvider.future);
  final weather = await ApiHelper.getWeeklyWeather(
    lat: activeLocation.lat,
    lon: activeLocation.lon,
  );
  ref.cacheFor(const Duration(minutes: 30));
  return weather;
});

final searchWeatherProvider = FutureProvider.autoDispose.family<Weather, String>((
  ref,
  String cityName,
) async {
  final weather = await ApiHelper.getWeatherByCity(cityName);
  ref.cacheFor(const Duration(minutes: 5));
  return weather;
});

extension RefCacheFor on AutoDisposeRef<Object?> {
  void cacheFor(Duration duration) {
    final link = keepAlive();
    final timer = Timer(duration, link.close);
    onDispose(timer.cancel);
  }
}
