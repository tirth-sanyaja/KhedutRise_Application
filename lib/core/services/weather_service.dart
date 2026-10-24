import 'package:flutter/foundation.dart';
import '../api/weather_api_client.dart';
import '../models/weather_model.dart';
import 'farmer_service.dart';

/// Real weather integration using Open-Meteo free meteorological API.
/// Retrieves live temperature, relative humidity, and precipitation for Indian farm coordinates.
class WeatherService extends ChangeNotifier {
  WeatherService._internal();
  static final WeatherService instance = WeatherService._internal();

  FarmWeather? _currentWeather;
  FarmWeather? get currentWeather => _currentWeather;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // District coordinate mapping for Gujarat / Saurashtra agricultural zones
  static const Map<String, List<double>> _districtCoordinates = {
    'rajkot': [22.3039, 70.8022],
    'sardhar': [22.1408, 70.9631],
    'junagadh': [21.5222, 70.4579],
    'jamnagar': [22.4707, 70.0577],
    'amreli': [21.6032, 71.2221],
    'bhavnagar': [21.7645, 72.1519],
    'morbi': [22.8120, 70.8236],
    'surendranagar': [22.7276, 71.6370],
    'ahmedabad': [23.0225, 72.5714],
    'surat': [21.1702, 72.8311],
    'vadodara': [22.3072, 73.1812],
  };

  /// Fetches live weather for the given district/location or current farmer location
  Future<FarmWeather> fetchWeather({String? districtName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final locationQuery = districtName ??
        FarmerService.instance.currentFarmer?.district ??
        'Rajkot';

    final cleanQuery = locationQuery.toLowerCase().trim();
    final coords = _districtCoordinates[cleanQuery] ?? [22.3039, 70.8022];
    final lat = coords[0];
    final lon = coords[1];

    try {
      final current = await WeatherApiClient().fetchCurrentWeather(
        latitude: lat,
        longitude: lon,
      );

      if (current != null) {
        final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 28.0;
        final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 55;
        final precip = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
        final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
        final condition = _interpretWeatherCode(weatherCode);

        final weather = FarmWeather(
          locationName: locationQuery,
          latitude: lat,
          longitude: lon,
          temperature: temp,
          humidity: humidity,
          precipitation: precip,
          condition: condition,
          isLive: true,
          fetchedAt: DateTime.now().toLocal().toString().substring(0, 16),
        );

        _currentWeather = weather;
        _isLoading = false;
        notifyListeners();
        return weather;
      }

      throw Exception('Weather data format not recognized');
    } catch (e) {
      debugPrint('Live weather fetch failed: $e. Using regional baseline.');
      _errorMessage = 'Live weather unavailable. Showing regional climate baseline.';
      final baseline = FarmWeather.defaultBaseline(location: locationQuery);
      _currentWeather = baseline;
      _isLoading = false;
      notifyListeners();
      return baseline;
    }
  }

  static String _interpretWeatherCode(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1 || code == 2) return 'Mainly Clear / Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain Showers';
    if (code >= 80 && code <= 82) return 'Heavy Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Fair Weather';
  }
}
