import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:weatheria/core/generated/env.dart';
import 'package:weatheria/features/weather/model/hourly_weather.dart';
import 'package:weatheria/features/weather/model/weather.dart';

import '../../features/weather/model/weekly_weather.dart';
import 'package:path_provider/path_provider.dart';

class ApiHelper {
  static var apiKey = Env.apiKey;
  static const String _baseUrl = 'https://api.weatherapi.com/v1';
  static const Duration _weatherMaxStale = Duration(hours: 24);
  static const Duration _searchMaxStale = Duration(hours: 12);
  static CacheStore? _cacheStoreInstance;
  static CacheStore get _cacheStore {
    return _cacheStoreInstance ??= MemCacheStore();
  }

  static Future<void> init() async {
    _cacheStoreInstance = MemCacheStore();
  }

  static CacheOptions get _cacheOptions => CacheOptions(
    store: _cacheStore,
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(days: 7),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );

  static String _constructCurrentWeatherUrlByCoords({
    required double lat,
    required double lon,
  }) =>
      '$_baseUrl/current.json?key=$apiKey&q=$lat,$lon&aqi=no';
  static String _constructCurrentWeatherUrlByCity(String cityName) =>
      '$_baseUrl/current.json?key=$apiKey&q=$cityName&aqi=no';
  static String _constructWeeklyWeatherUrl({
    required double lat,
    required double lon,
  }) =>
      '$_baseUrl/forecast.json?key=$apiKey&q=$lat,$lon&days=5&aqi=no&alerts=no';

  static Dio? _dioInstance;
  static Dio get dio => _dioInstance ??= Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  )..interceptors.add(DioCacheInterceptor(options: _cacheOptions));

  static Future<Map<String, dynamic>> _fetchData(
    String url, {
    Options? options,
  }) async {
    try {
      debugPrint('--- API CALL START ---');
      debugPrint('URL: $url');
      final response = await dio.get(url, options: options);
      debugPrint('STATUS CODE: ${response.statusCode}');
      
      final data = response.data;
      if ((response.statusCode == 200 || response.statusCode == 304) && 
          data is Map<String, dynamic>) {
        debugPrint('--- API CALL SUCCESS ---');
        return data;
      }

      debugPrint('--- API CALL INVALID FORMAT ---');
      throw Exception('Invalid API response format');
    } on DioException catch (e) {
      debugPrint('--- API CALL DIO ERROR ---');
      debugPrint('ERROR: ${e.message}');
      debugPrint('RESPONSE DATA: ${e.response?.data}');
      
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      String message = 'Error fetching data';

      if (responseData is Map<String, dynamic>) {
        final errorNode = responseData['error'];
        if (errorNode is Map<String, dynamic>) {
          final apiMessage = errorNode['message'];
          if (apiMessage != null) {
            message = apiMessage.toString();
          }
        }
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }

      throw Exception(
        statusCode != null ? '[$statusCode] $message' : message,
      );
    } catch (e) {
      debugPrint('--- API CALL GENERAL ERROR ---');
      debugPrint('ERROR: $e');
      throw Exception(e.toString());
    }
  }

  static Future<Weather> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    final url = _constructCurrentWeatherUrlByCoords(lat: lat, lon: lon);
    final response = await _fetchData(
      url,
      options: _buildCacheOptions(_weatherMaxStale),
    );
    return Weather.fromJson(response);
  }

  static Future<Weather> getWeatherByCity(String cityName) async {
    final url = _constructCurrentWeatherUrlByCity(cityName);
    final response = await _fetchData(
      url,
      options: _buildCacheOptions(_searchMaxStale),
    );
    return Weather.fromJson(response);
  }

  static Future<HourlyWeather> getHourlyWeather({
    required double lat,
    required double lon,
  }) async {
    final url = _constructWeeklyWeatherUrl(lat: lat, lon: lon);
    final response = await _fetchData(
      url,
      options: _buildCacheOptions(_weatherMaxStale),
    );
    return HourlyWeather.fromJson(response);
  }

  static Future<WeeklyWeather> getWeeklyWeather({
    required double lat,
    required double lon,
  }) async {
    final url = _constructWeeklyWeatherUrl(lat: lat, lon: lon);
    final response = await _fetchData(
      url,
      options: _buildCacheOptions(_weatherMaxStale),
    );
    return WeeklyWeather.fromJson(response);
  }

  static Options _buildCacheOptions(Duration maxStale) {
    return _cacheOptions
        .copyWith(maxStale: Nullable(maxStale))
        .toOptions();
  }

}
