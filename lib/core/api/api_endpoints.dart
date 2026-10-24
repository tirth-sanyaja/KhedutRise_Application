/// Centralized API Endpoints for KhedutRise
class ApiEndpoints {
  const ApiEndpoints._();

  // Open-Meteo Free Weather API (CC-BY 4.0, zero cost, no key needed)
  static const String openMeteoForecast = 'https://api.open-meteo.com/v1/forecast';

  // Google Gemini Developer API (Free Tier: 15 RPM / 1500 RPD)
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String defaultGeminiModel = 'gemini-1.5-flash';

  static String geminiGenerateContent(String model, String apiKey) =>
      '$geminiBaseUrl/$model:generateContent?key=$apiKey';
}
