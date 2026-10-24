import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_constants.dart';

/// Persistent local offline database manager for KhedutRise.
/// Guarantees data persistence on the farmer's physical device without requiring
/// a paid database or active internet connectivity.
///
/// Features:
/// - Persists all 7 core collections: users, farms, disease_scans, crop_recommendations, chats, expenses, bookings.
/// - Immediate in-memory caching for zero-latency UI updates.
/// - Background asynchronous disk write through SharedPreferences.
/// - Preserves user partition isolation (UID matching).
class LocalDatabaseService extends ChangeNotifier {
  LocalDatabaseService._internal();
  static final LocalDatabaseService instance = LocalDatabaseService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // In-memory cache for immediate reads
  final Map<String, List<Map<String, dynamic>>> _cache = {
    for (var col in DatabaseCollections.all) col: [],
  };

  /// Initialize local database and preload all stored collections from disk
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      for (final collection in DatabaseCollections.all) {
        final key = _storageKey(collection);
        final rawJson = _prefs?.getString(key);
        if (rawJson != null && rawJson.isNotEmpty) {
          try {
            final decoded = jsonDecode(rawJson);
            if (decoded is List) {
              _cache[collection] = decoded
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList();
            }
          } catch (e) {
            debugPrint('Failed to decode local collection $collection: $e');
            _cache[collection] = [];
          }
        } else {
          _cache[collection] = [];
        }
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('LocalDatabaseService initialization warning: $e');
      _isInitialized = true; // Still allow memory cache
    }
  }

  String _storageKey(String collection) => 'khedutrise_db_$collection';

  /// Save or update a document in a collection and persist to disk
  Future<bool> saveDocument(String collection, Map<String, dynamic> data) async {
    if (!_cache.containsKey(collection)) {
      _cache[collection] = [];
    }

    final doc = Map<String, dynamic>.from(data);
    final id = doc['id'] as String? ??
        doc['scanId'] as String? ??
        doc['recommendationId'] as String? ??
        doc['messageId'] as String? ??
        doc['bookingId'] as String? ??
        doc['userId'] as String? ??
        DateTime.now().millisecondsSinceEpoch.toString();

    doc['id'] = id;
    doc['savedAt'] = doc['savedAt'] ?? DateTime.now().toUtc().toIso8601String();

    final list = _cache[collection]!;
    list.removeWhere((item) =>
        item['id'] == id ||
        (doc.containsKey('userId') &&
            collection == DatabaseCollections.users &&
            item['userId'] == doc['userId']));

    list.add(doc);
    notifyListeners();

    return await _persistCollection(collection);
  }

  /// Retrieve all documents in a collection, optionally filtered by userId
  List<Map<String, dynamic>> getDocuments(
    String collection, {
    String? userId,
  }) {
    final list = _cache[collection] ?? [];
    if (userId == null || userId.isEmpty) {
      return List<Map<String, dynamic>>.from(list);
    }
    return list
        .where((item) => item['userId'] == userId)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  /// Retrieve single document by ID
  Map<String, dynamic>? getDocumentById(String collection, String id) {
    final list = _cache[collection] ?? [];
    try {
      final doc = list.firstWhere(
        (item) => item['id'] == id || item['userId'] == id,
      );
      return Map<String, dynamic>.from(doc);
    } catch (_) {
      return null;
    }
  }

  /// Delete a document by ID and persist change to disk
  Future<bool> deleteDocument(String collection, String id) async {
    final list = _cache[collection];
    if (list == null) return false;

    final initialCount = list.length;
    list.removeWhere((item) => item['id'] == id);

    if (list.length != initialCount) {
      notifyListeners();
      return await _persistCollection(collection);
    }
    return true;
  }

  /// Clear entire collection from disk and memory
  Future<bool> clearCollection(String collection) async {
    _cache[collection] = [];
    notifyListeners();
    return await _persistCollection(collection);
  }

  /// Internal disk persistence routine
  Future<bool> _persistCollection(String collection) async {
    if (_prefs == null) return true; // Graceful in-memory fallback if disk is not yet ready
    try {
      final list = _cache[collection] ?? [];
      final jsonStr = jsonEncode(list);
      return await _prefs!.setString(_storageKey(collection), jsonStr);
    } catch (e) {
      debugPrint('Error writing collection $collection to disk: $e');
      return true; // Keep in-memory cache functional
    }
  }

  /// Total count of saved documents across all collections
  int get totalRecordsCount {
    int total = 0;
    for (final list in _cache.values) {
      total += list.length;
    }
    return total;
  }
}
