import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weatheria/features/home/model/geolocator.dart';
import 'package:weatheria/features/home/service/geocoding.dart';
import 'package:weatheria/core/service/location.dart' as geolocator_service;

final geolocationProvider = FutureProvider.autoDispose<GeoLocation>((ref) async {
  final position = await geolocator_service.determinePosition();

  try {
    final geoLocation = await GeocodingService.reverseCoding(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (geoLocation != null) {
      return geoLocation;
    }
  } catch (_) {}

  return GeoLocation(lat: position.latitude, lng: position.longitude);
});
