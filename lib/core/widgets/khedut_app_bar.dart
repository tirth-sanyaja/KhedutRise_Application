import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../services/farmer_service.dart';

class KhedutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool isDarkGreen;
  final List<Widget>? actions;

  const KhedutAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBack,
    this.onNotificationTap,
    this.onProfileTap,
    this.isDarkGreen = false,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 70 : 60);

  @override
  Widget build(BuildContext context) {
    final canGoBack = showBackButton && Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: isDarkGreen ? AppColors.primaryDeep : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: canGoBack
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDarkGreen ? Colors.white : AppColors.textPrimary,
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: isDarkGreen ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: isDarkGreen ? Colors.white70 : AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
      centerTitle: true,
      actions:
          actions ??
          [
            IconButton(
              icon: Stack(
                children: [
                  Icon(
                    Icons.notifications,
                    color: isDarkGreen ? Colors.white : AppColors.primaryDark,
                    size: 26,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed:
                  onNotificationTap ??
                  () => Navigator.pushNamed(context, '/notifications'),
            ),
            ListenableBuilder(
              listenable: FarmerService.instance,
              builder: (context, _) {
                final initials = FarmerService.instance.farmerInitials;
                return GestureDetector(
                  onTap:
                      onProfileTap ??
                      () => Navigator.pushNamed(context, '/profile'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16, left: 4),
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
    );
  }
}
