import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Central configuration for KhedutRise AI services.
/// Supports Gemini API key via:
/// 1. Persistent SharedPreferences storage (entered by farmer in UI)
/// 2. Compile-time environment: `--dart-define=GEMINI_API_KEY=your_key`
class AiConfig extends ChangeNotifier {
  AiConfig._internal();
  static final AiConfig instance = AiConfig._internal();

  /// Default model name for agriculture multimodal vision & chat
  static const String defaultModel = 'gemini-1.5-flash';

  /// Gemini Developer API Free Tier Quota Limits (Strict ₹0 Cost)
  static const int freeTierMaxRpm = 15; // 15 Requests Per Minute
  static const int freeTierMaxRpd = 1500; // 1,500 Requests Per Day
  static const bool isBillingAccountRequired = false; // No credit card or billing account needed

  static const String _storageKeyCustomApiKey = 'khedutrise_gemini_custom_api_key';

  /// Compile-time define key
  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Runtime custom key override (set by user in settings or directly in AI screen)
  String _customApiKey = '';
  SharedPreferences? _prefs;

  /// Active model name
  String _activeModel = defaultModel;

  String get activeModel => _activeModel;
  set activeModel(String model) {
    if (_activeModel != model) {
      _activeModel = model;
      notifyListeners();
    }
  }

  /// Initialize and load saved API key from persistent storage
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final saved = _prefs?.getString(_storageKeyCustomApiKey);
      if (saved != null && saved.trim().isNotEmpty) {
        _customApiKey = saved.trim();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AiConfig.init warning: $e');
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

  /// Set or update the runtime API key and persist to disk
  void setApiKey(String key) {
    _customApiKey = key.trim();
    if (_customApiKey.isNotEmpty) {
      _prefs?.setString(_storageKeyCustomApiKey, _customApiKey);
      SharedPreferences.getInstance().then((p) {
        _prefs = p;
        p.setString(_storageKeyCustomApiKey, _customApiKey);
      }).catchError((_) {});
    } else {
      _prefs?.remove(_storageKeyCustomApiKey);
      SharedPreferences.getInstance().then((p) {
        _prefs = p;
        p.remove(_storageKeyCustomApiKey);
      }).catchError((_) {});
    }
    notifyListeners();
  }

  /// Clear the custom API key and remove from disk
  void clearApiKey() {
    _customApiKey = '';
    _prefs?.remove(_storageKeyCustomApiKey);
    SharedPreferences.getInstance().then((p) {
      _prefs = p;
      p.remove(_storageKeyCustomApiKey);
    }).catchError((_) {});
    notifyListeners();
  }

  /// Base URL for Gemini v1beta REST API
  String get geminiBaseUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_activeModel:generateContent?key=$apiKey';

  /// Test connection to the Gemini API with current or candidate key
  Future<bool> testConnection([String? testKey]) async {
    final keyToTest = (testKey != null && testKey.trim().isNotEmpty) ? testKey.trim() : apiKey;
    if (keyToTest.isEmpty) return false;
    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_activeModel:generateContent?key=$keyToTest',
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
