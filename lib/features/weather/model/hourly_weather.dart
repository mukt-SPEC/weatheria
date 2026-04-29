import 'package:flutter/foundation.dart' show immutable;
import 'package:weatheria/features/weather/model/weather.dart';

@immutable
class HourlyWeather {
  final int cnt;
  final List<WeatherEntry> list;

  const HourlyWeather({
    required this.cnt,
    required this.list,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    final forecast = _readMap(json['forecast']);
    final forecastDays = _readList(forecast['forecastday']);

    final entries = forecastDays
        .whereType<Map<String, dynamic>>()
        .expand((day) => _readList(day['hour'])
            .whereType<Map<String, dynamic>>()
            .map(WeatherEntry.fromJson))
        .toList(growable: false);

    return HourlyWeather(
      cnt: entries.length,
      list: entries,
    );
  }
}

@immutable
class WeatherEntry {
  final int timeEpoch;
  final String time;
  final double tempC;
  final double tempF;
  final int isDay;
  final WeatherCondition condition;
  final double windMph;
  final double windKph;
  final int windDegree;
  final String windDir;
  final double pressureMb;
  final double pressureIn;
  final double precipMm;
  final double precipIn;
  final double snowCm;
  final int humidity;
  final int cloud;
  final double feelslikeC;
  final double feelslikeF;
  final double windchillC;
  final double windchillF;
  final double heatindexC;
  final double heatindexF;
  final double dewpointC;
  final double dewpointF;
  final int willItRain;
  final int chanceOfRain;
  final int willItSnow;
  final int chanceOfSnow;
  final double visKm;
  final double visMiles;
  final double gustMph;
  final double gustKph;
  final double uv;
  final double shortRad;
  final double diffRad;
  final double dni;
  final double gti;

  const WeatherEntry({
    required this.timeEpoch,
    required this.time,
    required this.tempC,
    required this.tempF,
    required this.isDay,
    required this.condition,
    required this.windMph,
    required this.windKph,
    required this.windDegree,
    required this.windDir,
    required this.pressureMb,
    required this.pressureIn,
    required this.precipMm,
    required this.precipIn,
    required this.snowCm,
    required this.humidity,
    required this.cloud,
    required this.feelslikeC,
    required this.feelslikeF,
    required this.windchillC,
    required this.windchillF,
    required this.heatindexC,
    required this.heatindexF,
    required this.dewpointC,
    required this.dewpointF,
    required this.willItRain,
    required this.chanceOfRain,
    required this.willItSnow,
    required this.chanceOfSnow,
    required this.visKm,
    required this.visMiles,
    required this.gustMph,
    required this.gustKph,
    required this.uv,
    required this.shortRad,
    required this.diffRad,
    required this.dni,
    required this.gti,
  });

  factory WeatherEntry.fromJson(Map<String, dynamic> json) {
    return WeatherEntry(
      timeEpoch: _asInt(json['time_epoch']),
      time: _asString(json['time']),
      tempC: _asDouble(json['temp_c']),
      tempF: _asDouble(json['temp_f']),
      isDay: _asInt(json['is_day']),
      condition: WeatherCondition.fromJson(_readMap(json['condition'])),
      windMph: _asDouble(json['wind_mph']),
      windKph: _asDouble(json['wind_kph']),
      windDegree: _asInt(json['wind_degree']),
      windDir: _asString(json['wind_dir']),
      pressureMb: _asDouble(json['pressure_mb']),
      pressureIn: _asDouble(json['pressure_in']),
      precipMm: _asDouble(json['precip_mm']),
      precipIn: _asDouble(json['precip_in']),
      snowCm: _asDouble(json['snow_cm']),
      humidity: _asInt(json['humidity']),
      cloud: _asInt(json['cloud']),
      feelslikeC: _asDouble(json['feelslike_c']),
      feelslikeF: _asDouble(json['feelslike_f']),
      windchillC: _asDouble(json['windchill_c']),
      windchillF: _asDouble(json['windchill_f']),
      heatindexC: _asDouble(json['heatindex_c']),
      heatindexF: _asDouble(json['heatindex_f']),
      dewpointC: _asDouble(json['dewpoint_c']),
      dewpointF: _asDouble(json['dewpoint_f']),
      willItRain: _asInt(json['will_it_rain']),
      chanceOfRain: _asInt(json['chance_of_rain']),
      willItSnow: _asInt(json['will_it_snow']),
      chanceOfSnow: _asInt(json['chance_of_snow']),
      visKm: _asDouble(json['vis_km']),
      visMiles: _asDouble(json['vis_miles']),
      gustMph: _asDouble(json['gust_mph']),
      gustKph: _asDouble(json['gust_kph']),
      uv: _asDouble(json['uv']),
      shortRad: _asDouble(json['short_rad']),
      diffRad: _asDouble(json['diff_rad']),
      dni: _asDouble(json['dni']),
      gti: _asDouble(json['gti']),
    );
  }
}

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return const <String, dynamic>{};
}

List<dynamic> _readList(dynamic value) {
  if (value is List) {
    return value;
  }
  return const <dynamic>[];
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

int _asInt(dynamic value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _asString(dynamic value) => value?.toString() ?? '';
