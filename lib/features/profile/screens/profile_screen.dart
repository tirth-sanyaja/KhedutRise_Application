import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to log out from KhedutRise?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              FarmerService.instance.logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showLandRecordsDialog(BuildContext context) {
    final farmer = FarmerService.instance.currentFarmer;
    final khata = farmer?.id.replaceAll('#', '') ?? '8492';
    final village = farmer?.village.isNotEmpty == true
        ? farmer!.village
        : 'Sardhar';
    final totalArea = farmer?.landAcres.isNotEmpty == true
        ? farmer!.landAcres
        : '5.5 Acres';
    final soil = farmer?.soilType.isNotEmpty == true
        ? farmer!.soilType
        : 'Medium Black (Kali Jameen)';
    final water = farmer?.waterSource.isNotEmpty == true
        ? farmer!.waterSource
        : 'Borewell + Drip System';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Land Records (7/12 & 8A)',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AnyRoR Verified',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildRecordRow('Khata No.', '$khata / $village'),
                _buildRecordRow('Survey / Block No.', '142 / Paiki 1'),
                _buildRecordRow('Total Area', totalArea),
                _buildRecordRow('Soil Classification', soil),
                _buildRecordRow('Irrigation Source', water),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildRecordRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(
        title: 'Farmer Profile',
        subtitle: 'Account & Farm Management',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: FarmerService.instance,
          builder: (context, _) {
            final farmer = FarmerService.instance.currentFarmer;
            final name = farmer?.displayName ?? AppConstants.farmerName;
            final initials = farmer?.initials ?? AppConstants.farmerInitials;
            final location =
                farmer?.displayLocation ?? AppConstants.farmerLocation;
            final farmerId = farmer?.id ?? AppConstants.farmerId;
            final landAcres = farmer?.landAcres ?? '5.5 Acres';

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDeep, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFA7F3D0),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initials,
                                style: AppTypography.headline.copyWith(
                                  color: AppColors.primaryDark,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          name,
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified,
                                        color: Color(0xFF6EE7B7),
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$location • ID: $farmerId',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Kisan Credit Card (KCC) Linked',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white70,
                                size: 22,
                              ),
                              tooltip: 'Edit Profile',
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/edit_profile'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(landAcres, 'Total Land'),
                              Container(
                                width: 1,
                                height: 28,
                                color: Colors.white24,
                              ),
                              _buildStatItem(
                                farmer?.currentCrop.isNotEmpty == true
                                    ? farmer!.currentCrop
                                    : 'Wheat, Cotton',
                                'Active Crops',
                              ),
                              Container(
                                width: 1,
                                height: 28,
                                color: Colors.white24,
                              ),
                              _buildStatItem('Plot A & B', 'Plots'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Farm Operations Section
                  Text(
                    'Farm Records & Operations',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildOptionTile(
                    icon: Icons.person_outline,
                    title: 'Edit Farmer Profile',
                    subtitle: 'Update name, mobile, address & soil type',
                    onTap: () => Navigator.pushNamed(context, '/edit_profile'),
                  ),
                  _buildOptionTile(
                    icon: Icons.assignment_outlined,
                    title: 'Land Records & 7/12 Documents',
                    subtitle: 'Khata #$farmerId, Survey #142',
                    onTap: () => _showLandRecordsDialog(context),
                  ),
                  _buildOptionTile(
                    icon: Icons.edit_note,
                    title: 'Edit Farm & Soil Profile',
                    subtitle: 'Update acres, soil type, irrigation',
                    onTap: () => Navigator.pushNamed(context, '/edit_farm'),
                  ),
                  _buildOptionTile(
                    icon: Icons.calendar_month_outlined,
                    title: 'Crop Calendar & Schedules',
                    subtitle: 'Irrigation, fertilizer dates',
                    onTap: () => Navigator.pushNamed(context, '/crop_calendar'),
                  ),
                  _buildOptionTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Farm Expenses & Accounts',
                    subtitle: 'Track seeds, fertilizer & labor costs',
                    onTap: () => Navigator.pushNamed(context, '/farm_expenses'),
                  ),
                  _buildOptionTile(
                    icon: Icons.agriculture_outlined,
                    title: 'Tractor & Machinery Rentals',
                    subtitle: 'Hire machinery near $location',
                    onTap: () => Navigator.pushNamed(context, '/tractor_hire'),
                  ),

                  const SizedBox(height: 22),

                  // App Settings & Support Section
                  Text(
                    'Settings & Kisan Support',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications & Alerts',
                    subtitle: 'Weather, Mandi rates, tasks',
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                  ),
                  _buildOptionTile(
                    icon: Icons.settings_outlined,
                    title: 'App Settings',
                    subtitle: 'Language, themes, offline mode',
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  _buildOptionTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Help Center & Kisan Helpline',
                    subtitle: 'Call 1800-180-1551, FAQs',
                    onTap: () => Navigator.pushNamed(context, '/help_center'),
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(
                        color: AppColors.errorRed,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.errorRed,
                      size: 20,
                    ),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                  const SizedBox(height: 18),

                  Center(
                    child: Text(
                      '${AppConstants.appName} v${AppConstants.appVersion} • Made with ❤️ for Indian Farmers',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 22),
          ),
          title: Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
