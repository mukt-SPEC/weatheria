class GeoLocation {
  String? city, county, state, country;
  double? lat, lng;

  GeoLocation({
    this.city,
    this.county,
    this.state,
    this.country,
    this.lat,
    this.lng,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    final address = (json['address'] as Map<String, dynamic>?) ?? const {};

    return GeoLocation(
      city:
          address['city'] ??
          address['town'] ??
          address['village'] ??
          address['county'] ??
          address['state'],
      county: address['county'] ?? address['city'] ?? address['state'],
      state: address['state']?.toString(),
      country: address['country']?.toString(),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lon']),
    );
  }

  String get displayName {
    final cityName = city?.trim() ?? '';
    final countryName = country?.trim() ?? '';

    if (cityName.isEmpty && countryName.isEmpty) {
      return '';
    }
    if (cityName.isEmpty) {
      return countryName;
    }
    if (countryName.isEmpty) {
      return cityName;
    }
    return '$cityName, $countryName';
  }

  @override
  String toString() {
    return """
  City: '$city\n
  Country: '$country\n
  County: '$county\n
  State: '$state\n
  Latlong: '$lat + $lng\n
""";
  }
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
