import 'dart:convert';
import 'package:http/http.dart' as http;

class MapsService {
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';

  // Search places (autocomplete)
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    final url = '$_nominatimUrl/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&accept-language=es&countrycodes=pe';
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'AppPeydar/1.0 (delivery@peydar.com)'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Reverse geocode: lat/lng -> display name
  static Future<String?> reverseGeocode(double lat, double lng) async {
    final url = '$_nominatimUrl/reverse?lat=$lat&lon=$lng&format=json&accept-language=es';
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'AppPeydar/1.0 (delivery@peydar.com)'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['display_name'] as String?;
    }
    return null;
  }
}
