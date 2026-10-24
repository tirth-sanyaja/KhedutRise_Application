import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

/// Lightweight HTTP client for Open-Meteo meteorological endpoints.
class WeatherApiClient {
  final http.Client _client;

  WeatherApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Retrieve current weather parameters for given latitude and longitude
  Future<Map<String, dynamic>?> fetchCurrentWeather({
    required double latitude,
    required double longitude,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final uri = Uri.parse(
      '${ApiEndpoints.openMeteoForecast}?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,precipitation,weather_code&timezone=auto',
    );

    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['current'] as Map<String, dynamic>?;
      }
    } catch (_) {
      // Return null on network or timeout issues
    }
    return null;
  }
}
