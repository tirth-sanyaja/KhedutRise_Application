import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/khedut_app_bar.dart';
import '../../../core/widgets/khedut_button.dart';
import '../../../resources/resources.dart';

class SelectPhotoScreen extends StatefulWidget {
  const SelectPhotoScreen({super.key});

  @override
  State<SelectPhotoScreen> createState() => _SelectPhotoScreenState();
}

class _SelectPhotoScreenState extends State<SelectPhotoScreen> {
  int _selectedTabIndex = 0;
  int _selectedPhotoIndex = 0;

  final List<Color> _tileColors = [
    const Color(0xFFE8F5E9),
    const Color(0xFFFFF3E0),
    const Color(0xFFF1F5F9),
    const Color(0xFFF3E8FF),
    const Color(0xFFEDE9FE),
    const Color(0xFFF8FAFC),
  ];

  void _onUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo uploaded! Diagnosing leaf health with AI...'),
        backgroundColor: AppColors.primary,
      ),
    );
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/crop_advisor');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(title: 'Select Photo'),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs: Recent Photos / Albums
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Column(
                        children: [
                          Text(
                            'Recent Photos',
                            style: AppTypography.titleSmall.copyWith(
                              color: _selectedTabIndex == 0
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 3,
                            color: _selectedTabIndex == 0
                                ? AppColors.primaryDark
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Column(
                        children: [
                          Text(
                            'Albums',
                            style: AppTypography.titleSmall.copyWith(
                              color: _selectedTabIndex == 1
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 3,
                            color: _selectedTabIndex == 1
                                ? AppColors.primaryDark
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Photos Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  itemCount: 6,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedPhotoIndex == index;
                    final samplePath =
                        AppImages.leafScanGallerySamples[index %
                            AppImages.leafScanGallerySamples.length];
                    return InkWell(
                      onTap: () => setState(() => _selectedPhotoIndex = index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: _tileColors[index % _tileColors.length],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderLight,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              samplePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 38,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Upload Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: KhedutButton(
                text: 'Upload Selected Photo',
                onPressed: _onUpload,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
