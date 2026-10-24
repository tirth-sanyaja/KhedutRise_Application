import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Central configuration for KhedutRise AI services.
/// Supports Gemini API key via:
/// 1. Compile-time environment: `--dart-define=GEMINI_API_KEY=your_key`
/// 2. Runtime user configuration in App Settings.
class AiConfig extends ChangeNotifier {
  AiConfig._internal();
  static final AiConfig instance = AiConfig._internal();

  /// Default model name for agriculture multimodal vision & chat
  static const String defaultModel = 'gemini-1.5-flash';

  /// Compile-time define key
  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Runtime custom key override (set by user in settings)
  String _customApiKey = '';

  /// Active model name
  String _activeModel = defaultModel;

  String get activeModel => _activeModel;
  set activeModel(String model) {
    if (_activeModel != model) {
      _activeModel = model;
      notifyListeners();
    }
  }

  /// Get active API key (runtime override takes precedence over compile-time define)
  String get apiKey {
    if (_customApiKey.isNotEmpty) return _customApiKey;
    return _envApiKey;
  }

  /// Whether an API key is currently configured
  bool get isConfigured => apiKey.trim().isNotEmpty;

  /// Custom key is set at runtime
  bool get hasCustomKey => _customApiKey.isNotEmpty;

  /// Set or update the runtime API key
  void setApiKey(String key) {
    _customApiKey = key.trim();
    notifyListeners();
  }

  /// Clear the custom API key
  void clearApiKey() {
    _customApiKey = '';
    notifyListeners();
  }

  /// Base URL for Gemini v1beta REST API
  String get geminiBaseUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_activeModel:generateContent?key=$apiKey';

  /// Test connection to the Gemini API with current key
  Future<bool> testConnection() async {
    if (!isConfigured) return false;
    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_activeModel:generateContent?key=$apiKey',
      );
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body:
                '{"contents":[{"parts":[{"text":"Reply with OK if you receive this agricultural test message."}]}]}',
          )
          .timeout(const Duration(seconds: 12));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
