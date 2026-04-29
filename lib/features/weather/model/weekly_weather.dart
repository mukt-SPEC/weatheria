import 'package:flutter/foundation.dart' show immutable;
import 'package:weatheria/features/weather/model/hourly_weather.dart';
import 'package:weatheria/features/weather/model/weather.dart';

@immutable
class WeeklyWeather {
  final WeatherLocation? location;
  final List<ForecastDay> forecastDays;

  const WeeklyWeather({
    required this.location,
    required this.forecastDays,
  });

  factory WeeklyWeather.fromJson(Map<String, dynamic> json) {
    final locationJson = _readMap(json['location']);
    final forecast = _readMap(json['forecast']);

    final days = _readList(forecast['forecastday'])
        .whereType<Map<String, dynamic>>()
        .map(ForecastDay.fromJson)
        .toList(growable: false);

    return WeeklyWeather(
      location: locationJson.isEmpty ? null : WeatherLocation.fromJson(locationJson),
      forecastDays: days,
    );
  }
}

@immutable
class ForecastDay {
  final String date;
  final int dateEpoch;
  final DayWeather day;
  final Astro astro;
  final List<WeatherEntry> hour;

  const ForecastDay({
    required this.date,
    required this.dateEpoch,
    required this.day,
    required this.astro,
    required this.hour,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) => ForecastDay(
        date: _asString(json['date']),
        dateEpoch: _asInt(json['date_epoch']),
        day: DayWeather.fromJson(_readMap(json['day'])),
        astro: Astro.fromJson(_readMap(json['astro'])),
        hour: _readList(json['hour'])
            .whereType<Map<String, dynamic>>()
            .map(WeatherEntry.fromJson)
            .toList(growable: false),
      );
}

@immutable
class DayWeather {
  final double maxtempC;
  final double maxtempF;
  final double mintempC;
  final double mintempF;
  final double avgtempC;
  final double avgtempF;
  final double maxwindMph;
  final double maxwindKph;
  final double totalprecipMm;
  final double totalprecipIn;
  final double totalsnowCm;
  final double avgvisKm;
  final double avgvisMiles;
  final int avghumidity;
  final int dailyWillItRain;
  final int dailyChanceOfRain;
  final int dailyWillItSnow;
  final int dailyChanceOfSnow;
  final WeatherCondition condition;
  final double uv;

  const DayWeather({
    required this.maxtempC,
    required this.maxtempF,
    required this.mintempC,
    required this.mintempF,
    required this.avgtempC,
    required this.avgtempF,
    required this.maxwindMph,
    required this.maxwindKph,
    required this.totalprecipMm,
    required this.totalprecipIn,
    required this.totalsnowCm,
    required this.avgvisKm,
    required this.avgvisMiles,
    required this.avghumidity,
    required this.dailyWillItRain,
    required this.dailyChanceOfRain,
    required this.dailyWillItSnow,
    required this.dailyChanceOfSnow,
    required this.condition,
    required this.uv,
  });

  factory DayWeather.fromJson(Map<String, dynamic> json) => DayWeather(
        maxtempC: _asDouble(json['maxtemp_c']),
        maxtempF: _asDouble(json['maxtemp_f']),
        mintempC: _asDouble(json['mintemp_c']),
        mintempF: _asDouble(json['mintemp_f']),
        avgtempC: _asDouble(json['avgtemp_c']),
        avgtempF: _asDouble(json['avgtemp_f']),
        maxwindMph: _asDouble(json['maxwind_mph']),
        maxwindKph: _asDouble(json['maxwind_kph']),
        totalprecipMm: _asDouble(json['totalprecip_mm']),
        totalprecipIn: _asDouble(json['totalprecip_in']),
        totalsnowCm: _asDouble(json['totalsnow_cm']),
        avgvisKm: _asDouble(json['avgvis_km']),
        avgvisMiles: _asDouble(json['avgvis_miles']),
        avghumidity: _asInt(json['avghumidity']),
        dailyWillItRain: _asInt(json['daily_will_it_rain']),
        dailyChanceOfRain: _asInt(json['daily_chance_of_rain']),
        dailyWillItSnow: _asInt(json['daily_will_it_snow']),
        dailyChanceOfSnow: _asInt(json['daily_chance_of_snow']),
        condition: WeatherCondition.fromJson(_readMap(json['condition'])),
        uv: _asDouble(json['uv']),
      );
}

@immutable
class Astro {
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final String moonPhase;
  final String moonIllumination;
  final int isMoonUp;
  final int isSunUp;

  const Astro({
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.moonIllumination,
    required this.isMoonUp,
    required this.isSunUp,
  });

  factory Astro.fromJson(Map<String, dynamic> json) => Astro(
        sunrise: _asString(json['sunrise']),
        sunset: _asString(json['sunset']),
        moonrise: _asString(json['moonrise']),
        moonset: _asString(json['moonset']),
        moonPhase: _asString(json['moon_phase']),
        moonIllumination: _asString(json['moon_illumination']),
        isMoonUp: _asInt(json['is_moon_up']),
        isSunUp: _asInt(json['is_sun_up']),
      );
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
