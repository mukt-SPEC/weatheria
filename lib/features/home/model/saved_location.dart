import 'package:weatheria/features/weather/model/weather.dart';

class SavedLocation {
  const SavedLocation({
    required this.id,
    required this.label,
    required this.lat,
    required this.lon,
  });

  final String id;
  final String label;
  final double lat;
  final double lon;

  factory SavedLocation.fromWeatherLocation(WeatherLocation weatherLocation) {
    final label = _buildLabel(
      state: weatherLocation.region,
      country: weatherLocation.country,
      fallbackCity: weatherLocation.name,
    );

    return SavedLocation(
      id: _coordinateId(weatherLocation.lat, weatherLocation.lon),
      label: label,
      lat: weatherLocation.lat,
      lon: weatherLocation.lon,
    );
  }

  factory SavedLocation.fromMap(Map<String, dynamic> map) {
    final rawLabel = map['label']?.toString() ?? '';

    return SavedLocation(
      id: map['id']?.toString() ?? '',
      label: _sanitizeLocationLabel(rawLabel),
      lat: _toDouble(map['lat']),
      lon: _toDouble(map['lon']),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'label': label, 'lat': lat, 'lon': lon};
  }

  static String coordinateId(double lat, double lon) {
    return _coordinateId(lat, lon);
  }
}

class ActiveLocation {
  const ActiveLocation({
    required this.id,
    required this.label,
    required this.lat,
    required this.lon,
    required this.isCurrentLocation,
  });

  final String id;
  final String label;
  final double lat;
  final double lon;
  final bool isCurrentLocation;
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _coordinateId(double lat, double lon) {
  return '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
}

String _buildLabel({
  required String state,
  required String country,
  required String fallbackCity,
}) {
  final stateText = state.trim();
  final countryText = country.trim();
  final fallbackCityText = fallbackCity.trim();

  if (stateText.isNotEmpty && countryText.isNotEmpty) {
    return '$stateText, $countryText';
  }
  if (countryText.isNotEmpty) {
    return countryText;
  }
  if (stateText.isNotEmpty) {
    return stateText;
  }
  return fallbackCityText;
}

String _sanitizeLocationLabel(String rawLabel) {
  final normalized = rawLabel.trim();
  if (normalized.isEmpty) {
    return normalized;
  }

  final parts = normalized
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return normalized;
  }

  final cityPart = _cleanCityPrefix(parts.first);
  final countryPart = parts.last;

  if (cityPart.isNotEmpty && countryPart.isNotEmpty) {
    return '$cityPart, $countryPart';
  }
  if (countryPart.isNotEmpty) {
    return countryPart;
  }
  return cityPart;
}

String _cleanCityPrefix(String value) {
  const cityOfPrefix = 'city of ';
  final lowercase = value.toLowerCase();
  if (lowercase.startsWith(cityOfPrefix)) {
    return value.substring(cityOfPrefix.length).trim();
  }
  return value.trim();
}
