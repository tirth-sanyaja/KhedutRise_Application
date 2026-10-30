import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/config/ai_config.dart';
import '../../../core/services/ai_chat_service.dart';
import '../../../core/services/ai_history_service.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/widgets/gemini_api_key_dialog.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class AiChatScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const AiChatScreen({super.key, this.onSwitchTab});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiChatService _chatService = AiChatService.instance;
  final AiHistoryService _historyService = AiHistoryService.instance;

  String _lastFailedMessage = '';

  @override
  void initState() {
    super.initState();
    _chatService.addListener(_onServiceUpdate);
    _historyService.addListener(_onServiceUpdate);
    AiConfig.instance.addListener(_onServiceUpdate);
    _seedInitialGreetingIfNeeded();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
    _scrollToBottom();
  }

  void _seedInitialGreetingIfNeeded() {
    final history = _historyService.getChatHistory();
    if (history.isEmpty) {
      final farmer = FarmerService.instance.currentFarmer;
      final farmerName = farmer?.displayName ?? 'Farmer';
      final lang = _chatService.currentLanguage;

      String greeting;
      if (lang == 'gu') {
        greeting = 'નમસ્તે $farmerName! હું ખેડૂતરાઇઝ AI સહાયક છું. પાક સંરક્ષણ, ખાતર, પિયત કે રોગ નિયંત્રણ વિશે કંઈપણ પૂછો.';
      } else if (lang == 'hi') {
        greeting = 'नमस्ते $farmerName! मैं खेड़ूतराइज़ AI सहायक हूँ। फसल, कीट, उर्वरक या सिंचाई संबंधित सवाल पूछें।';
      } else {
        greeting = 'Hello $farmerName! I am your KhedutRise AI Assistant. How can I help you with your crops today?';
      }

      _historyService.saveChatMessage(
        AiChatMessage(
          id: 'welcome_msg',
          farmerId: farmer?.id ?? 'default_farmer',
          isUser: false,
          text: greeting,
          timestamp: DateTime.now(),
          language: lang,
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    _messageController.clear();
    _lastFailedMessage = clean;
    _scrollToBottom();

    await _chatService.sendMessage(clean);
    _scrollToBottom();
  }

  void _switchLanguage(String code) {
    setState(() {
      _chatService.setLanguage(code);
    });
    // Add brief language confirmation system note
    final farmer = FarmerService.instance.currentFarmer;
    String note;
    if (code == 'gu') {
      note = 'ભાષા બદલાઈ: હવે AI તમને ગુજરાતીમાં જવાબ આપશે.';
    } else if (code == 'hi') {
      note = 'भाषा बदली गई: अब AI आपको हिन्दी में मार्गदर्शन देगा।';
    } else {
      note = 'Language set to English. AI will now respond in English.';
    }
    _historyService.saveChatMessage(
      AiChatMessage(
        id: 'lang_note_${DateTime.now().millisecondsSinceEpoch}',
        farmerId: farmer?.id ?? 'default_farmer',
        isUser: false,
        text: note,
        timestamp: DateTime.now(),
        language: code,
      ),
    );
  }

  @override
  void dispose() {
    _chatService.removeListener(_onServiceUpdate);
    _historyService.removeListener(_onServiceUpdate);
    AiConfig.instance.removeListener(_onServiceUpdate);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = _historyService.getChatHistory();
    final lang = _chatService.currentLanguage;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(
        title: 'AI Farming Assistant',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Language Selection Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.translate, size: 18, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Text(
                    'Language:',
                    style: AppTypography.labelUppercase.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  _buildLanguagePill('ગુજરાતી', 'gu', lang == 'gu'),
                  const SizedBox(width: 6),
                  _buildLanguagePill('हिन्दी', 'hi', lang == 'hi'),
                  const SizedBox(width: 6),
                  _buildLanguagePill('English', 'en', lang == 'en'),
                ],
              ),
            ),

            // AI Engine Status & Key Setup Strip
            InkWell(
              onTap: () => GeminiApiKeyDialog.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: AiConfig.instance.isConfigured
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  border: Border(
                    bottom: BorderSide(
                      color: AiConfig.instance.isConfigured
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFFDE68A),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      AiConfig.instance.isConfigured
                          ? Icons.check_circle
                          : Icons.info_outline,
                      size: 15,
                      color: AiConfig.instance.isConfigured
                          ? AppColors.primaryDark
                          : Colors.amber.shade900,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AiConfig.instance.isConfigured
                            ? 'Gemini 1.5 Live AI સક્રિય છે (Free Tier ₹0)'
                            : 'ઓફલાઇન AI • મફત લાઈવ AI ચાલુ કરવા અહીં ટેપ કરો (₹0)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AiConfig.instance.isConfigured
                              ? AppColors.primaryDark
                              : Colors.amber.shade900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AiConfig.instance.isConfigured
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Text(
                        AiConfig.instance.isConfigured ? 'સેટિંગ્સ' : 'કી સેટ કરો',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AiConfig.instance.isConfigured
                              ? AppColors.primaryDark
                              : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Messages & Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Green Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDeep,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello ${FarmerService.instance.farmerName}',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lang == 'gu'
                                      ? 'આજે તમારા પાક વિશે શું પૂછવું છે?'
                                      : lang == 'hi'
                                          ? 'आज आपकी फसल के लिए क्या सहायता चाहिए?'
                                          : 'Ask me anything about crops, pests & weather.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick Suggestion Chips (Localized)
                    _buildSuggestionChips(lang),
                    const SizedBox(height: 18),

                    // Message Bubbles
                    ...history.map((msg) => _buildMessageBubble(msg)),

                    // Loading Indicator
                    if (_chatService.isSending)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16, right: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryDark,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    lang == 'gu'
                                        ? 'AI ખેતી સલાહ વિચારી રહ્યું છે...'
                                        : lang == 'hi'
                                            ? 'AI उत्तर तैयार कर रहा है...'
                                            : 'AI is analyzing your farming query...',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Error retry bar if last message failed
                    if (_chatService.lastError != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _chatService.lastError!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _sendMessage(_lastFailedMessage),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),

                    // 3 Circular Action Shortcuts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircleAction(
                          context,
                          icon: Icons.mic,
                          label: 'Voice',
                          onTap: () =>
                              Navigator.pushNamed(context, '/voice_assistant'),
                        ),
                        _buildCircleAction(
                          context,
                          icon: Icons.camera_alt_outlined,
                          label: 'Scan Leaf',
                          onTap: () =>
                              Navigator.pushNamed(context, '/scan_leaf'),
                        ),
                        _buildCircleAction(
                          context,
                          icon: Icons.eco_outlined,
                          label: 'Advisor',
                          onTap: () =>
                              Navigator.pushNamed(context, '/crop_advisor'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Statutory Disclaimer
                    Center(
                      child: Text(
                        'AI advice is advisory. Prioritize chemical package labels & local KVK guidance. Yield not guaranteed.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFA7F3D0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: lang == 'gu'
                              ? 'પાક વિશે કંઈપણ પૂછો...'
                              : lang == 'hi'
                                  ? 'फसल संबंधित सवाल पूछें...'
                                  : 'Ask AI anything about crops...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _sendMessage(_messageController.text),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePill(String title, String code, bool isSelected) {
    return InkWell(
      onTap: () => _switchLanguage(code),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(String lang) {
    String q1, q2, q3, q4;
    if (lang == 'gu') {
      q1 = 'કયો પાક વાવવો?';
      q2 = 'પાન પીળા કેમ પડે છે?';
      q3 = 'પિયત ક્યારે આપવું?';
      q4 = 'ખાતરનું સમયપત્રક';
    } else if (lang == 'hi') {
      q1 = 'कौन सी फसल बोएं?';
      q2 = 'पत्तियां पीली पड़ने का हल';
      q3 = 'सिंचाई कब करें?';
      q4 = 'उर्वरक की सही मात्रा';
    } else {
      q1 = 'Which crop to grow?';
      q2 = 'Crop disease solution';
      q3 = 'When to irrigate?';
      q4 = 'Fertilizer guide';
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildChip(q1, () => _sendMessage(q1))),
            const SizedBox(width: 10),
            Expanded(child: _buildChip(q2, () => _sendMessage(q2))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildChip(q3, () => _sendMessage(q3))),
            const SizedBox(width: 10),
            Expanded(child: _buildChip(q4, () => _sendMessage(q4))),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageBubble(AiChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Text(
            msg.text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 16, right: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: msg.isError
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFA7F3D0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Khedut AI Assistant',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: msg.isDemoData
                                ? const Color(0xFFFEF3C7)
                                : (msg.isError ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            msg.isDemoData
                                ? 'DEMO DATA'
                                : (msg.isError ? 'ERROR' : 'LIVE AI (₹0)'),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: msg.isDemoData
                                  ? Colors.amber.shade900
                                  : (msg.isError ? Colors.red.shade900 : AppColors.primaryDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      msg.text,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildCircleAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.6),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
