import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatheria/features/home/model/geolocator.dart';
import 'package:weatheria/features/home/service/geocoding.dart';
import 'package:weatheria/core/service/location.dart' as geolocator_service;

final geolocationProvider = StreamProvider.autoDispose<GeoLocation>((ref) {
  Stream<Position> positions() async* {
    final initialPosition = await geolocator_service.determinePosition();
    yield initialPosition;
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(distanceFilter: 50),
    );
  }

  return positions().asyncMap((position) async {
    final geoLocation = await GeocodingService.reverseCoding(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (geoLocation == null) {
      throw Exception('Unable to fetch location');
    }

    return geoLocation;
  });
});
