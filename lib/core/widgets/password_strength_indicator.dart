import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../validation/app_validators.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showRequirements;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showRequirements = true,
  });

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return const Color(0xFFEF4444); // Red
      case PasswordStrength.fair:
        return const Color(0xFFF59E0B); // Amber / Orange
      case PasswordStrength.strong:
        return const Color(0xFF10B981); // Emerald / Light Green
      case PasswordStrength.veryStrong:
        return const Color(0xFF047857); // Deep Green
      case PasswordStrength.none:
        return const Color(0xFF94A3B8); // Slate grey
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final result = AppValidators.calculatePasswordStrength(password);
    final activeColor = _getStrengthColor(result.strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Live strength label and meter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength:',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: activeColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                result.label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: activeColor,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 4 segmented bars
        Row(
          children: List.generate(4, (index) {
            final isFilled = index < result.score;
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: index < 3 ? 6.0 : 0.0),
                decoration: BoxDecoration(
                  color: isFilled ? activeColor : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),

        // Requirements list
        if (showRequirements) ...[
          const SizedBox(height: 12),
          _RequirementRow(
            label: 'At least 8 characters',
            isMet: result.hasMinLength,
          ),
          const SizedBox(height: 4),
          _RequirementRow(
            label: 'Uppercase (A-Z) & Lowercase (a-z) letters',
            isMet: result.hasUppercase && result.hasLowercase,
          ),
          const SizedBox(height: 4),
          _RequirementRow(
            label: 'At least 1 number (0-9)',
            isMet: result.hasDigit,
          ),
          const SizedBox(height: 4),
          _RequirementRow(
            label: 'At least 1 special character (!@#\$%*?)',
            isMet: result.hasSpecialChar,
          ),
        ],
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool isMet;

  const _RequirementRow({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 14,
          color: isMet ? const Color(0xFF10B981) : AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 11,
            color: isMet ? AppColors.textPrimary : AppColors.textTertiary,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
