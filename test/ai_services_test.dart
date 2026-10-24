import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:khedutrise/core/config/ai_config.dart';
import 'package:khedutrise/core/models/crop_disease_model.dart';
import 'package:khedutrise/core/models/crop_recommendation_model.dart';
import 'package:khedutrise/core/services/ai_chat_service.dart';
import 'package:khedutrise/core/services/ai_history_service.dart';
import 'package:khedutrise/core/services/crop_disease_service.dart';
import 'package:khedutrise/core/services/crop_recommendation_service.dart';
import 'package:khedutrise/core/services/weather_service.dart';

void main() {
  group('AI Configuration Tests', () {
    test('AiConfig manages runtime API keys and model', () {
      final config = AiConfig.instance;
      expect(config.activeModel, equals('gemini-1.5-flash'));

      config.setApiKey('test_key_abc_123');
      expect(config.apiKey, equals('test_key_abc_123'));
      expect(config.isConfigured, isTrue);

      config.clearApiKey();
      expect(config.hasCustomKey, isFalse);
    });
  });

  group('Crop Disease Diagnostic Tests', () {
    test('CropDiseaseResult handles unclear or blurry leaf photos accurately', () {
      final unclear = CropDiseaseResult.unclearImage(
        feedback: 'The photo is too blurry to diagnose.',
      );
      expect(unclear.isClearImage, isFalse);
      expect(unclear.confidence.toLowerCase(), contains('uncertain'));
      expect(unclear.clarityFeedback, contains('blurry'));
      expect(unclear.immediateSteps, contains('Retake Photo'));
    });

    test('CropDiseaseService fallback diagnoses diseased cotton leaf correctly', () async {
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = await CropDiseaseService.instance.analyzeImage(
        filePath: 'test/sample_diseased_leaf.jpg',
        imageBytes: dummyBytes,
      );

      expect(result.cropName, contains('Cotton'));
      expect(result.diseaseName, contains('Bacterial Leaf Blight'));
      expect(result.symptoms, isNotEmpty);
      expect(result.organicTreatment, contains('Neem'));
      expect(result.chemicalTreatment, contains('Copper Oxychloride'));
      expect(result.expertConsultation, contains('KVK'));
    });

    test('CropDiseaseService handles empty image bytes with clarity feedback', () async {
      final result = await CropDiseaseService.instance.analyzeImage(
        imageBytes: Uint8List(0),
      );
      expect(result.isClearImage, isFalse);
      expect(result.clarityFeedback, contains('No image data'));
    });
  });

  group('Weather & Agrometeorology Tests', () {
    test('WeatherService baseline returns valid parameters without inventing data', () async {
      final baseline = await WeatherService.instance.fetchWeather(
        districtName: 'Rajkot',
      );
      expect(baseline.locationName, equals('Rajkot'));
      expect(baseline.temperature, isNonNegative);
      expect(baseline.humidity, inInclusiveRange(0, 100));
      expect(baseline.condition, isNotEmpty);
    });
  });

  group('Crop Recommendation Engine Tests', () {
    test('Recommends Cotton & Groundnut for Kharif black soil', () async {
      const input = CropRecommendationInput(
        soilType: 'Black Soil',
        season: 'Kharif (Monsoon)',
        waterSource: 'Borewell',
        landArea: '5.5 Acres',
        previousCrop: 'Fallow / None',
        hasMeasuredSoilTest: false,
        location: 'Rajkot, Gujarat',
      );

      final result = await CropRecommendationService.instance.recommendCrops(
        input: input,
      );

      expect(result.recommendations, isNotEmpty);
      final firstCrop = result.recommendations.first;
      expect(firstCrop.cropName, contains('Cotton'));
      expect(firstCrop.matchScore, greaterThanOrEqualTo(90));
      expect(firstCrop.expectedYield, isNotEmpty);
      expect(firstCrop.expectedProfit, isNotEmpty);
      expect(firstCrop.precautions, isNotEmpty);
      expect(result.isMeasuredSoil, isFalse);
      expect(result.advisoryNotice, contains('Advisory Note'));
    });

    test('Recommends Wheat & Cumin for Rabi season with measured soil card', () async {
      const input = CropRecommendationInput(
        soilType: 'Black Soil',
        season: 'Rabi (Winter)',
        waterSource: 'Borewell',
        landArea: '5.5 Acres',
        previousCrop: 'Cotton',
        hasMeasuredSoilTest: true,
        nitrogen: 135.0,
        phosphorus: 42.0,
        potassium: 275.0,
        ph: 7.5,
        location: 'Rajkot, Gujarat',
      );

      final result = await CropRecommendationService.instance.recommendCrops(
        input: input,
      );

      expect(result.recommendations, isNotEmpty);
      final cropNames = result.recommendations.map((r) => r.cropName).toList();
      expect(cropNames.any((name) => name.contains('Wheat')), isTrue);
      expect(result.isMeasuredSoil, isTrue);
      expect(result.soilMeasurementStatus, contains('Measured'));
    });
  });

  group('AI Farming Chatbot Tests', () {
    test('Answers farming queries in Gujarati when language is set to gu', () async {
      final chatService = AiChatService.instance;
      chatService.setLanguage('gu');
      expect(chatService.currentLanguage, equals('gu'));

      final reply = await chatService.sendMessage('કપાસના પાન પીળા પડે છે');
      expect(reply, contains('નાઇટ્રોજન'));
      expect(reply, contains('લીમડાનું તેલ'));
      expect(reply, contains('KVK'));
    });

    test('Answers farming queries in Hindi when language is set to hi', () async {
      final chatService = AiChatService.instance;
      chatService.setLanguage('hi');

      final reply = await chatService.sendMessage('फसल में पत्तियां पीली हो रही हैं');
      expect(reply, contains('नाइट्रोजन'));
      expect(reply, contains('सावधानी'));
    });

    test('Answers farming queries in English with label warnings & KVK consultation', () async {
      final chatService = AiChatService.instance;
      chatService.setLanguage('en');

      final reply = await chatService.sendMessage('My leaves are yellowing');
      expect(reply, contains('Nitrogen'));
      expect(reply, contains('Neem'));
      expect(reply, contains('label instructions'));
      expect(reply, contains('cannot be guaranteed'));
    });
  });

  group('AI History & Persistence Tests', () {
    test('Saves and retrieves scan history partitioned by farmer UID', () async {
      final historyService = AiHistoryService.instance;

      final scanResult = CropDiseaseResult(
        id: 'test_scan_001',
        cropName: 'Cotton',
        diseaseName: 'Healthy Foliage',
        confidence: 'High (95%)',
        isClearImage: true,
        clarityFeedback: '',
        symptoms: ['Clean foliage'],
        immediateSteps: 'Continue irrigation',
        preventionGuidance: 'Monitor sticky traps',
        organicTreatment: 'Neem spray',
        chemicalTreatment: 'None required',
        expertConsultation: 'KVK desk',
        scannedAt: DateTime.now(),
      );

      await historyService.saveScanResult(scanResult);
      final scans = historyService.getScansForCurrentFarmer();
      expect(scans.any((s) => s.id == 'test_scan_001'), isTrue);

      await historyService.deleteScan('test_scan_001');
      final scansAfter = historyService.getScansForCurrentFarmer();
      expect(scansAfter.any((s) => s.id == 'test_scan_001'), isFalse);
    });
  });
}
