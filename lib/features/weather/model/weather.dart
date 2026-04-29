import 'package:flutter/foundation.dart' show immutable;

@immutable
class Weather {
  final WeatherLocation location;
  final WeatherCurrent current;

  const Weather({
    required this.location,
    required this.current,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        location: WeatherLocation.fromJson(_readMap(json['location'])),
        current: WeatherCurrent.fromJson(_readMap(json['current'])),
      );
}

@immutable
class WeatherLocation {
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;
  final String tzId;
  final int localtimeEpoch;
  final String localtime;

  const WeatherLocation({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    required this.tzId,
    required this.localtimeEpoch,
    required this.localtime,
  });

  factory WeatherLocation.fromJson(Map<String, dynamic> json) => WeatherLocation(
        name: _asString(json['name']),
        region: _asString(json['region']),
        country: _asString(json['country']),
        lat: _asDouble(json['lat']),
        lon: _asDouble(json['lon']),
        tzId: _asString(json['tz_id']),
        localtimeEpoch: _asInt(json['localtime_epoch']),
        localtime: _asString(json['localtime']),
      );
}

@immutable
class WeatherCurrent {
  final int lastUpdatedEpoch;
  final String lastUpdated;
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
  final double visKm;
  final double visMiles;
  final double uv;
  final double gustMph;
  final double gustKph;

  const WeatherCurrent({
    required this.lastUpdatedEpoch,
    required this.lastUpdated,
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
    required this.visKm,
    required this.visMiles,
    required this.uv,
    required this.gustMph,
    required this.gustKph,
  });

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) => WeatherCurrent(
        lastUpdatedEpoch: _asInt(json['last_updated_epoch']),
        lastUpdated: _asString(json['last_updated']),
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
        visKm: _asDouble(json['vis_km']),
        visMiles: _asDouble(json['vis_miles']),
        uv: _asDouble(json['uv']),
        gustMph: _asDouble(json['gust_mph']),
        gustKph: _asDouble(json['gust_kph']),
      );
}

@immutable
class WeatherCondition {
  final String text;
  final String icon;
  final int code;

  const WeatherCondition({
    required this.text,
    required this.icon,
    required this.code,
  });

  factory WeatherCondition.fromJson(Map<String, dynamic> json) => WeatherCondition(
        text: _asString(json['text']),
        icon: _asString(json['icon']),
        code: _asInt(json['code']),
      );

  String get iconUrl => icon.startsWith('//') ? 'https:$icon' : icon;
}

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return const <String, dynamic>{};
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
