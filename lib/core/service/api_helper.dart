import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:weatheria/core/generated/env.dart';
import 'package:weatheria/features/weather/model/hourly_weather.dart';
import 'package:weatheria/features/weather/model/weather.dart';

import '../../features/weather/model/weekly_weather.dart';

class ApiHelper {
  static var apiKey = Env.apiKey;
  static const String _baseUrl = 'https://api.weatherapi.com/v1';
  static const Duration _currentWeatherMaxAge = Duration(minutes: 10);
  static const Duration _forecastMaxAge = Duration(minutes: 30);
  static const Duration _searchMaxAge = Duration(minutes: 5);
  static const Duration _weatherMaxStale = Duration(hours: 24);
  static const Duration _searchMaxStale = Duration(hours: 12);
  static final DioCacheManager _cacheManager = DioCacheManager(
    CacheConfig(
      baseUrl: _baseUrl,
      defaultMaxAge: const Duration(days: 7),
      defaultMaxStale: const Duration(days: 14),
      defaultRequestMethod: 'GET',
    ),
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

  static final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  )..interceptors.add(_cacheManager.interceptor);

  static Future<Map<String, dynamic>> _fetchData(
    String url, {
    Options? options,
  }) async {
    try {
      final response = await dio.get(url, options: options);
      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return data;
      }

      throw Exception('Invalid API response format');
    } on DioException catch (e) {
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
      options: _buildCurrentWeatherCacheOptions(),
    );
    return Weather.fromJson(response);
  }

  static Future<Weather> getWeatherByCity(String cityName) async {
    final url = _constructCurrentWeatherUrlByCity(cityName);
    final response = await _fetchData(
      url,
      options: _buildSearchWeatherCacheOptions(),
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
      options: _buildForecastCacheOptions(),
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
      options: _buildForecastCacheOptions(),
    );
    return WeeklyWeather.fromJson(response);
  }

  static Options _buildCurrentWeatherCacheOptions() {
    return buildCacheOptions(
      _currentWeatherMaxAge,
      maxStale: _weatherMaxStale,
    );
  }

  static Options _buildForecastCacheOptions() {
    return buildCacheOptions(
      _forecastMaxAge,
      maxStale: _weatherMaxStale,
    );
  }

  static Options _buildSearchWeatherCacheOptions() {
    return buildCacheOptions(
      _searchMaxAge,
      maxStale: _searchMaxStale,
    );
  }
}
