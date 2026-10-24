import 'package:flutter/foundation.dart';
import '../config/ai_config.dart';
import '../models/crop_disease_model.dart';
import '../models/crop_recommendation_model.dart';
import 'ai_chat_service.dart';
import 'crop_disease_service.dart';
import 'crop_recommendation_service.dart';
import 'firestore_service.dart';

/// Central Unified AI Service for KhedutRise operating strictly under the ₹0 Free Tier budget.
///
/// Features:
/// 1. Direct integration with Google Gemini Developer API (Free Tier: 15 RPM, 1,500 RPD).
/// 2. Rate-limiting guard: Tracks RPM and RPD in-memory to prevent spamming and handle 429 errors gracefully.
/// 3. Strict Rule 10 Compliance: Explicitly differentiates real AI responses from offline demonstration data.
/// 4. In-Memory Image Processing: Bypasses paid Cloud Storage by encoding images directly from memory.
/// 5. Automatic Firestore Persistence: Saves scans, recommendations, and chat logs into Firestore collections.
class AiService extends ChangeNotifier {
  AiService._internal();
  static final AiService instance = AiService._internal();

  // Gemini Free Tier Quota Limits
  static const int maxRequestsPerMinute = 15;
  static const int maxRequestsPerDay = 1500;

  // Rate-limiting sliding window tracking
  final List<DateTime> _recentRequestTimestamps = [];
  int _requestsToday = 0;
  DateTime _dayResetDate = DateTime.now();

  int get requestsToday => _requestsToday;
  int get requestsThisMinute => _countRequestsLastMinute();

  bool _isRateLimited = false;
  bool get isRateLimited => _isRateLimited;

  String? _rateLimitMessage;
  String? get rateLimitMessage => _rateLimitMessage;

  int _countRequestsLastMinute() {
    final now = DateTime.now();
    _recentRequestTimestamps.removeWhere(
      (ts) => now.difference(ts).inSeconds > 60,
    );
    return _recentRequestTimestamps.length;
  }

  /// Verifies whether the request can proceed within the free tier quota
  bool _canProceedWithRequest() {
    final now = DateTime.now().toUtc();
    if (now.day != _dayResetDate.toUtc().day) {
      _requestsToday = 0;
      _dayResetDate = now;
    }

    final inMinute = _countRequestsLastMinute();
    if (inMinute >= maxRequestsPerMinute) {
      _isRateLimited = true;
      _rateLimitMessage =
          'Gemini Free Tier rate limit reached ($maxRequestsPerMinute requests/min). Please wait 30 seconds. Zero billing is activated.';
      notifyListeners();
      return false;
    }

    if (_requestsToday >= maxRequestsPerDay) {
      _isRateLimited = true;
      _rateLimitMessage =
          'Daily free AI quota reached ($maxRequestsPerDay requests/day). Resets at 00:00 UTC with strictly ₹0 cost.';
      notifyListeners();
      return false;
    }

    _isRateLimited = false;
    _rateLimitMessage = null;
    return true;
  }

  void _recordSuccessfulRequest() {
    final now = DateTime.now();
    _recentRequestTimestamps.add(now);
    _requestsToday++;
    notifyListeners();
  }

  // ==========================================
  // A. CROP DISEASE DETECTION
  // ==========================================
  Future<CropDiseaseResult> detectCropDisease({
    String? filePath,
    String? assetPath,
    Uint8List? imageBytes,
  }) async {
    if (AiConfig.instance.isConfigured && !_canProceedWithRequest()) {
      return CropDiseaseResult(
        id: 'rate_limited_${DateTime.now().millisecondsSinceEpoch}',
        cropName: 'Diagnosis Paused (Free Tier Quota)',
        diseaseName: 'Rate Limit (15 RPM / 1,500 RPD)',
        confidence: 'Rate Limited',
        isClearImage: false,
        clarityFeedback: _rateLimitMessage ?? 'Please wait a moment before analyzing another photo.',
        symptoms: ['Free tier rate limit reached'],
        immediateSteps: 'Wait 30-60 seconds for free quota window to refresh.',
        preventionGuidance: 'Gemini Developer API Free Tier provides 15 requests per minute at ₹0 cost.',
        organicTreatment: 'N/A',
        chemicalTreatment: 'N/A',
        expertConsultation: 'Contact KVK helpline 1800-180-1551 for urgent assistance.',
        scannedAt: DateTime.now(),
        imagePath: filePath ?? assetPath,
      );
    }

    final result = await CropDiseaseService.instance.analyzeImage(
      filePath: filePath,
      assetPath: assetPath,
      imageBytes: imageBytes,
    );

    if (AiConfig.instance.isConfigured) {
      _recordSuccessfulRequest();
    }

    // Save scan result to Firestore within Spark Plan free quota
    await FirestoreService.instance.saveDiseaseScan(result.toMap());

    return result;
  }

  // ==========================================
  // B. CROP RECOMMENDATION
  // ==========================================
  Future<CropRecommendationResult> recommendCrops({
    required CropRecommendationInput input,
  }) async {
    if (AiConfig.instance.isConfigured && !_canProceedWithRequest()) {
      throw Exception(_rateLimitMessage ?? 'AI Free tier rate limit reached.');
    }

    final result = await CropRecommendationService.instance.recommendCrops(
      input: input,
    );

    if (AiConfig.instance.isConfigured) {
      _recordSuccessfulRequest();
    }

    // Save recommendation to Firestore within Spark Plan free quota
    await FirestoreService.instance.saveCropRecommendation({
      'id': result.id,
      'input': input.toMap(),
      'isMeasuredSoil': result.isMeasuredSoil,
      'soilMeasurementStatus': result.soilMeasurementStatus,
      'recommendations': result.recommendations.map((r) => r.toMap()).toList(),
      'advisoryNotice': result.advisoryNotice,
      'createdAt': result.createdAt.toIso8601String(),
    });

    return result;
  }

  // ==========================================
  // C. AI FARMING CHATBOT
  // ==========================================
  Future<String> sendChatMessage(String message) async {
    if (AiConfig.instance.isConfigured && !_canProceedWithRequest()) {
      final rateMsg = _rateLimitMessage ??
          'Free tier rate limit (15 requests/minute). Please wait 30 seconds before sending another question.';
      return rateMsg;
    }

    final response = await AiChatService.instance.sendMessage(message);

    if (AiConfig.instance.isConfigured) {
      _recordSuccessfulRequest();
    }

    // Save chat message to Firestore within Spark Plan free quota
    await FirestoreService.instance.saveChatMessage({
      'id': 'chat_${DateTime.now().millisecondsSinceEpoch}',
      'userPrompt': message,
      'aiResponse': response,
      'language': AiChatService.instance.currentLanguage,
      'isRealAi': AiConfig.instance.isConfigured,
    });

    return response;
  }

  /// Reset tracking counters for unit tests
  void resetRateLimitsForTesting() {
    _recentRequestTimestamps.clear();
    _requestsToday = 0;
    _isRateLimited = false;
    _rateLimitMessage = null;
    notifyListeners();
  }

  /// Simulates a request for rate-limit unit testing
  void simulateRequestForTesting() {
    _recordSuccessfulRequest();
  }
}
