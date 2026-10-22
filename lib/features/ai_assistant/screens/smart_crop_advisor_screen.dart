import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/khedut_app_bar.dart';
import '../../../core/widgets/khedut_button.dart';

class SmartCropAdvisorScreen extends StatefulWidget {
  const SmartCropAdvisorScreen({super.key});

  @override
  State<SmartCropAdvisorScreen> createState() => _SmartCropAdvisorScreenState();
}

class _SmartCropAdvisorScreenState extends State<SmartCropAdvisorScreen> {
  final _soilController = TextEditingController(text: 'Black Soil');
  final _seasonController = TextEditingController(text: 'Monsoon');
  final _waterController = TextEditingController(text: 'High Water');
  final _areaController = TextEditingController(text: '5.5 Acres');

  bool _isGenerating = false;

  void _onGenerate() {
    setState(() => _isGenerating = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI Recommendation Generated for your Farm!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _soilController.dispose();
    _seasonController.dispose();
    _waterController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(title: 'AI Crop Recommendation'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Green Top Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primaryDeep,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Crop Advisor',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Answer questions & get AI's most profitable crop.",
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Farm Information Header
              Text(
                'Farm Information :',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              // Form fields in container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFA7F3D0),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInput('SOIL TYPE', _soilController),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInput('SEASON', _seasonController),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _buildInput('WATER', _waterController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInput('AREA', _areaController)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Generate Button
              KhedutButton(
                text: _isGenerating
                    ? 'Analyzing with AI...'
                    : 'Generate AI Recommendation',
                onPressed: _isGenerating ? null : _onGenerate,
              ),
              const SizedBox(height: 24),

              // Recommendation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 1.6),
                ),
                child: Column(
                  children: [
                    Text(
                      'Recommended Crop: Cotton',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCol('Expected Yield', '15 Quintal / Acre'),
                        _buildStatCol('Expected Profit', '₹75,000 / Acre'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCol('Duration', '120 Days'),
                        _buildStatCol('Market Demand', 'High Demand'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'AI Analysis based on soil parameters & market trend algorithms.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Bottom highlights
              Center(
                child: Text(
                  '✓ Black Soil Match  |  ✓ High Market Price',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.primaryDark,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderInput),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
