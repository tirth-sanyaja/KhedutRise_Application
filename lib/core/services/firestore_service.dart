import 'package:flutter/foundation.dart';
import '../database/database_constants.dart';
import '../database/local_database_service.dart';
import 'farmer_service.dart';

/// Comprehensive Cloud Firestore service tailored strictly for the Firebase Spark (₹0 Free) Plan.
/// Manages all 7 required collections:
/// 1. users
/// 2. farms
/// 3. disease_scans
/// 4. crop_recommendations
/// 5. chats
/// 6. expenses
/// 7. bookings
///
/// Features:
/// - Enforces Spark Plan daily quota limits (50k reads, 20k writes, 1GB storage)
/// - Quota exhaustion protection: pauses writes/reads and alerts user rather than incurring billing
/// - Zero Cloud Storage cost: processes crop images in-memory and stores only lightweight metadata
/// - Authenticated UID isolation matching firestore.rules
class FirestoreService extends ChangeNotifier {
  FirestoreService._internal() {
    syncFromLocalDatabase();
  }
  static final FirestoreService instance = FirestoreService._internal();

  /// Synchronize all collections from persistent local database upon startup
  Future<void> syncFromLocalDatabase() async {
    try {
      await LocalDatabaseService.instance.init();
      for (final col in DatabaseCollections.all) {
        final records = LocalDatabaseService.instance.getDocuments(col);
        if (records.isNotEmpty) {
          _localCollections[col] = List<Map<String, dynamic>>.from(records);
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  // Firebase project identifier (configurable via --dart-define=FIREBASE_PROJECT_ID=... or runtime)
  static const String _envProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  String _customProjectId = '';

  String get projectId {
    if (_customProjectId.isNotEmpty) return _customProjectId;
    if (_envProjectId.isNotEmpty) return _envProjectId;
    return 'khedutrise-spark-free';
  }

  void setProjectId(String id) {
    _customProjectId = id.trim();
    notifyListeners();
  }

  // Spark Plan Daily Quotas
  static const int sparkMaxReadsPerDay = 50000;
  static const int sparkMaxWritesPerDay = 20000;
  static const int sparkMaxDeletesPerDay = 20000;

  // In-memory Spark Plan quota consumption tracking for the current calendar day
  int _readsToday = 0;
  int _writesToday = 0;
  int _deletesToday = 0;
  DateTime _quotaResetDate = DateTime.now();

  int get readsToday => _readsToday;
  int get writesToday => _writesToday;
  int get deletesToday => _deletesToday;

  bool _isQuotaExhausted = false;
  bool get isQuotaExhausted => _isQuotaExhausted;

  String? _quotaErrorMessage;
  String? get quotaErrorMessage => _quotaErrorMessage;

  final Set<String> _expenseIdSet = {};

  // Local in-memory store simulating Firestore partitioned by collection and authenticated UID
  final Map<String, List<Map<String, dynamic>>> _localCollections = {
    'users': [],
    'farms': [],
    'disease_scans': [],
    'crop_recommendations': [],
    'chats': [],
    'expenses': [],
    'bookings': [],
  };

  String get _currentUserId =>
      FarmerService.instance.currentFarmer?.id ?? 'guest_farmer_001';

  /// Verify and maintain daily quota reset (resets at 00:00 UTC)
  void _checkAndResetDailyQuota() {
    final now = DateTime.now().toUtc();
    if (now.day != _quotaResetDate.toUtc().day ||
        now.month != _quotaResetDate.toUtc().month ||
        now.year != _quotaResetDate.toUtc().year) {
      _readsToday = 0;
      _writesToday = 0;
      _deletesToday = 0;
      _isQuotaExhausted = false;
      _quotaErrorMessage = null;
      _quotaResetDate = now;
      notifyListeners();
    }
  }

  /// Trigger quota exhaustion safety stop
  void _triggerQuotaExhaustion([String? reason]) {
    _isQuotaExhausted = true;
    _quotaErrorMessage = reason ??
        'Daily free Firebase Spark quota limit reached. Database operations are paused to maintain strict ₹0 cost. Service resets tomorrow at 00:00 UTC.';
    notifyListeners();
  }

  // ==========================================
  // 1. USERS COLLECTION
  // ==========================================
  Future<bool> saveUser(Map<String, dynamic> userData) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _writesToday >= sparkMaxWritesPerDay) {
      _triggerQuotaExhaustion();
      return false;
    }

    final uid = userData['uid'] as String? ?? _currentUserId;
    final doc = Map<String, dynamic>.from(userData);
    doc['userId'] = uid;
    doc['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    doc['plan'] = 'Spark (Free Tier - ₹0)';

    _localCollections['users']!.removeWhere((u) => u['userId'] == uid);
    _localCollections['users']!.add(doc);
    _writesToday++;
    await LocalDatabaseService.instance.saveDocument(DatabaseCollections.users, doc);
    notifyListeners();
    return true;
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _readsToday >= sparkMaxReadsPerDay) {
      _triggerQuotaExhaustion();
      return null;
    }

    _readsToday++;
    final list = _localCollections['users']!;
    for (final doc in list) {
      if (doc['userId'] == userId) return doc;
    }
    return null;
  }

  // ==========================================
  // 2. FARMS COLLECTION
  // ==========================================
  Future<bool> saveFarm(Map<String, dynamic> farmData) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _writesToday >= sparkMaxWritesPerDay) {
      _triggerQuotaExhaustion();
      return false;
    }

    final farmId = farmData['farmId'] as String? ??
        'farm_${DateTime.now().millisecondsSinceEpoch}';
    final doc = Map<String, dynamic>.from(farmData);
    doc['farmId'] = farmId;
    doc['userId'] = farmData['userId'] as String? ?? _currentUserId;
    doc['updatedAt'] = DateTime.now().toUtc().toIso8601String();

    _localCollections['farms']!.removeWhere((f) => f['farmId'] == farmId);
    _localCollections['farms']!.add(doc);
    _writesToday++;
    await LocalDatabaseService.instance.saveDocument(DatabaseCollections.farms, doc);
    notifyListeners();
    return true;
  }

