import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

/// Lightweight HTTP client for Google Gemini Developer API.
/// Operates strictly within the free tier rate limits (15 RPM / 1500 RPD).
class GeminiApiClient {
  final http.Client _client;

  GeminiApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Send prompt and optional inline base64 image data to Gemini
  Future<String?> generateContent({
    required String apiKey,
    required String prompt,
    String? model,
    String? base64Image,
    String mimeType = 'image/jpeg',
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final selectedModel = model ?? ApiEndpoints.defaultGeminiModel;
    final url = ApiEndpoints.geminiGenerateContent(selectedModel, apiKey);

    final parts = <Map<String, dynamic>>[];

    // Add multimodal inline image if supplied
    if (base64Image != null && base64Image.isNotEmpty) {
      parts.add({
        'inline_data': {
          'mime_type': mimeType,
          'data': base64Image,
        }
      });
    }

    // Add text prompt
    parts.add({'text': prompt});

    final body = jsonEncode({
      'contents': [
        {'parts': parts}
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 1024,
      }
    });

    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final partsList = content?['parts'] as List?;
          if (partsList != null && partsList.isNotEmpty) {
            return partsList[0]['text'] as String?;
          }
        }
      }
    } catch (_) {
      // Handle network errors gracefully
    }
    return null;
  }
}
