import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
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
}
