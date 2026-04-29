import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatheria/features/home/model/geolocator.dart';
import 'package:weatheria/features/home/service/geocoding.dart';
import 'package:weatheria/core/service/location.dart' as geolocator_service;


final geolocationProvider = StreamProvider<GeoLocation>((ref) {
 
  Stream<Position> positions() async* {
  
    final initialPosition = await geolocator_service.determinePosition();
    yield initialPosition;

  
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(distanceFilter: 50),
    );
  }

  return positions().asyncMap((position) async {
   
    try {
      final geoLocation = await GeocodingService.reverseCoding(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (geoLocation != null) {
        return geoLocation;
      }
    } catch (_) {
      
    }

  
    return GeoLocation(lat: position.latitude, lng: position.longitude);
  });
});
