import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:weatheria/features/home/model/geolocator.dart';
import 'package:weatheria/features/home/model/saved_location.dart';
import 'package:weatheria/features/home/provider/geolocation_provider.dart';
import 'package:weatheria/features/home/provider/saved_locations_provider.dart';
import 'package:weatheria/features/weather/model/weather.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('weatheria_test_');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>(savedLocationsBoxName);
    await Hive.openBox<dynamic>(selectedLocationBoxName);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('defaults startup location to Abuja when there is no saved selection', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(selectedLocationProvider), abujaFallbackLocationId);
    expect(container.read(activeLocationProvider).label, 'Abuja, Nigeria');
    expect(container.read(activeLocationProvider).isCurrentLocation, isFalse);
  });

  test('migrates legacy current selection to the Abuja fallback', () async {
    await Hive.box<dynamic>(
      selectedLocationBoxName,
    ).put(selectedLocationIdKey, currentLocationId);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(selectedLocationProvider), abujaFallbackLocationId);

    await Future<void>.delayed(Duration.zero);

    expect(
      Hive.box<dynamic>(selectedLocationBoxName).get(selectedLocationIdKey),
      abujaFallbackLocationId,
    );
  });

  test('manual city selection stays persisted as the startup location', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const weatherLocation = WeatherLocation(
      name: 'Lagos',
      region: 'Lagos',
      country: 'Nigeria',
      lat: 6.5244,
      lon: 3.3792,
      tzId: 'Africa/Lagos',
      localtimeEpoch: 0,
      localtime: '2026-05-03 12:00',
    );

    await container
        .read(savedLocationsProvider.notifier)
        .addFromWeatherLocation(weatherLocation);

    final savedLocationId = SavedLocation.coordinateId(
      weatherLocation.lat,
      weatherLocation.lon,
    );

    await container
        .read(locationSelectionControllerProvider)
        .selectStartupLocation(savedLocationId);

    expect(container.read(selectedLocationProvider), savedLocationId);
    expect(
      container.read(activeLocationSourceProvider),
      ActiveLocationSource.startup,
    );
    expect(container.read(activeLocationProvider).label, 'Lagos, Nigeria');
  });

  test('current location activates only after an explicit successful request', () async {
    final container = ProviderContainer(
      overrides: [
        geolocationProvider.overrideWith(
          (ref) async => GeoLocation(
            city: 'Abuja',
            country: 'Nigeria',
            lat: 9.0765,
            lng: 7.3986,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final success = await container
        .read(locationSelectionControllerProvider)
        .useCurrentLocation();

    expect(success, isTrue);
    expect(
      container.read(activeLocationSourceProvider),
      ActiveLocationSource.currentLocation,
    );
    expect(container.read(activeLocationProvider).isCurrentLocation, isTrue);
    expect(container.read(activeLocationProvider).label, 'Abuja, Nigeria');
    expect(container.read(selectedLocationProvider), abujaFallbackLocationId);
  });

  test('current location failure keeps the previous startup city active', () async {
    final container = ProviderContainer(
      overrides: [
        geolocationProvider.overrideWith(
          (ref) => throw Exception('Location permissions are denied'),
        ),
      ],
    );
    addTearDown(container.dispose);

    const weatherLocation = WeatherLocation(
      name: 'Kano',
      region: 'Kano',
      country: 'Nigeria',
      lat: 12.0022,
      lon: 8.5920,
      tzId: 'Africa/Lagos',
      localtimeEpoch: 0,
      localtime: '2026-05-03 12:00',
    );

    await container
        .read(savedLocationsProvider.notifier)
        .addFromWeatherLocation(weatherLocation);

    final savedLocationId = SavedLocation.coordinateId(
      weatherLocation.lat,
      weatherLocation.lon,
    );

    await container
        .read(locationSelectionControllerProvider)
        .selectStartupLocation(savedLocationId);

    final success = await container
        .read(locationSelectionControllerProvider)
        .useCurrentLocation();

    expect(success, isFalse);
    expect(
      container.read(activeLocationSourceProvider),
      ActiveLocationSource.startup,
    );
    expect(container.read(activeLocationProvider).label, 'Kano, Nigeria');
    expect(container.read(currentLocationSessionProvider).hasError, isTrue);
  });
}