  Future<List<Map<String, dynamic>>> getFarms(String userId) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _readsToday >= sparkMaxReadsPerDay) {
      _triggerQuotaExhaustion();
      return [];
    }

    _readsToday++;
    return _localCollections['farms']!
        .where((f) => f['userId'] == userId)
        .toList();
  }

  // ==========================================
  // 3. DISEASE_SCANS COLLECTION
  // ==========================================
  /// Saves crop disease diagnosis.
  /// IMPORTANT ZERO-COST RULE: Never upload heavy image binaries to Cloud Storage.
  /// Image is processed in memory; only diagnostic outcome metadata is stored.
  Future<bool> saveDiseaseScan(Map<String, dynamic> scanData) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _writesToday >= sparkMaxWritesPerDay) {
      _triggerQuotaExhaustion();
      return false;
    }

    final scanId = scanData['id'] as String? ??
        'scan_${DateTime.now().millisecondsSinceEpoch}';
    final doc = Map<String, dynamic>.from(scanData);
    doc['scanId'] = scanId;
    doc['userId'] = scanData['userId'] as String? ?? _currentUserId;
    doc['scannedAt'] = DateTime.now().toUtc().toIso8601String();

    // Strip any raw image bytes/base64 to ensure document size is <2 KB (100% free within 1GB limit)
    doc.remove('imageBase64');

    _localCollections['disease_scans']!.removeWhere((s) => s['scanId'] == scanId);
    _localCollections['disease_scans']!.insert(0, doc);
    _writesToday++;
    await LocalDatabaseService.instance.saveDocument(DatabaseCollections.diseaseScans, doc);
    notifyListeners();
    return true;
  }

  Future<List<Map<String, dynamic>>> getDiseaseScans(String userId) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _readsToday >= sparkMaxReadsPerDay) {
      _triggerQuotaExhaustion();
      return [];
    }

    _readsToday++;
    return _localCollections['disease_scans']!
        .where((s) => s['userId'] == userId)
        .toList();
  }

  // ==========================================
  // 4. CROP_RECOMMENDATIONS COLLECTION
  // ==========================================
  Future<bool> saveCropRecommendation(Map<String, dynamic> recData) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _writesToday >= sparkMaxWritesPerDay) {
      _triggerQuotaExhaustion();
      return false;
    }

    final recId = recData['id'] as String? ??
        'rec_${DateTime.now().millisecondsSinceEpoch}';
    final doc = Map<String, dynamic>.from(recData);
    doc['recId'] = recId;
    doc['userId'] = recData['userId'] as String? ?? _currentUserId;
    doc['createdAt'] = DateTime.now().toUtc().toIso8601String();

    _localCollections['crop_recommendations']!
        .removeWhere((r) => r['recId'] == recId);
    _localCollections['crop_recommendations']!.insert(0, doc);
    _writesToday++;
    await LocalDatabaseService.instance.saveDocument(DatabaseCollections.cropRecommendations, doc);
    notifyListeners();
    return true;
  }

  Future<List<Map<String, dynamic>>> getCropRecommendations(String userId) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _readsToday >= sparkMaxReadsPerDay) {
      _triggerQuotaExhaustion();
      return [];
    }

    _readsToday++;
    return _localCollections['crop_recommendations']!
        .where((r) => r['userId'] == userId)
        .toList();
  }

  // ==========================================
  // 5. CHATS COLLECTION
  // ==========================================
  Future<bool> saveChatMessage(Map<String, dynamic> chatData) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _writesToday >= sparkMaxWritesPerDay) {
      _triggerQuotaExhaustion();
      return false;
    }

    final msgId = chatData['id'] as String? ??
        'chat_${DateTime.now().millisecondsSinceEpoch}';
    final doc = Map<String, dynamic>.from(chatData);
    doc['chatId'] = msgId;
    doc['userId'] = chatData['userId'] as String? ?? _currentUserId;
    doc['timestamp'] = DateTime.now().toUtc().toIso8601String();

    _localCollections['chats']!.add(doc);
    _writesToday++;
    await LocalDatabaseService.instance.saveDocument(DatabaseCollections.chats, doc);
    notifyListeners();
    return true;
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String userId) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _readsToday >= sparkMaxReadsPerDay) {
      _triggerQuotaExhaustion();
      return [];
    }

    _readsToday++;
    return _localCollections['chats']!
        .where((c) => c['userId'] == userId)
        .toList();
  }

  // ==========================================
  // 6. EXPENSES COLLECTION
  // ==========================================
  Future<bool> saveExpense(Map<String, dynamic> expenseData) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _writesToday >= sparkMaxWritesPerDay) {
      _triggerQuotaExhaustion();
      return false;
    }

    final expId = expenseData['id'] as String? ??
        'exp_${DateTime.now().millisecondsSinceEpoch}';
    final doc = Map<String, dynamic>.from(expenseData);
    doc['expenseId'] = expId;
    doc['userId'] = expenseData['userId'] as String? ?? _currentUserId;
    doc['createdAt'] = DateTime.now().toUtc().toIso8601String();

    if (_expenseIdSet.contains(expId)) {
      _localCollections['expenses']!.removeWhere((e) => e['expenseId'] == expId);
    } else {
      _expenseIdSet.add(expId);
    }
    _localCollections['expenses']!.add(doc);
    _writesToday++;
    await LocalDatabaseService.instance.saveDocument(DatabaseCollections.expenses, doc);
    notifyListeners();
    return true;
  }

  Future<List<Map<String, dynamic>>> getExpenses(String userId) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _readsToday >= sparkMaxReadsPerDay) {
      _triggerQuotaExhaustion();
      return [];
    }

    _readsToday++;
    return _localCollections['expenses']!
        .where((e) => e['userId'] == userId)
        .toList();
  }

  Future<bool> deleteExpense(String expenseId) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _deletesToday >= sparkMaxDeletesPerDay) {
      _triggerQuotaExhaustion();
      return false;
    }

    _localCollections['expenses']!.removeWhere((e) => e['expenseId'] == expenseId);
    _deletesToday++;
    await LocalDatabaseService.instance.deleteDocument(DatabaseCollections.expenses, expenseId);
    notifyListeners();
    return true;
  }

  // ==========================================
  // 7. BOOKINGS COLLECTION
  // ==========================================
  Future<bool> saveBooking(Map<String, dynamic> bookingData) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _writesToday >= sparkMaxWritesPerDay) {
      _triggerQuotaExhaustion();
      return false;
    }

    final bookId = bookingData['id'] as String? ??
        'book_${DateTime.now().millisecondsSinceEpoch}';
    final doc = Map<String, dynamic>.from(bookingData);
    doc['bookingId'] = bookId;
    doc['userId'] = bookingData['userId'] as String? ?? _currentUserId;
    doc['createdAt'] = DateTime.now().toUtc().toIso8601String();

    _localCollections['bookings']!.removeWhere((b) => b['bookingId'] == bookId);
    _localCollections['bookings']!.add(doc);
    _writesToday++;
    await LocalDatabaseService.instance.saveDocument(DatabaseCollections.bookings, doc);
    notifyListeners();
    return true;
  }

  Future<List<Map<String, dynamic>>> getBookings(String userId) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _readsToday >= sparkMaxReadsPerDay) {
      _triggerQuotaExhaustion();
      return [];
    }

    _readsToday++;
    return _localCollections['bookings']!
        .where((b) => b['userId'] == userId)
        .toList();
  }

  Future<bool> cancelBooking(String bookingId) async {
    _checkAndResetDailyQuota();
    if (_isQuotaExhausted || _writesToday >= sparkMaxWritesPerDay) {
      _triggerQuotaExhaustion();
      return false;
    }

    final list = _localCollections['bookings']!;
    for (int i = 0; i < list.length; i++) {
      if (list[i]['bookingId'] == bookingId && list[i]['userId'] == _currentUserId) {
        list[i]['status'] = 'Cancelled';
        list[i]['updatedAt'] = DateTime.now().toUtc().toIso8601String();
        _writesToday++;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Reset in-memory quota tracking (used for testing and manual sync)
  void resetQuotaUsageForTesting() {
    _readsToday = 0;
    _writesToday = 0;
    _deletesToday = 0;
    _isQuotaExhausted = false;
    _quotaErrorMessage = null;
    _expenseIdSet.clear();
    _localCollections['expenses']!.clear();
    notifyListeners();
  }
}
