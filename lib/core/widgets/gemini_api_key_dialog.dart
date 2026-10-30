import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../config/ai_config.dart';

/// Reusable modal dialog for configuring Gemini AI API Key (Strict ₹0 Free Tier).
/// Accessible from AI Chat, Crop Leaf Scanner, and Profile Settings.
class GeminiApiKeyDialog extends StatefulWidget {
  const GeminiApiKeyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const GeminiApiKeyDialog(),
    );
  }

  @override
  State<GeminiApiKeyDialog> createState() => _GeminiApiKeyDialogState();
}

class _GeminiApiKeyDialogState extends State<GeminiApiKeyDialog> {
  late final TextEditingController _controller;
  bool _isTesting = false;
  bool _obscureText = true;
  String? _testMessage;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: AiConfig.instance.apiKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _testKey() async {
    final candidateKey = _controller.text.trim();
    if (candidateKey.isEmpty) {
      setState(() {
        _testSuccess = false;
        _testMessage = 'કૃપા કરીને પહેલા Gemini API Key દાખલ કરો.';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testMessage = null;
      _testSuccess = null;
    });

    final success = await AiConfig.instance.testConnection(candidateKey);

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _testSuccess = success;
      _testMessage = success
          ? 'સફળ! Gemini AI લાઈવ કનેક્ટ થઈ ગયું છે.'
          : 'કનેક્શન નિષ્ફળ. કૃપા કરીને કી અને ઇન્ટરનેટ ચકાસો.';
    });
  }

  void _saveKey() {
    final key = _controller.text.trim();
    if (key.isNotEmpty) {
      AiConfig.instance.setApiKey(key);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gemini Live AI Key સફળતાપૂર્વક સાચવવામાં આવી!'),
          backgroundColor: AppColors.primaryDark,
          duration: Duration(seconds: 3),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  void _clearKey() {
    AiConfig.instance.clearApiKey();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API Key હટાવી દીધી. હવે લોકલ ઓફલાઇન AI કાર્યરત છે.'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 3),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isConfigured = AiConfig.instance.isConfigured;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology, color: AppColors.primaryDark, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gemini AI Setup (₹0)',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'ગૂગલ આર્ટિફિશિયલ ઇન્ટેલિજન્સ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Free Tier Guide Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '૧૦૦% મફત કી કેવી રીતે મેળવવી? (₹0 Free Tier)',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '૧. તમારા બ્રાઉઝરમાં aistudio.google.com/app/apikey ખોલો.\n'
                    '૨. Google એકાઉન્ટથી સાઇન ઇન કરી "Create API key" દબાવો.\n'
                    '૩. તે કી અહીં પેસ્ટ કરો. કોઈ ક્રેડિટ કાર્ડ કે ચાર્જની જરૂર નથી.',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Input field
            Text(
              'Gemini API Key દાખલ કરો:',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              obscureText: _obscureText,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
            ),

            // Test Feedback Notice
            if (_testMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _testSuccess == true ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess == true ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess == true ? Icons.check_circle : Icons.error,
                      color: _testSuccess == true ? AppColors.primaryDark : Colors.red.shade900,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testMessage!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _testSuccess == true ? AppColors.primaryDark : Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testKey,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check, size: 16),
                    label: Text(
                      _isTesting ? 'ચકાસે છે...' : 'ટેસ્ટ કરો',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveKey,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'સેવ કરો',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),

            if (isConfigured) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: _clearKey,
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: const Text(
                    'કી કાઢી નાખો (Remove Key)',
                    style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
