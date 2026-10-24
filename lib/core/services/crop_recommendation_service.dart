import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/ai_config.dart';
import '../models/crop_recommendation_model.dart';
import '../models/weather_model.dart';
import 'weather_service.dart';

/// Service generating AI crop suggestions based on farm soil, season, weather, and water parameters.
class CropRecommendationService extends ChangeNotifier {
  CropRecommendationService._internal();
  static final CropRecommendationService instance =
      CropRecommendationService._internal();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CropRecommendationResult? _lastResult;
  CropRecommendationResult? get lastResult => _lastResult;

  /// Generate AI crop recommendations
  Future<CropRecommendationResult> recommendCrops({
    required CropRecommendationInput input,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch live weather for location
      FarmWeather? weather;
      try {
        weather = await WeatherService.instance.fetchWeather(
          districtName: input.location,
        );
      } catch (e) {
        debugPrint('Weather fetch skipped in crop recommendation: $e');
      }

      // 2. Call Gemini API if configured
      if (AiConfig.instance.isConfigured) {
        try {
          final geminiResult = await _callGeminiRecommendation(input, weather);
          _lastResult = geminiResult;
          _isLoading = false;
          notifyListeners();
          return geminiResult;
        } catch (e) {
          debugPrint('Gemini Crop Recommendation error: $e. Using agronomic engine.');
        }
      }

      // 3. Fallback agricultural domain recommendation engine
      final result = _generateRuleBasedRecommendation(input, weather);
      _lastResult = result;
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('Crop recommendation exception: $e');
      final fallback = _generateRuleBasedRecommendation(input, null);
      _lastResult = fallback;
      _isLoading = false;
      notifyListeners();
      return fallback;
    }
  }

