import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/services/expense_service.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class MyFarmScreen extends StatelessWidget {
  final Function(int)? onSwitchTab;

  const MyFarmScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(title: 'My Farm', showBackButton: true),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: FarmerService.instance,
          builder: (context, _) {
            final farmer = FarmerService.instance.currentFarmer;
            final locationText = farmer != null && farmer.village.isNotEmpty
                ? '${farmer.village}, ${farmer.district}'
                : 'Sardhar, Rajkot';
            final acres = farmer?.landAcres.isNotEmpty == true
                ? farmer!.landAcres
                : '5.5 Acres';
            final soil = farmer?.soilType.isNotEmpty == true
                ? farmer!.soilType
                : 'Black Soil';

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Farm Plot Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.flag_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vishvas Plot A',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$locationText |  $acres',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$soil |  Kharif Season 2026',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Current Crop Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFA7F3D0),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Crop: ${farmer?.currentCrop.isNotEmpty == true ? farmer!.currentCrop : "Cotton"}',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sowing Date: ${farmer?.sowingDate.isNotEmpty == true ? farmer!.sowingDate : "15 June 2026"}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Harvest Date: ${farmer?.harvestDate.isNotEmpty == true ? farmer!.harvestDate : "15 Oct 2026 (Day 45/120)"}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4 Action Buttons Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.edit_outlined,
                          label: farmer?.currentCrop.isNotEmpty == true
                              ? 'Edit Crop'
                              : 'Add Crop',
                          onTap: () =>
                              Navigator.pushNamed(context, '/edit_crop'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.edit_outlined,
                          label: 'Edit Farm',
                          onTap: () =>
                              Navigator.pushNamed(context, '/edit_farm'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.calendar_today_outlined,
                          label: 'View Calendar',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/calendar_timeline',
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ListenableBuilder(
                          listenable: ExpenseService.instance,
                          builder: (context, _) {
                            return _buildActionButton(
                              context,
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'View Expenses',
                              subtitle:
                                  ExpenseService.instance.totalExpenseFormatted,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/farm_expenses',
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Today's Farm Reminders
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFA7F3D0),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Farm Reminders :",
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Irrigation Plot A (5 PM) |   NPK Spray (Tomorrow)',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // AI Farm Insight Card
                  InkWell(
                    onTap: () {
                      if (onSwitchTab != null) {
                        onSwitchTab!(2);
                      } else {
                        Navigator.pushNamed(context, '/ai-chat');
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'AI Farm Insight',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '"Irrigation is recommended after 2 days"',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View Details',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF047857),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
