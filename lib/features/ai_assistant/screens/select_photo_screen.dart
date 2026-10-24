import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/widgets/khedut_app_bar.dart';
import '../../../core/widgets/khedut_button.dart';
import '../../../resources/resources.dart';
import '../widgets/crop_disease_result_sheet.dart';

class SelectPhotoScreen extends StatefulWidget {
  const SelectPhotoScreen({super.key});

  @override
  State<SelectPhotoScreen> createState() => _SelectPhotoScreenState();
}

class _SelectPhotoScreenState extends State<SelectPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  int _selectedTabIndex = 0;
  int _selectedPhotoIndex = 0;
  String? _customGalleryPath;
  Uint8List? _customGalleryBytes;
  bool _isAnalyzing = false;

  final List<Color> _tileColors = [
    const Color(0xFFE8F5E9),
    const Color(0xFFFFF3E0),
    const Color(0xFFF1F5F9),
    const Color(0xFFF3E8FF),
    const Color(0xFFEDE9FE),
    const Color(0xFFF8FAFC),
  ];

  Future<void> _pickFromDeviceGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _customGalleryPath = image.path;
          _customGalleryBytes = bytes;
          _selectedPhotoIndex = -1; // Deselect sample photos
        });
      }
    } catch (e) {
      debugPrint('Device gallery pick error: $e');
    }
  }

  Future<void> _onUploadAndDiagnose() async {
    setState(() => _isAnalyzing = true);

    try {
      dynamic result;
      if (_customGalleryBytes != null || _customGalleryPath != null) {
        result = await AiService.instance.detectCropDisease(
          filePath: _customGalleryPath,
          imageBytes: _customGalleryBytes,
        );
      } else {
        final samplePath = AppImages.leafScanGallerySamples[
            _selectedPhotoIndex % AppImages.leafScanGallerySamples.length];
        result = await AiService.instance.detectCropDisease(
          assetPath: samplePath,
        );
      }

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      CropDiseaseResultSheet.show(
        context,
        result: result,
        onRetake: () {
          setState(() {
            _customGalleryPath = null;
            _customGalleryBytes = null;
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(title: 'Select Leaf Photo'),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs: Sample Photos / Device Gallery
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
                            'Sample Crops',
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
                      onTap: () {
                        setState(() => _selectedTabIndex = 1);
                        _pickFromDeviceGallery();
                      },
                      child: Column(
                        children: [
                          Text(
                            'Device Gallery',
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
            const SizedBox(height: 8),

            // Pick Custom File Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: _pickFromDeviceGallery,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customGalleryBytes != null
                                  ? 'Custom Photo Selected'
                                  : 'Pick from your Phone Gallery',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              _customGalleryBytes != null
                                  ? 'Tap to change photo'
                                  : 'Select high-resolution photo from storage',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

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
                      onTap: () {
                        setState(() {
                          _selectedPhotoIndex = index;
                          _customGalleryPath = null;
                          _customGalleryBytes = null;
                        });
                      },
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

            // Upload / Diagnose Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: KhedutButton(
                text: _isAnalyzing
                    ? 'AI Pathology Inspection in Progress...'
                    : 'Analyze Selected Photo with AI',
                onPressed: _isAnalyzing ? null : _onUploadAndDiagnose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
