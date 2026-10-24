import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/ai_config.dart';
import 'ai_history_service.dart';
import 'farmer_service.dart';

/// Real AI Farming Assistant supporting Gujarati, Hindi, and English.
/// Powered by Gemini 1.5 Flash with conversational memory and agricultural safety disclaimers.
class AiChatService extends ChangeNotifier {
  AiChatService._internal();
  static final AiChatService instance = AiChatService._internal();

  bool _isSending = false;
  bool get isSending => _isSending;

  String? _lastError;
  String? get lastError => _lastError;

  String _currentLanguage = 'en'; // 'gu' (Gujarati), 'hi' (Hindi), 'en' (English)
  String get currentLanguage => _currentLanguage;

  void setLanguage(String langCode) {
    if (_currentLanguage != langCode) {
      _currentLanguage = langCode;
      notifyListeners();
    }
  }

  /// Sends a message from the farmer to the AI assistant
  Future<String> sendMessage(String userMessage) async {
    final cleanMessage = userMessage.trim();
    if (cleanMessage.isEmpty) return '';

    _isSending = true;
    _lastError = null;
    notifyListeners();

    final farmer = FarmerService.instance.currentFarmer;
    final farmerId = farmer?.id ?? 'default_farmer';

    // 1. Record user message in history
    final userMsgObj = AiChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_u',
      farmerId: farmerId,
      isUser: true,
      text: cleanMessage,
      timestamp: DateTime.now(),
      language: _currentLanguage,
    );
    await AiHistoryService.instance.saveChatMessage(userMsgObj);

    try {
      String aiReplyText = '';

      // 2. Call Gemini API if configured
      if (AiConfig.instance.isConfigured) {
        try {
          aiReplyText = await _callGeminiChat(cleanMessage);
        } catch (e) {
          debugPrint('Gemini Chat call failed: $e. Falling back to agronomic knowledge engine.');
        }
      }

      // 3. Fallback agricultural knowledge engine if Gemini not configured or offline
      if (aiReplyText.isEmpty) {
        aiReplyText = _generateAgronomicResponse(cleanMessage, farmer);
      }

      // 4. Record AI assistant message in history
      final aiMsgObj = AiChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        farmerId: farmerId,
        isUser: false,
        text: aiReplyText,
        timestamp: DateTime.now(),
        language: _currentLanguage,
      );
      await AiHistoryService.instance.saveChatMessage(aiMsgObj);

