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
    if (id == currentLocationId) {
      return;
    }

    final next = state.where((location) => location.id != id).toList();
    state = next;
    await _persist();

    final selectedId = ref.read(selectedLocationProvider);
    if (selectedId == id) {
      await ref.read(selectedLocationProvider.notifier).select(currentLocationId);
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
    return box.get(selectedLocationIdKey, defaultValue: currentLocationId)
            ?.toString() ??
        currentLocationId;
  }

  Future<void> select(String locationId) async {
    state = locationId;
    final box = Hive.box<dynamic>(selectedLocationBoxName);
    await box.put(selectedLocationIdKey, locationId);
  }
}

final activeLocationProvider = FutureProvider.autoDispose<ActiveLocation>((ref) async {
  final selectedId = ref.watch(selectedLocationProvider);

  if (selectedId == currentLocationId) {
    final currentGeo = await ref.watch(geolocationProvider.future);
    return _activeFromCurrentGeo(currentGeo);
  }

  final savedLocations = ref.watch(savedLocationsProvider);
  SavedLocation? selectedLocation;
  for (final location in savedLocations) {
    if (location.id == selectedId) {
      selectedLocation = location;
      break;
    }
  }

  if (selectedLocation != null) {
    return ActiveLocation(
      id: selectedLocation.id,
      label: _normalizeLocationLabel(selectedLocation.label),
      lat: selectedLocation.lat,
      lon: selectedLocation.lon,
      isCurrentLocation: false,
    );
  }

  await ref.read(selectedLocationProvider.notifier).select(currentLocationId);
  final currentGeo = await ref.watch(geolocationProvider.future);
  return _activeFromCurrentGeo(currentGeo);
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
