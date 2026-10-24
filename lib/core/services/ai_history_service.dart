import 'package:flutter/foundation.dart';
import '../models/crop_disease_model.dart';
import 'farmer_service.dart';

/// Message model for AI Farming Assistant chat history
class AiChatMessage {
  final String id;
  final String farmerId;
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final String? language; // 'gu', 'hi', 'en'
  final bool isError;

  const AiChatMessage({
    required this.id,
    required this.farmerId,
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.language,
    this.isError = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'farmerId': farmerId,
        'isUser': isUser,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'language': language,
        'isError': isError,
      };

  factory AiChatMessage.fromMap(Map<String, dynamic> map) => AiChatMessage(
        id: map['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
        farmerId: map['farmerId'] as String? ?? 'guest',
        isUser: map['isUser'] as bool? ?? false,
        text: map['text'] as String? ?? '',
        timestamp: map['timestamp'] != null
            ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        language: map['language'] as String?,
        isError: map['isError'] as bool? ?? false,
      );
}

/// Service managing persistent AI scan history and conversation history,
/// partitioned by authenticated Farmer UID.
class AiHistoryService extends ChangeNotifier {
  AiHistoryService._internal();
  static final AiHistoryService instance = AiHistoryService._internal();

  final List<CropDiseaseResult> _scanHistory = [];
  final List<AiChatMessage> _chatHistory = [];

  String get _currentFarmerId =>
      FarmerService.instance.currentFarmer?.id ?? 'farmer_default';

  /// Retrieve all scan results for the currently authenticated farmer
  List<CropDiseaseResult> getScansForCurrentFarmer() {
    return List.unmodifiable(_scanHistory);
  }

  /// Most recent scan result
  CropDiseaseResult? get latestScan =>
      _scanHistory.isNotEmpty ? _scanHistory.first : null;

  /// Save a new leaf disease diagnosis
  Future<void> saveScanResult(CropDiseaseResult result) async {
    // Insert at front so latest scans appear first
    _scanHistory.removeWhere((item) => item.id == result.id);
    _scanHistory.insert(0, result);
    notifyListeners();
  }

  /// Delete a scan record
  Future<void> deleteScan(String scanId) async {
    _scanHistory.removeWhere((item) => item.id == scanId);
    notifyListeners();
  }

  /// Retrieve chat history for current farmer
  List<AiChatMessage> getChatHistory() {
    return _chatHistory
        .where((msg) => msg.farmerId == _currentFarmerId)
        .toList();
  }

  /// Save a chat message
  Future<void> saveChatMessage(AiChatMessage message) async {
    _chatHistory.add(message);
    notifyListeners();
  }

  /// Clear chat history for current farmer
  Future<void> clearChatHistory() async {
    _chatHistory.removeWhere((msg) => msg.farmerId == _currentFarmerId);
    notifyListeners();
  }
}