      _isSending = false;
      notifyListeners();
      return aiReplyText;
    } catch (e) {
      _isSending = false;
      _lastError = 'Unable to receive advice right now. Please check internet connection.';
      final errMsgObj = AiChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_err',
        farmerId: farmerId,
        isUser: false,
        text: 'I could not connect to the agricultural knowledge base. Please check your network and tap retry.',
        timestamp: DateTime.now(),
        language: _currentLanguage,
        isError: true,
      );
      await AiHistoryService.instance.saveChatMessage(errMsgObj);
      notifyListeners();
      return '';
    }
  }

  /// Multiturn Gemini API call with farmer context & safety rules
  Future<String> _callGeminiChat(String message) async {
    final url = AiConfig.instance.geminiBaseUrl;
    final farmer = FarmerService.instance.currentFarmer;

    final history = AiHistoryService.instance.getChatHistory();
    // Take recent 6 turns for conversational context
    final recentHistory = history.length > 8 ? history.sublist(history.length - 8) : history;

    final farmerContext = '''
Farmer Profile:
- Name: ${farmer?.displayName ?? "Farmer"}
- Location: ${farmer?.village ?? "Sardhar"}, ${farmer?.district ?? "Rajkot"}, ${farmer?.state ?? "Gujarat"}
- Soil: ${farmer?.soilType ?? "Black Soil"}
- Water: ${farmer?.waterSource ?? "Borewell"}
- Land: ${farmer?.landAcres ?? "5.5 Acres"}
Active Language: ${_getLanguageName(_currentLanguage)}
''';

    final systemInstruction = '''
You are KhedutRise AI Farming Assistant, a certified Indian agronomist and crop advisor.
$farmerContext

Strict Behavioral & Agricultural Guidelines:
1. Always reply in the farmer's active language: ${_getLanguageName(_currentLanguage)}.
2. If asked in Gujarati, answer in natural Gujarati (ગુજરાતી). If in Hindi, answer in Hindi (हिन्दी). If English, answer in clear English.
3. Be respectful, practical, and direct. Focus on actionable guidance for Indian crops (Cotton, Groundnut, Cumin, Wheat, Mustard, Vegetables, Pulses, Sugarcane).
4. For all pesticide and chemical fertilizer recommendations, emphasize following package label instructions and verifying with the local Krishi Vigyan Kendra (KVK).
5. NEVER claim that AI advice guarantees a specific harvest or yield; explain that farming outcomes depend on weather and field management.
6. Provide organic remedies (Neem oil, Trichoderma, cow urine extract, sticky traps) alongside integrated pest management.
7. Keep responses concise and formatted with bullet points for readability on mobile screens.
''';

    final contents = <Map<String, dynamic>>[];

    // Add prior conversation turns
    for (final h in recentHistory) {
      if (h.isError) continue;
      contents.add({
        'role': h.isUser ? 'user' : 'model',
        'parts': [
          {'text': h.text}
        ]
      });
    }

    // Add current user prompt
    contents.add({
      'role': 'user',
      'parts': [
        {'text': '$systemInstruction\nFarmer Question: $message'}
      ]
    });

    final requestBody = jsonEncode({
      'contents': contents,
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 800,
      }
    });

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Gemini status ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Empty candidates');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts?[0]['text'] as String?;
    return text?.trim() ?? '';
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'gu':
        return 'Gujarati (ગુજરાતી)';
      case 'hi':
        return 'Hindi (हिन्दी)';
      default:
        return 'English';
    }
  }

  /// High-accuracy offline agronomic response engine for Indian farmers
  String _generateAgronomicResponse(String prompt, dynamic farmer) {
    final lower = prompt.toLowerCase();
    final lang = _currentLanguage;

    // Disease / Yellow leaf / Pests
    if (lower.contains('yellow') ||
        lower.contains('disease') ||
        lower.contains('pest') ||
        lower.contains('leaf') ||
        lower.contains('leaves') ||
        lower.contains('પીળા') ||
        lower.contains('પીળી') ||
        lower.contains('રોગ') ||
        lower.contains('ઈયળ') ||
        lower.contains('કીટક') ||
        lower.contains('पीले') ||
        lower.contains('पीली') ||
        lower.contains('पत्ती') ||
        lower.contains('रोग') ||
        lower.contains('कीट')) {
      if (lang == 'gu') {
        return '''કપાસ અને અન્ય પાકમાં પાન પીળા પડવાના મુખ્ય કારણો નાઇટ્રોજનની ઉણપ અથવા ચૂસિયા પ્રકારની જીવાત (થ્રિપ્સ, સફેદ માખી) હોઈ શકે છે.

ઉકેલ અને માર્ગદર્શન:
• તરત પગલાં: 19:19:19 ખાતર 100 ગ્રામ / 15 લીટર પાણીમાં ઓગાળી છંટકાવ કરો.
• જૈવિક ઉપચાર: લીમડાનું તેલ (1500 PPM) 40 મિલી પ્રતિ પંપ છાંટો અને પીળા ચીકણા ટ્રેપ (10 નંગ/એકર) લગાવો.
• સાવચેતી: કોઈપણ દવા છાંટતા પહેલા ઉત્પાદકના પેકેજ પર આપેલી સૂચનાઓ અવશ્ય વાંચો. પાક ઉત્પાદન હવામાન અને સંભાળ પર આધાર રાખે છે.
• વધુ સલાહ માટે નજીકના કૃષિ વિજ્ઞાન કેન્દ્ર (KVK) નો સંપર્ક કરો.''';
      } else if (lang == 'hi') {
        return '''फसल में पत्तियां पीली पड़ने का मुख्य कारण नाइट्रोजन की कमी या रसचूसक कीट (सफेद मक्खी, थ्रिप्स) हो सकते हैं।

कृषि समाधान:
• तत्काल कदम: NPK 19-19-19 उर्वरक 100 ग्राम प्रति 15 लीटर पंप में घोलकर छिड़काव करें।
• जैविक नियंत्रण: नीम का तेल (1500 PPM) 40 मिली प्रति पंप स्प्रे करें और पीले चिपचिपे कार्ड लगाएं।
• सावधानी: कीटनाशक का उपयोग लेबल पर दिए निर्देशों के अनुसार ही करें। उपज की गारंटी मौसम और देखरेख पर निर्भर करती है।
• स्थानीय कृषि विज्ञान केंद्र (KVK) के विशेषज्ञ से अवश्य सलाह लें।''';
      } else {
        return '''Yellowing foliage in crops like Cotton and Groundnut is commonly caused by early Nitrogen/Iron deficiency or sucking pests (aphids, thrips, whiteflies).

Agronomic Recommendations:
• Immediate action: Foliar spray of soluble NPK 19-19-19 @ 100g per 15L water pump.
• Organic control: Spray 5% Neem Seed Kernel Extract (NSKE) or Neem oil 1500ppm (40ml/pump). Deploy 8 yellow sticky traps per acre.
• Statutory Caution: Always strictly adhere to product label instructions for dosages and waiting periods. Harvest yield cannot be guaranteed as it depends on local climate and soil factors.
• For on-field verification, consult your local Krishi Vigyan Kendra (KVK) agronomist.''';
      }
    }

    // Irrigation / Water
    if (lower.contains('irrigate') ||
        lower.contains('water') ||
        lower.contains('પિયત') ||
        lower.contains('પાણી') ||
        lower.contains('सिंचाई') ||
        lower.contains('पानी')) {
      if (lang == 'gu') {
        return '''પિયત વ્યવસ્થાપન માર્ગદર્શન:
• જમીનમાં 5 સે.મી. ઊંડાઈ સુધી ભેજ ચકાસ્યા પછી જ પિયત આપો.
• કપાસમાં ફૂલ અને જીંડવા બેસવાના સમયે પિયતની તાણ ન પડવી જોઈએ.
• કાળી જમીનમાં વધુ પડતું પાણી ભરાઈ ન રહે તેનું ખાસ ધ્યાન રાખો જેથી મૂળનો કોહવારો ન થાય.
• ટપક સિંચાઈ (Drip Irrigation) નો ઉપયોગ કરવાથી 40% પાણી બચે છે અને ઉત્પાદનમાં વધારો થાય છે.''';
      } else if (lang == 'hi') {
        return '''सिंचाई प्रबंधन दिशानिर्देश:
• मिट्टी में 5 सेमी गहराई तक नमी जांचने के बाद ही पानी दें।
• कपास में फूल और गूलर बनते समय तथा गेहूं में पहली सिंचाई (21 दिन पर) अत्यंत महत्वपूर्ण है।
• खेत में जलभराव न होने दें, अन्यथा जड़ों में सड़न की समस्या हो सकती है।
• ड्रिप सिंचाई अपनाने से 40% पानी की बचत होती है और फसल स्वस्थ रहती है।''';
      } else {
        return '''Crop Irrigation Guidelines:
• Always check soil moisture 5 cm below surface before scheduling irrigation.
• Critical stages: Flowering and boll formation in Cotton; Crown Root Initiation (21 DAS) in Wheat; Pod development in Groundnut.
• Avoid waterlogging in black soils to prevent root rot and wilting.
• Adopting drip irrigation saves up to 40% water while maintaining optimal root aeration.''';
      }
    }

    // Fertilizer / NPK
    if (lower.contains('fertilizer') ||
        lower.contains('npk') ||
        lower.contains('urea') ||
        lower.contains('ખાતર') ||
        lower.contains('ખાતરનો') ||
        lower.contains('उर्वरक') ||
        lower.contains('खाद')) {
      if (lang == 'gu') {
        return '''ખાતર વ્યવસ્થાપન ભલામણ:
• કપાસ માટે: પ્રતિ એકર યુરિયા ખાતર 2 થી 3 હપ્તામાં આપવું. વાવણી વખતે DAP અથવા NPK (10:26:26) આપવું.
• સૂક્ષ્મ પોષક તત્વો: ઝિંક અને મેગ્નેશિયમ સલ્ફેટનો છંટકાવ પાકની વૃદ્ધિ માટે ઉત્તમ છે.
• દેશી ખાતર: એકરે 4 થી 5 ટન સારું કોહવાયેલું છાણીયું ખાતર અથવા વર્મીકમ્પોસ્ટ જમીનની ફળદ્રુપતા વધારે છે.
• સલાહ: તમારી જમીનનું સોઈલ હેલ્થ કાર્ડ કઢાવીને જ રાસાયણિક ખાતરોનો પ્રમાણસર ઉપયોગ કરો.''';
      } else if (lang == 'hi') {
        return '''उर्वरक एवं पोषण प्रबंधन:
• बुवाई के समय संतुलित NPK (12:32:16 या DAP + पोटाश) का उपयोग करें।
• यूरिया को एक साथ न देकर 2-3 किस्तों में बांटकर पौधों की जड़ों के पास दें।
• फूल आने की अवस्था में 00:52:34 का पर्णीय छिड़काव फलों/दानों के भराव में सहायक है।
• चेतावनी: उर्वरक पैकेट पर दिए निर्देशों का पालन करें। अधिक यूरिया से कीट प्रकोप बढ़ सकता है।''';
      } else {
        return '''Fertilizer & Soil Nutrition Guide:
• Basal application: Apply balanced NPK (e.g. 10:26:26 or DAP with MOP) at sowing time.
• Split Nitrogen: Split Urea into 2-3 top dressings to prevent leaching in sandy/loamy soils.
• Foliar booster: Spray 00:52:34 @ 75g/pump during flower bud development for superior boll/grain weight.
• Label Advisory: Prioritize soil health card readings and package guidelines. Avoid excessive urea which invites sucking pests.''';
      }
    }

    // Crop selection / Which crop to grow
    if (lower.contains('which crop') ||
        lower.contains('crop to grow') ||
        lower.contains('કયો પાક') ||
        lower.contains('વાવેતર') ||
        lower.contains('कौन सी फसल') ||
        lower.contains('बुवाई')) {
      if (lang == 'gu') {
        return '''તમારા વિસ્તાર અને જમીન માટે શ્રેષ્ઠ પાક ભલામણ:
• ચોમાસુ (ખરીફ): બીટી કપાસ (RCH 659), મગફળી (GG-20), સોયાબીન અથવા તુવેર.
• શિયાળુ (રવિ): ઘઉં (GW-496 / GW-322), જીરું (GC-4), ચણા (GG-2), અથવા રાયડો.
• ઉનાળુ (ઝાયદ): તલ, મગ, અથવા ઉનાળુ બાજરી.
• ચોક્કસ ગણતરી અને નફાકારકતા માટે એપ્લિકેશનના 'Smart Crop Advisor' માં તમારી જમીન અને પાણીની વિગતો દાખલ કરો.''';
      } else if (lang == 'hi') {
        return '''आपके क्षेत्र और मौसम के लिए अनुशंसित फसलें:
• खरीफ (मानसून): बीटी कपास, मूंगफली (GG-20), सोयाबीन, या उड़द।
• रबी (सर्दी): गेहूं (GW-496), जीरा, चना, या सरसों।
• जायद (गर्मी): तिल या मूंग।
• सटीक जानकारी के लिए ऐप के 'Smart Crop Advisor' फीचर में अपनी मिट्टी और सिंचाई का प्रकार चुनें।''';
      } else {
        return '''Recommended Crops for your Agro-Climatic Zone:
• Kharif (Monsoon): Bt Cotton (RCH 659 / G.Cot.Hy.12), Groundnut (GG-20 / GJG-22), Soybean, or Pigeon Pea.
• Rabi (Winter): Wheat (GW-496 / Lok-1), Cumin / Jeeru (GC-4), Chickpea / Chana (GG-5), or Mustard.
• Summer (Zaid): Sesame (Til), Green Gram (Moong), or Pearl Millet (Bajra).
• Tap 'Smart Crop Advisor' in the app to calculate expected yield and net profit tailored to your specific field acres.''';
      }
    }

    // General greeting or fallback
    if (lang == 'gu') {
      return '''નમસ્તે ખેડૂત મિત્ર! હું ખેડૂતરાઇઝ AI સહાયક છું. 

હું તમને નીચેની બાબતોમાં મદદ કરી શકું છું:
• પાક સંરક્ષણ અને રોગ-જીવાત નિયંત્રણ
• ખાતરનું સંતુલિત પ્રમાણ અને સમયપત્રક
• પિયત વ્યવસ્થાપન અને હવામાન આધારિત સલાહ
• બજારભાવ અને શ્રેષ્ઠ પાકની પસંદગી

તમે કોઈપણ પાક સંબંધિત પ્રશ્ન ગુજરાતી, હિન્દી કે અંગ્રેજીમાં પૂછી શકો છો!''';
    } else if (lang == 'hi') {
      return '''नमस्ते किसान भाई! मैं खेड़ूतराइज़ AI सहायक हूँ।

मैं आपकी इन विषयों में सहायता कर सकता हूँ:
• फसल सुरक्षा और कीट-रोग नियंत्रण
• उर्वरक और पोषण की सही मात्रा
• मौसम अनुसार सिंचाई मार्गदर्शन
• आपके खेत के लिए सबसे उपयुक्त फसल की सलाह

आप कृषि संबंधित कोई भी सवाल बेझिझक पूछ सकते हैं!''';
    } else {
      return '''Hello Farmer! I am your KhedutRise AI Agricultural Assistant.

I can assist you with:
• Crop disease & pest diagnosis with organic and chemical controls
• Balanced NPK fertilizer scheduling and dosage calculations
• Irrigation timing and weather-adaptive farm planning
• Crop recommendation based on soil and season

Feel free to ask any farming question in English, Gujarati (ગુજરાતી), or Hindi (हिन्दी)!''';
    }
  }
}
