import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../model/geolocator.dart';

class GeocodingService {
  static const Map<String, String> _headers = {
    'User-Agent': 'weatheria-app',
  };

  static Future<GeoLocation?> reverseCoding({
    required double latitude,
    required double longitude,
  }) async {
    try {
      http.Response response = await http.get(
        Uri.parse(
          "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude",
        ),
        headers: _headers,
      );
      if (response.statusCode != 200) return null;
      GeoLocation geoLocation = GeoLocation.fromJson(
        json.decode(response.body),
      );
      log(geoLocation.toString());
      return geoLocation;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<GeoLocation?> forwardCoding(String? query) async {
    if (query == null || query.trim().isEmpty) return null;

    try {
      http.Response response = await http.get(
        Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1",
        ),
        headers: _headers,
      );
      if (response.statusCode != 200) return null;

      final decoded = json.decode(response.body) as List<dynamic>;
      if (decoded.isEmpty) return null;

      GeoLocation geoLocation = GeoLocation.fromJson(
        decoded.first as Map<String, dynamic>,
      );
      return geoLocation;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
