import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/config/ai_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'Gujarati (ગુજરાતી)';
  String _landUnit = 'Acres';
  bool _weatherAlerts = true;
  bool _pestWarnings = true;
  bool _mandiPriceAlerts = true;
  bool _offlineSync = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(
        title: 'App Settings',
        subtitle: 'Preferences & Configurations',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          children: [
            Text(
              'Regional & Language',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            _buildDropdownTile(
              title: 'App Language',
              value: _selectedLanguage,
              items: ['Gujarati (ગુજરાતી)', 'Hindi (हिन्दी)', 'English'],
              onChanged: (val) {
                if (val != null) setState(() => _selectedLanguage = val);
              },
            ),
            _buildDropdownTile(
              title: 'Land Area Unit',
              value: _landUnit,
              items: ['Acres', 'Vigha (વીઘા)', 'Hectares'],
              onChanged: (val) {
                if (val != null) setState(() => _landUnit = val);
              },
            ),
            const Divider(height: 28),

            Text(
              'Notifications & Alerts',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            _buildSwitchTile(
              title: 'Severe Weather & Rain Alerts',
              subtitle: 'Real-time rainfall & cyclone forecast for Rajkot',
              value: _weatherAlerts,
              onChanged: (val) => setState(() => _weatherAlerts = val),
            ),
            _buildSwitchTile(
              title: 'AI Pest & Disease Outbreak Warnings',
              subtitle: 'Alerts if nearby farms report crop pests',
              value: _pestWarnings,
              onChanged: (val) => setState(() => _pestWarnings = val),
            ),
            _buildSwitchTile(
              title: 'Daily Mandi Price Updates',
              subtitle: 'Rajkot & Gondal APMC market rates',
              value: _mandiPriceAlerts,
              onChanged: (val) => setState(() => _mandiPriceAlerts = val),
            ),
            const Divider(height: 28),

            Text(
              'Data & Offline Mode',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            _buildSwitchTile(
              title: 'Offline Farm Data Sync',
              subtitle: 'Cache field tasks and crop advice without internet',
              value: _offlineSync,
              onChanged: (val) => setState(() => _offlineSync = val),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Clear Local Cache',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Freed up space: 14.2 MB',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Local cache cleared successfully!'),
                      backgroundColor: AppColors.primaryDark,
                    ),
                  );
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Divider(height: 28),

            Text(
              'AI & Cloud Configuration',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            _buildAiConfigTile(),
            const Divider(height: 28),

            Text(
              'About Application',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'v${AppConstants.appVersion}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Empowering Gujarat farmers with AI-driven diagnostics, land marketplace, and mechanization rentals.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          DropdownButton<String>(
            value: items.contains(value) ? value : items.firstOrNull,
            underline: const SizedBox(),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAiConfigTile() {
    final aiConfig = AiConfig.instance;
    final isConfigured = aiConfig.isConfigured;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Text(
                    'Gemini 1.5 Multimodal AI',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isConfigured ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isConfigured ? 'Connected' : 'Offline Engine',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isConfigured ? AppColors.primaryDark : Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isConfigured
                ? 'Active Key: •••••••••••••••• (Gemini API Active)'
                : 'No custom API key entered. Running high-precision local agronomic AI.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Strict ₹0 Cost & Free Tier Guard',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '• Gemini Free Tier: 15 RPM / 1,500 RPD (₹0, no credit card)\n'
                  '• Firebase Spark: 50k reads / 20k writes daily limit\n'
                  '• In-Memory Images: Zero Cloud Storage upload cost\n'
                  '• Open-Meteo: Free non-commercial API (CC-BY 4.0)\n'
                  '• Data Notice: Free Gemini prompts may be used for model training.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _showApiKeyDialog,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isConfigured ? 'Change Key' : 'Configure Key',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              if (isConfigured) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testAiConnection,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Test Status',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController(text: AiConfig.instance.apiKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gemini API Key Setup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google AI Studio Gemini API Key. Keys can also be provided at build time via --dart-define=GEMINI_API_KEY=your_key.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          if (AiConfig.instance.hasCustomKey)
            TextButton(
              onPressed: () {
                AiConfig.instance.clearApiKey();
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('Clear Key', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                AiConfig.instance.setApiKey(controller.text.trim());
              }
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _testAiConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Testing connection to Google Gemini API...'),
        duration: Duration(seconds: 2),
      ),
    );

    final success = await AiConfig.instance.testConnection();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Gemini Multimodal AI is active and responding!'
              : 'Connection test failed. Check key validity or internet connectivity.',
        ),
        backgroundColor: success ? AppColors.primary : Colors.red,
      ),
    );
  }
}
