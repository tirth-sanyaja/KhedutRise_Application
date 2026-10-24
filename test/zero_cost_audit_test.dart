import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:khedutrise/core/config/ai_config.dart';
import 'package:khedutrise/core/models/crop_recommendation_model.dart';
import 'package:khedutrise/core/services/ai_service.dart';
import 'package:khedutrise/core/services/firestore_service.dart';
import 'package:khedutrise/core/services/weather_service.dart';

void main() {
  group('Step 2: Firestore Spark Plan & Zero-Cost Database Tests', () {
    setUp(() {
      FirestoreService.instance.resetQuotaUsageForTesting();
    });

    test('All 7 collections can store and retrieve documents partitioned by UID', () async {
      final fs = FirestoreService.instance;
      const testUid = 'farmer_test_123';

      // 1. users
      final userSaved = await fs.saveUser({
        'uid': testUid,
        'name': 'Rameshbhai Patel',
        'email': 'ramesh@khedutrise.in',
      });
      expect(userSaved, isTrue);
      final userDoc = await fs.getUser(testUid);
      expect(userDoc?['name'], equals('Rameshbhai Patel'));
      expect(userDoc?['plan'], contains('Spark'));

      // 2. farms
      final farmSaved = await fs.saveFarm({
        'farmId': 'farm_01',
        'userId': testUid,
        'soilType': 'Black Soil',
        'landAcres': '7.5 Acres',
      });
      expect(farmSaved, isTrue);
      final farms = await fs.getFarms(testUid);
      expect(farms.any((f) => f['farmId'] == 'farm_01'), isTrue);

      // 3. disease_scans (verifying raw binary is stripped to avoid Cloud Storage cost)
      final scanSaved = await fs.saveDiseaseScan({
        'id': 'scan_01',
        'userId': testUid,
        'cropName': 'Cotton',
        'diseaseName': 'Leaf Blight',
        'imageBase64': 'large_base64_binary_string_here',
      });
      expect(scanSaved, isTrue);
      final scans = await fs.getDiseaseScans(testUid);
      expect(scans.first['cropName'], equals('Cotton'));
      expect(scans.first.containsKey('imageBase64'), isFalse); // Stripped for zero cost!

      // 4. crop_recommendations
      final recSaved = await fs.saveCropRecommendation({
        'id': 'rec_01',
        'userId': testUid,
        'soilType': 'Black Soil',
        'season': 'Kharif',
      });
      expect(recSaved, isTrue);
      final recs = await fs.getCropRecommendations(testUid);
      expect(recs.isNotEmpty, isTrue);

      // 5. chats
      final chatSaved = await fs.saveChatMessage({
        'id': 'chat_01',
        'userId': testUid,
        'text': 'How to control whitefly in cotton?',
      });
      expect(chatSaved, isTrue);
      final chats = await fs.getChatMessages(testUid);
      expect(chats.isNotEmpty, isTrue);

      // 6. expenses
      final expSaved = await fs.saveExpense({
        'id': 'exp_01',
        'userId': testUid,
        'title': 'DAP Fertilizer',
        'amount': 1350,
      });
      expect(expSaved, isTrue);
      final expenses = await fs.getExpenses(testUid);
      expect(expenses.any((e) => e['expenseId'] == 'exp_01'), isTrue);

      // 7. bookings
      final bookSaved = await fs.saveBooking({
        'id': 'book_01',
        'userId': testUid,
        'machineryName': 'Mahindra 575 DI',
        'totalCost': 1800,
      });
      expect(bookSaved, isTrue);
      final bookings = await fs.getBookings(testUid);
      expect(bookings.any((b) => b['bookingId'] == 'book_01'), isTrue);
    });

    test('Quota exhaustion triggers safety pause when Spark daily limits are exceeded', () async {
      final fs = FirestoreService.instance;

      // Simulate reaching Spark limit
      for (int i = 0; i < 20005; i++) {
        final success = await fs.saveExpense({
          'id': 'stress_exp_$i',
          'amount': 100,
        });
        if (!success) {
          // Safety triggered
          break;
        }
      }

      expect(fs.isQuotaExhausted, isTrue);
      expect(fs.quotaErrorMessage, contains('Firebase Spark quota'));

      // Additional write must fail to prevent any billing
      final preventedWrite = await fs.saveFarm({'plot': 'overflow_plot'});
      expect(preventedWrite, isFalse);
    });
  });

  group('Step 3: Real AI with Zero-Cost Configuration Tests', () {
    setUp(() {
      AiService.instance.resetRateLimitsForTesting();
    });

    test('AiConfig enforces developer free-tier constants (15 RPM / 1500 RPD)', () {
      expect(AiConfig.freeTierMaxRpm, equals(15));
      expect(AiConfig.freeTierMaxRpd, equals(1500));
      expect(AiConfig.isBillingAccountRequired, isFalse);
      expect(AiConfig.defaultModel, equals('gemini-1.5-flash'));
    });

    test('Rule 10 Compliance: Offline data is explicitly marked as demo data', () async {
      // In offline / test mode without real API key
      AiConfig.instance.clearApiKey();

      final result = await AiService.instance.detectCropDisease(
        imageBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
        filePath: 'test/sample_diseased_leaf.jpg',
      );

      expect(result.isDemoData, isTrue);
      expect(result.cropName, contains('Cotton'));
    });

    test('Rule 10 Compliance: Crop recommendation marks regional fallback as demo data', () async {
      AiConfig.instance.clearApiKey();

      const input = CropRecommendationInput(
        soilType: 'Black Soil',
        season: 'Kharif (Monsoon)',
        waterSource: 'Borewell',
        landArea: '5.5 Acres',
        previousCrop: 'Fallow / None',
        hasMeasuredSoilTest: false,
        location: 'Rajkot, Gujarat',
      );

      final result = await AiService.instance.recommendCrops(input: input);
      expect(result.isDemoData, isTrue);
      expect(result.recommendations, isNotEmpty);
    });

    test('Rate Limiting Guard halts requests when RPM threshold (15 requests/min) is reached', () async {
      // Set dummy API key to activate Gemini path
      AiConfig.instance.setApiKey('test_key_dummy');

      // Simulate 15 requests
      for (int i = 0; i < 15; i++) {
        AiService.instance.simulateRequestForTesting();
      }

      expect(AiService.instance.requestsThisMinute, equals(15));

      // 16th request must be rate-limited to avoid API spam
      final throttledReply = await AiService.instance.sendChatMessage('Question 16');
      expect(throttledReply, contains('rate limit'));
      expect(AiService.instance.isRateLimited, isTrue);

      AiConfig.instance.clearApiKey();
    });
  });

  group('Step 4: Free Weather API (Open-Meteo) Tests', () {
    test('Open-Meteo model contains non-commercial license attribution and valid units', () async {
      final weather = await WeatherService.instance.fetchWeather(
        districtName: 'Rajkot',
      );

      expect(weather.attribution, contains('Open-Meteo.com'));
      expect(weather.attribution, contains('CC-BY 4.0'));
      expect(weather.locationName, equals('Rajkot'));
      expect(weather.temperature, isNonNegative);
      expect(weather.humidity, inInclusiveRange(0, 100));
      expect(weather.precipitation, greaterThanOrEqualTo(0.0));
      expect(weather.fetchedAt, isNotEmpty);
    });
  });
}
