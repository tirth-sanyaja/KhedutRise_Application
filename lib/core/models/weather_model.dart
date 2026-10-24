/// Represents real-time and forecast weather data for a farm location.
class FarmWeather {
  final String locationName;
  final double latitude;
  final double longitude;
  final double temperature; // Celsius
  final int humidity; // %
  final double precipitation; // mm
  final String condition; // e.g. Sunny, Clear, Overcast, Rain
  final bool isLive; // true if fetched from live weather API, false if offline estimate
  final String fetchedAt;
  final String attribution; // Open-Meteo CC-BY 4.0 license attribution

  const FarmWeather({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.condition,
    required this.isLive,
    required this.fetchedAt,
    this.attribution = 'Weather data provided by Open-Meteo.com under CC-BY 4.0 (Free Non-commercial)',
  });

  factory FarmWeather.defaultBaseline({String location = 'Rajkot, Gujarat'}) {
    return FarmWeather(
      locationName: location,
      latitude: 22.3039,
      longitude: 70.8022,
      temperature: 28.5,
      humidity: 58,
      precipitation: 0.0,
      condition: 'Partly Cloudy',
      isLive: false,
      fetchedAt: DateTime.now().toLocal().toString().substring(0, 16),
      attribution: 'Regional Agro-Climatic Baseline (Offline Mode)',
    );
  }
}
