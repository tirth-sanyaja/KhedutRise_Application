import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class CalendarTimelineScreen extends StatelessWidget {
  const CalendarTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(title: 'Calendar'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Month Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'July 2026',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Calendar Days of Week
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                  return SizedBox(
                    width: 38,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Calendar Dates Grid
              _buildCalendarGrid(),
              const SizedBox(height: 28),

              // July Activity Timeline Header
              Text(
                'July Activity Timeline',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              // Activity Cards
              _buildTimelineCard(
                title: 'Sowing Complete',
                subtitle: 'Cotton Crop • 16 July 2026',
                dotColor: const Color(0xFFDCFCE7),
                isHighlighted: false,
              ),
              const SizedBox(height: 14),
              _buildTimelineCard(
                title: 'First Irrigation',
                subtitle: 'TOMORROW • 23 July (05:00 PM)',
                dotColor: const Color(0xFFFEF3C7),
                isHighlighted: true,
              ),
              const SizedBox(height: 14),
              _buildTimelineCard(
                title: 'NPK Fertilizer spray',
                subtitle: 'Scheduled • 29 July 2026',
                dotColor: const Color(0xFFE0E7FF),
                isHighlighted: false,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final rows = [
      ['28', '29', '30', '1', '2', '3', '4'],
      ['5', '6', '7', '8', '9', '10', '11'],
      ['12', '13', '14', '15', '16', '17', '18'],
      ['19', '20', '21', '22', '23', '24', '25'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: row.map((date) {
              final isCurrent = date == '20';
              final isDimmed = ['28', '29', '30'].contains(date);

              return Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    color: isCurrent
                        ? Colors.white
                        : isDimmed
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineCard({
    required String title,
    required String subtitle,
    required Color dotColor,
    required bool isHighlighted,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : AppColors.borderLight,
          width: isHighlighted ? 1.6 : 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
