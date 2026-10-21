import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

enum KhedutButtonType { primary, outlined, danger, dangerOutlined }

class KhedutButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool showArrow;
  final IconData? prefixIcon;
  final KhedutButtonType type;
  final double? width;
  final double height;
  final double borderRadius;

  const KhedutButton({
    super.key,
    required this.text,
    this.onPressed,
    this.showArrow = true,
    this.prefixIcon,
    this.type = KhedutButtonType.primary,
    this.width,
    this.height = 52,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide borderSide;

    switch (type) {
      case KhedutButtonType.primary:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        borderSide = BorderSide.none;
        break;
      case KhedutButtonType.outlined:
        bgColor = Colors.white;
        textColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case KhedutButtonType.danger:
        bgColor = AppColors.errorRed;
        textColor = Colors.white;
        borderSide = BorderSide.none;
        break;
      case KhedutButtonType.dangerOutlined:
        bgColor = const Color(0xFFFEF2F2);
        textColor = AppColors.errorRed;
        borderSide = const BorderSide(color: AppColors.errorRed, width: 1.5);
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, color: textColor, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTypography.buttonText.copyWith(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: textColor, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
