import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weatheria/features/home/model/geolocator.dart';
import 'package:weatheria/features/home/model/saved_location.dart';
import 'package:weatheria/features/home/provider/geolocation_provider.dart';
import 'package:weatheria/features/weather/model/weather.dart';

const savedLocationsBoxName = 'saved_locations_box';
const selectedLocationBoxName = 'selected_location_box';
const savedLocationsKey = 'saved_locations';
const selectedLocationIdKey = 'selected_location_id';
const currentLocationId = 'current';
const abujaFallbackLocationId = 'abuja_nigeria_fallback';

const abujaFallbackLocation = SavedLocation(
  id: abujaFallbackLocationId,
  label: 'Abuja, Nigeria',
  lat: 9.0765,
  lon: 7.3986,
);

final savedLocationsProvider =
    NotifierProvider<SavedLocationsNotifier, List<SavedLocation>>(
      SavedLocationsNotifier.new,
    );

class SavedLocationsNotifier extends Notifier<List<SavedLocation>> {
  @override
  List<SavedLocation> build() {
    final box = Hive.box<dynamic>(savedLocationsBoxName);
    final raw = box.get(savedLocationsKey, defaultValue: const <dynamic>[]);

    if (raw is! List) {
      return const [];
    }

    return raw
        .whereType<Map>()
        .map(
          (item) => SavedLocation.fromMap(
            item.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<bool> addFromWeatherLocation(WeatherLocation weatherLocation) async {
    final candidate = SavedLocation.fromWeatherLocation(weatherLocation);
    final exists = state.any((location) => location.id == candidate.id);
    if (exists) {
      return false;
    }

    state = [...state, candidate];
    await _persist();
    return true;
  }

  Future<void> deleteById(String id) async {
    if (id == currentLocationId || id == abujaFallbackLocationId) {
      return;
    }

    final next = state.where((location) => location.id != id).toList();
    state = next;
    await _persist();

    final selectedId = ref.read(selectedLocationProvider);
    if (selectedId == id) {
      await ref
          .read(selectedLocationProvider.notifier)
          .select(abujaFallbackLocationId);
    }
  }

  Future<void> _persist() async {
    final box = Hive.box<dynamic>(savedLocationsBoxName);
    await box.put(
      savedLocationsKey,
      state.map((location) => location.toMap()).toList(growable: false),
    );
  }
}

final selectedLocationProvider =
    NotifierProvider<SelectedLocationNotifier, String>(
      SelectedLocationNotifier.new,
    );

class SelectedLocationNotifier extends Notifier<String> {
  @override
  String build() {
    final box = Hive.box<dynamic>(selectedLocationBoxName);
    final storedId = box.get(selectedLocationIdKey)?.toString();
    final normalizedId = _normalizeStartupLocationId(storedId);

    if (storedId != normalizedId) {
      unawaited(box.put(selectedLocationIdKey, normalizedId));
    }

    return normalizedId;
  }

  Future<void> select(String locationId) async {
    final normalizedId = _normalizeStartupLocationId(locationId);
    state = normalizedId;
    final box = Hive.box<dynamic>(selectedLocationBoxName);
    await box.put(selectedLocationIdKey, normalizedId);
  }
}

enum ActiveLocationSource { startup, currentLocation }

class ActiveLocationSourceNotifier extends Notifier<ActiveLocationSource> {
  @override
  ActiveLocationSource build() {
    return ActiveLocationSource.startup;
  }

  void useStartupLocation() {
    state = ActiveLocationSource.startup;
  }

  void useCurrentLocation() {
    state = ActiveLocationSource.currentLocation;
  }
}

final activeLocationSourceProvider =
    NotifierProvider<ActiveLocationSourceNotifier, ActiveLocationSource>(
      ActiveLocationSourceNotifier.new,
    );

final currentLocationSessionProvider =
    StateProvider<AsyncValue<ActiveLocation?>>((ref) {
      return const AsyncData(null);
    });

final locationSelectionControllerProvider =
    Provider<LocationSelectionController>((ref) {
      return LocationSelectionController(ref);
    });

class LocationSelectionController {
  const LocationSelectionController(this._ref);

  final Ref _ref;

  Future<void> selectStartupLocation(String locationId) async {
    await _ref.read(selectedLocationProvider.notifier).select(locationId);
    _ref.read(activeLocationSourceProvider.notifier).useStartupLocation();
    _clearCurrentLocationError();
  }

  Future<bool> useCurrentLocation() async {
    final session = _ref.read(currentLocationSessionProvider.notifier);
    session.state = const AsyncLoading();

    try {
      final currentGeo = await _ref.read(geolocationProvider.future);
      final activeLocation = _activeFromCurrentGeo(currentGeo);
      session.state = AsyncData(activeLocation);
      _ref.read(activeLocationSourceProvider.notifier).useCurrentLocation();
      return true;
    } catch (error, stackTrace) {
      session.state = AsyncError(error, stackTrace);
      _ref.read(activeLocationSourceProvider.notifier).useStartupLocation();
      return false;
    }
  }

  void clearCurrentLocationFeedback() {
    _clearCurrentLocationError();
  }

  void _clearCurrentLocationError() {
    final session = _ref.read(currentLocationSessionProvider);
    if (session.hasError) {
      _ref.read(currentLocationSessionProvider.notifier).state =
          const AsyncData(null);
    }
  }
}

final startupLocationProvider = Provider<ActiveLocation>((ref) {
  final selectedId = ref.watch(selectedLocationProvider);
  if (selectedId == abujaFallbackLocationId) {
    return _activeFromSavedLocation(abujaFallbackLocation);
  }

  final savedLocations = ref.watch(savedLocationsProvider);
  for (final location in savedLocations) {
    if (location.id == selectedId) {
      return _activeFromSavedLocation(location);
    }
  }

  return _activeFromSavedLocation(abujaFallbackLocation);
});

final activeLocationProvider = Provider<ActiveLocation>((ref) {
  final source = ref.watch(activeLocationSourceProvider);
  final startupLocation = ref.watch(startupLocationProvider);

  if (source == ActiveLocationSource.currentLocation) {
    final currentLocationSession = ref.watch(currentLocationSessionProvider);
    return currentLocationSession.when(
      data: (location) => location ?? startupLocation,
      loading: () => startupLocation,
      error: (_, _) => startupLocation,
    );
  }

  return startupLocation;
});

ActiveLocation _activeFromCurrentGeo(GeoLocation geoLocation) {
  final currentLabel = _normalizeLocationLabel(geoLocation.displayName);

  return ActiveLocation(
    id: currentLocationId,
    label: currentLabel.isEmpty ? 'Current location' : currentLabel,
    lat: geoLocation.lat ?? 0,
    lon: geoLocation.lng ?? 0,
    isCurrentLocation: true,
  );
}

ActiveLocation _activeFromSavedLocation(SavedLocation location) {
  return ActiveLocation(
    id: location.id,
    label: _normalizeLocationLabel(location.label),
    lat: location.lat,
    lon: location.lon,
    isCurrentLocation: false,
  );
}

String _normalizeStartupLocationId(String? value) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty || normalized == currentLocationId) {
    return abujaFallbackLocationId;
  }
  return normalized;
}

String _normalizeLocationLabel(String label) {
  final normalized = label.trim();
  if (normalized.isEmpty) {
    return '';
  }

  final parts = normalized
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return '';
  }

  final cityPart = _cleanCityPart(parts.first);
  final countryPart = parts.last;

  if (cityPart.isNotEmpty && countryPart.isNotEmpty) {
    return '$cityPart, $countryPart';
  }
  if (countryPart.isNotEmpty) {
    return countryPart;
  }
  return cityPart;
}

String _cleanCityPart(String value) {
  const cityOfPrefix = 'city of ';
  final trimmed = value.trim();
  if (trimmed.toLowerCase().startsWith(cityOfPrefix)) {
    return trimmed.substring(cityOfPrefix.length).trim();
  }
  return trimmed;
}
