import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/crop_disease_model.dart';
import '../../../core/widgets/khedut_button.dart';

/// Bottom sheet displaying detailed AI plant pathology results
class CropDiseaseResultSheet extends StatelessWidget {
  final CropDiseaseResult result;
  final VoidCallback onRetake;

  const CropDiseaseResultSheet({
    super.key,
    required this.result,
    required this.onRetake,
  });

  static void show(
    BuildContext context, {
    required CropDiseaseResult result,
    required VoidCallback onRetake,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CropDiseaseResultSheet(
        result: result,
        onRetake: onRetake,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: result.isClearImage
                            ? (result.isHealthy
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFEF3C7))
                            : const Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        result.isClearImage
                            ? (result.isHealthy ? Icons.eco : Icons.bug_report)
                            : Icons.warning_amber_rounded,
                        color: result.isClearImage
                            ? (result.isHealthy
                                ? AppColors.primary
                                : Colors.amber.shade800)
                            : Colors.red.shade700,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'AI Diagnostic Report',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Real AI vs Demo Data Badge (Rule 10 Compliance)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: result.isDemoData ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: result.isDemoData ? const Color(0xFFFDE68A) : const Color(0xFF86EFAC),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        result.isDemoData ? Icons.science_outlined : Icons.verified,
                        size: 16,
                        color: result.isDemoData ? Colors.amber.shade900 : AppColors.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result.isDemoData
                              ? 'OFFLINE DEMO DATA (Rule 10: Non-AI Baseline)'
                              : 'LIVE AI DIAGNOSIS (Gemini 1.5 Flash - Free Tier ₹0)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: result.isDemoData ? Colors.amber.shade900 : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Unclear image banner
                if (!result.isClearImage) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFDC2626),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Clear Photo Required',
                              style: AppTypography.titleSmall.copyWith(
                                color: const Color(0xFFDC2626),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.clarityFeedback,
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF7F1D1D),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Crop & Disease Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: result.isHealthy
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: result.isHealthy
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDeep,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                result.cropName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.borderLight,
                              ),
                            ),
                            child: Text(
                              'Confidence: ${result.confidence}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: result.confidence.toLowerCase().contains('high')
                                    ? AppColors.primaryDark
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        result.diseaseName,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: result.isHealthy
                              ? AppColors.primaryDark
                              : const Color(0xFF92400E),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Symptoms
                if (result.symptoms.isNotEmpty) ...[
                  _buildSectionTitle(Icons.visibility, 'Visible Symptoms'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: result.symptoms
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      s,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textPrimary,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Immediate Steps
                if (result.immediateSteps.isNotEmpty) ...[
                  _buildSectionTitle(
                    Icons.flash_on,
                    'Immediate Action (24-48 Hours)',
                  ),
                  const SizedBox(height: 8),
                  _buildCardText(result.immediateSteps, const Color(0xFFEFF6FF)),
                  const SizedBox(height: 16),
                ],

                // Organic Treatment
                if (result.organicTreatment.isNotEmpty) ...[
                  _buildSectionTitle(Icons.eco, 'Organic & Biological Control'),
                  const SizedBox(height: 8),
                  _buildCardText(
                    result.organicTreatment,
                    const Color(0xFFF0FDF4),
                  ),
                  const SizedBox(height: 16),
                ],

                // Chemical Treatment
                if (result.chemicalTreatment.isNotEmpty) ...[
                  _buildSectionTitle(
                    Icons.science,
                    'Chemical Treatment (With Label Guidance)',
                  ),
                  const SizedBox(height: 8),
                  _buildCardText(
                    '${result.chemicalTreatment}\n\n*Statutory Note: Always adhere strictly to package label instructions for dosage, dilution, and harvesting intervals.*',
                    const Color(0xFFFEF3C7),
                  ),
                  const SizedBox(height: 16),
                ],

                // Prevention Guidance
                if (result.preventionGuidance.isNotEmpty) ...[
                  _buildSectionTitle(
                    Icons.shield_outlined,
                    'Prevention & Farm Sanitation',
                  ),
                  const SizedBox(height: 8),
                  _buildCardText(
                    result.preventionGuidance,
                    const Color(0xFFF8FAFC),
                  ),
                  const SizedBox(height: 16),
                ],

                // KVK Expert Consultation
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.support_agent,
                        color: AppColors.primaryDark,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          result.expertConsultation,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onRetake();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Retake / Scan Another',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KhedutButton(
                        text: 'Ask AI Assistant',
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed('/ai_chat');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryDark),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCardText(String text, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }
}