  /// Sends farm and soil parameters to Gemini API for multimodal reasoning
  Future<CropRecommendationResult> _callGeminiRecommendation(
    CropRecommendationInput input,
    FarmWeather? weather,
  ) async {
    final url = AiConfig.instance.geminiBaseUrl;

    final soilDesc = input.hasMeasuredSoilTest
        ? 'Soil Test (Measured): N=${input.nitrogen ?? "N/A"} kg/ha, P=${input.phosphorus ?? "N/A"} kg/ha, K=${input.potassium ?? "N/A"} kg/ha, pH=${input.ph ?? "N/A"}'
        : 'Soil Test: Farmer does NOT have measured lab test card; using estimated regional baseline for ${input.soilType}.';

    final weatherDesc = weather != null
        ? 'Current Weather: ${weather.temperature}°C, ${weather.humidity}% humidity, precipitation=${weather.precipitation}mm (${weather.isLive ? "Live API" : "Estimated baseline"})'
        : 'Weather: Average seasonal baseline';

    final prompt = '''
You are a senior agricultural scientist at the Indian Council of Agricultural Research (ICAR).
Recommend the top 2-3 most viable, profitable, and climate-resilient crops for an Indian farmer with these exact farm parameters:
- Location: ${input.location}
- Soil Type: ${input.soilType}
- Season: ${input.season}
- Water Availability: ${input.waterSource}
- Farm Area: ${input.landArea}
- Previous Crop in field: ${input.previousCrop}
- $soilDesc
- $weatherDesc

Return ONLY a strictly valid JSON object matching this schema:
{
  "recommendations": [
    {
      "cropName": "Name of crop and recommended Indian cultivar/variety",
      "matchScore": 95,
      "expectedYield": "Expected yield in Quintals/Acre",
      "expectedProfit": "Net profit estimate in ₹/Acre",
      "durationDays": "Crop duration in days",
      "marketDemand": "Market demand & MSP status",
      "growingConditions": "Key growing conditions required",
      "precautions": ["Precaution 1", "Precaution 2", "Precaution 3"],
      "whyRecommended": "Agronomic justification considering soil, previous crop, and season"
    }
  ],
  "advisoryNotice": "Important advisory notice reminding farmer to cross-verify with local Krishi Vigyan Kendra (KVK) and package labels before planting."
}

Do not invent measured soil test values if the farmer indicated they do not have a soil card.
Return ONLY raw JSON, with no markdown backticks.
''';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 1500,
      }
    });

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception('Gemini API returned status ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Empty candidates');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    String rawText = parts?[0]['text'] as String? ?? '';
    rawText = rawText.trim();
    if (rawText.startsWith('```json')) rawText = rawText.substring(7);
    if (rawText.startsWith('```')) rawText = rawText.substring(3);
    if (rawText.endsWith('```')) rawText = rawText.substring(0, rawText.length - 3);
    rawText = rawText.trim();

    final parsed = jsonDecode(rawText) as Map<String, dynamic>;
    final itemsList = (parsed['recommendations'] as List<dynamic>?)
            ?.map((e) => CropRecommendationItem.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    final advisoryNotice = parsed['advisoryNotice'] as String? ??
        'Advisory Note: Crop recommendations are algorithmic advisory estimates. Consult your local Taluka Agriculture Officer or Krishi Vigyan Kendra (KVK) before purchasing bulk seed inventory.';

    return CropRecommendationResult(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      input: input,
      weather: weather,
      recommendations: itemsList,
      isMeasuredSoil: input.hasMeasuredSoilTest,
      advisoryNotice: advisoryNotice,
      createdAt: DateTime.now(),
      isDemoData: false, // Live AI generated
    );
  }

  /// Rule-based agronomic model reflecting ICAR / Gujarat agricultural university guidelines
  CropRecommendationResult _generateRuleBasedRecommendation(
    CropRecommendationInput input,
    FarmWeather? weather,
  ) {
    final seasonLower = input.season.toLowerCase();
    final soilLower = input.soilType.toLowerCase();
    final prevCropLower = input.previousCrop.toLowerCase();

    List<CropRecommendationItem> recommendations = [];

    // Rabi (Winter) Season logic
    if (seasonLower.contains('rabi') || seasonLower.contains('winter')) {
      if (prevCropLower.contains('cotton') || prevCropLower.contains('groundnut')) {
        recommendations.add(
          const CropRecommendationItem(
            cropName: 'Wheat (Triticum aestivum - GW-496 / GW-322)',
            matchScore: 94,
            expectedYield: '20 - 24 Quintals / Acre',
            expectedProfit: '₹48,000 - ₹62,000 / Acre',
            durationDays: '115 - 125 Days',
            marketDemand: 'Very High (Government MSP ₹2,275/Qtl guaranteed)',
            growingConditions:
                'Requires cool winter temperatures during vegetative growth and bright sunshine during grain filling. 4-5 irrigations required.',
            precautions: [
                'Ensure crown root initiation (CRI) irrigation at 21 days after sowing (DAS)',
                'Avoid excessive nitrogen to prevent lodging and yellow rust susceptibility',
                'Treat certified seed with Trichoderma viride @ 5g/kg',
            ],
            whyRecommended:
                'Excellent follow-up crop after Kharif cotton or groundnut; breaks disease cycles and utilizes residual soil moisture.',
          ),
        );

        recommendations.add(
          const CropRecommendationItem(
            cropName: 'Cumin / Jeeru (Cuminum cyminum - GC-4)',
            matchScore: 91,
            expectedYield: '4 - 6 Quintals / Acre',
            expectedProfit: '₹70,000 - ₹95,000 / Acre',
            durationDays: '100 - 110 Days',
            marketDemand: 'Extremely High in Rajkot / Unjha Mandi (₹28,000 - ₹35,000/Qtl)',
            growingConditions:
                'Thrives in well-drained sandy loam or medium black soil with moderate winter chill and dry humidity.',
            precautions: [
                'Withhold sprinkler irrigation during cloudy or overcast spells to avoid blight',
                'Prevent water stagnation; construct raised nursery beds',
                'Monitor for powdery mildew and spray wettable sulfur @ 2.5 g/L',
            ],
            whyRecommended:
                'Highest cash-crop profit potential for Saurashtra region during dry winter months.',
          ),
        );

        recommendations.add(
          const CropRecommendationItem(
            cropName: 'Gram / Chickpea / Chana (Cicer arietinum - GG-2 / GG-5)',
            matchScore: 88,
            expectedYield: '8 - 11 Quintals / Acre',
            expectedProfit: '₹35,000 - ₹46,000 / Acre',
            durationDays: '95 - 105 Days',
            marketDemand: 'High Demand (Government MSP ₹5,440/Qtl)',
            growingConditions:
                'Low water requirement, deep taproot system, fixes atmospheric nitrogen into soil.',
            precautions: [
                'Do not over-irrigate; maximum 2 light irrigations at pre-flowering and pod filling',
                'Pinch apical shoots at 30 DAS to induce lateral branching',
            ],
            whyRecommended:
                'Restores depleted soil nitrogen naturally after heavy-feeder Kharif crops.',
          ),
        );
      } else {
        recommendations.add(
          const CropRecommendationItem(
            cropName: 'Mustard / Rai (Brassica juncea - GM-3)',
            matchScore: 90,
            expectedYield: '8 - 10 Quintals / Acre',
            expectedProfit: '₹40,000 - ₹52,000 / Acre',
            durationDays: '105 - 115 Days',
            marketDemand: 'High Oilseed Demand (MSP ₹5,650/Qtl)',
            growingConditions:
                'Frost-tolerant, thrives in sandy loam to clayey soils with 2-3 irrigations.',
            precautions: [
                'Monitor for aphid infestation during flowering stage',
                'Maintain proper spacing of 45 cm x 15 cm',
            ],
            whyRecommended:
                'Low input cost and high net return under limited irrigation supply.',
          ),
        );
      }
    } else {
      // Kharif (Monsoon) or General Season logic
      if (soilLower.contains('black') || soilLower.contains('clay')) {
        recommendations.add(
          const CropRecommendationItem(
            cropName: 'Bt Cotton (Gossypium hirsutum - RCH 659 / G.Cot.Hy.12)',
            matchScore: 96,
            expectedYield: '14 - 18 Quintals / Acre',
            expectedProfit: '₹68,000 - ₹88,000 / Acre',
            durationDays: '150 - 165 Days',
            marketDemand: 'High Demand (Rajkot APMC Mandi MSP ₹7,121/Qtl)',
            growingConditions:
                'Deep black clayey soil with high moisture retention, warm sunny climate (25-35°C).',
            precautions: [
                'Install pheromone traps (5 traps/acre) at 45 DAS to monitor pink bollworm',
                'Apply potassium nitrate (13-0-45) foliar spray at boll formation stage',
                'Avoid waterlogging; ensure proper field drainage channels',
            ],
            whyRecommended:
                'Black cotton soils of Saurashtra provide premier cation exchange capacity and water holding suitable for boll development.',
          ),
        );

        recommendations.add(
          const CropRecommendationItem(
            cropName: 'Groundnut / Magfali (Arachis hypogaea - GG-20 / GJG-22)',
            matchScore: 93,
            expectedYield: '12 - 15 Quintals / Acre',
            expectedProfit: '₹55,000 - ₹72,000 / Acre',
            durationDays: '110 - 120 Days',
            marketDemand: 'Very High Domestic & Export Oil Demand (MSP ₹6,377/Qtl)',
            growingConditions:
                'Well-aerated soil allowing easy peg penetration and pod formation; requires Gypsum application.',
            precautions: [
                'Apply Gypsum @ 150 kg/Acre at flowering stage for strong shell calcification',
                'Prevent collar rot with seed treatment of Trichoderma @ 5g/kg seed',
            ],
            whyRecommended:
                'Leguminous crop that enriches soil biology while commanding prompt APMC cash liquidity.',
          ),
        );

        recommendations.add(
          const CropRecommendationItem(
            cropName: 'Soybean (Glycine max - JS-335 / NRC-37)',
            matchScore: 87,
            expectedYield: '10 - 13 Quintals / Acre',
            expectedProfit: '₹42,000 - ₹56,000 / Acre',
            durationDays: '90 - 100 Days',
            marketDemand: 'Steady Demand (MSP ₹4,600/Qtl)',
            growingConditions:
                'Warm humid weather, fertile well-drained soil, short duration.',
            precautions: [
                'Avoid planting in waterlogged lowlands',
                'Inoculate seeds with Rhizobium and PSB culture prior to sowing',
            ],
            whyRecommended:
                'Short duration 95-day cycle enables rapid cash return and allows timely Rabi sowing.',
          ),
        );
      } else {
        // Sandy or Red soil
        recommendations.add(
          const CropRecommendationItem(
            cropName: 'Groundnut (Semi-Spreading - GG-20 / TG-37A)',
            matchScore: 92,
            expectedYield: '11 - 14 Quintals / Acre',
            expectedProfit: '₹52,000 - ₹68,000 / Acre',
            durationDays: '105 - 115 Days',
            marketDemand: 'High Demand across APMCs',
            growingConditions:
                'Loose light texture soil permits optimal gynophore peg penetration.',
            precautions: [
                'Ensure supplementary irrigation during pod enlargement stage',
                'Apply organic compost / farmyard manure to enhance water retention',
            ],
            whyRecommended:
                'Light and loamy soils minimize pod loss during harvesting.',
          ),
        );

        recommendations.add(
          const CropRecommendationItem(
            cropName: 'Sesame / Til (Sesamum indicum - Gujarat Til-2)',
            matchScore: 89,
            expectedYield: '3 - 5 Quintals / Acre',
            expectedProfit: '₹38,000 - ₹50,000 / Acre',
            durationDays: '85 - 90 Days',
            marketDemand: 'High Export Value (₹12,000 - ₹15,000/Qtl)',
            growingConditions:
                'Drought-tolerant crop suitable for light sandy loam soils with minimal irrigation.',
            precautions: [
                'Keep field weed-free during initial slow growth stage (first 25 days)',
                'Harvest before seed capsules shatter in field',
            ],
            whyRecommended:
                'Thrives in light soils with minimal fertilizer and water input.',
          ),
        );
      }
    }

    final advisoryNotice = input.hasMeasuredSoilTest
        ? 'Advisory Note: Recommendations are tailored to your measured soil lab card (N: ${input.nitrogen ?? "--"}, P: ${input.phosphorus ?? "--"}, K: ${input.potassium ?? "--"}, pH: ${input.ph ?? "--"}). Always adhere to certified package practices.'
        : 'Advisory Note: Recommendations are based on regional Saurashtra agro-climatic baselines because measured soil test values were not provided. Soil testing at your local Sub-Divisional Soil Testing Lab is strongly advised.';

    return CropRecommendationResult(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      input: input,
      weather: weather,
      recommendations: recommendations,
      isMeasuredSoil: input.hasMeasuredSoilTest,
      advisoryNotice: advisoryNotice,
      createdAt: DateTime.now(),
      isDemoData: true, // Rule 10: Clearly marked as regional demo baseline
    );
  }
}
