import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/crop_disease_service.dart';
import '../../../resources/resources.dart';
import '../widgets/crop_disease_result_sheet.dart';

class ScanLeafScreen extends StatefulWidget {
  const ScanLeafScreen({super.key});

  @override
  State<ScanLeafScreen> createState() => _ScanLeafScreenState();
}

class _ScanLeafScreenState extends State<ScanLeafScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  String? _capturedImagePath;
  Uint8List? _capturedImageBytes;
  bool _flashOn = false;
  bool _isAnalyzing = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _capturedImagePath = photo.path;
          _capturedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Camera capture error: $e. Falling back to sample leaf.');
      if (mounted) {
        _showSamplePickerNotice();
      }
    }
  }

  void _showSamplePickerNotice() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Plant Foliage for AI Scan',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Camera hardware is unavailable in this environment. You can pick an image from your device gallery or choose a farm test leaf.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Pick from Device Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.orange),
              title: const Text('Test with Diseased Cotton Leaf Sample'),
              onTap: () {
                Navigator.pop(ctx);
                _analyzeSample(AppImages.diseasedLeafSample);
              },
            ),
            ListTile(
              leading: const Icon(Icons.eco, color: AppColors.primary),
              title: const Text('Test with Healthy Cotton Leaf Sample'),
              onTap: () {
                Navigator.pop(ctx);
                _analyzeSample(AppImages.healthyLeafSample);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
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
          _capturedImagePath = image.path;
          _capturedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  Future<void> _analyzeSample(String assetPath) async {
    setState(() => _isAnalyzing = true);
    final result = await CropDiseaseService.instance.analyzeImage(
      assetPath: assetPath,
    );
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    _showResult(result);
  }

  Future<void> _runAnalysis() async {
    if (_capturedImageBytes == null && _capturedImagePath == null) {
      // Trigger camera capture if nothing captured yet
      await _captureFromCamera();
      if (_capturedImageBytes == null && _capturedImagePath == null) return;
    }

    setState(() => _isAnalyzing = true);

    final result = await CropDiseaseService.instance.analyzeImage(
      filePath: _capturedImagePath,
      imageBytes: _capturedImageBytes,
    );

    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    _showResult(result);
  }

  void _showResult(dynamic result) {
    CropDiseaseResultSheet.show(
      context,
      result: result,
      onRetake: () {
        setState(() {
          _capturedImagePath = null;
          _capturedImageBytes = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Scan Crop Leaf',
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Viewfinder or Captured Preview
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFF0F172A),
                    child: _capturedImageBytes != null
                        ? Image.memory(
                            _capturedImageBytes!,
                            fit: BoxFit.cover,
                          )
                        : _capturedImagePath != null
                            ? Image.file(
                                File(_capturedImagePath!),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                AppImages.healthyLeafSample,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: const Color(0xFF1E293B),
                                  child: const Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 80,
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                              ),
                  ),

                  // Scanning animation overlay
                  if (_isAnalyzing)
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Positioned(
                          top: 100 + (_animController.value * 240),
                          left: 40,
                          right: 40,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.8),
                                  blurRadius: 16,
                                  spreadRadius: 4,
                                ),
                              ],
                              color: AppColors.primaryLight,
                            ),
                          ),
                        );
                      },
                    ),

                  // 4 Corner Brackets Reticle
                  if (!_isAnalyzing)
                    SizedBox(
                      width: 260,
                      height: 280,
                      child: Stack(
                        children: [
                          // Top-left
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white, width: 4),
                                  left: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                          // Top-right
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white, width: 4),
                                  right: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                          // Bottom-left
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.white, width: 4),
                                  left: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                          // Bottom-right
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.white, width: 4),
                                  right: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Instruction pill or Scanning Status
                  Positioned(
                    bottom: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _isAnalyzing
                              ? AppColors.primary
                              : Colors.white24,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isAnalyzing) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'AI diagnosing crop leaf pathology...',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else if (_capturedImageBytes != null ||
                              _capturedImagePath != null) ...[
                            Text(
                              'Photo captured! Tap shutter to diagnose',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Align affected leaf inside the box to scan',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom camera controls
            Container(
              height: 120,
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gallery button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/select_photo'),
                  ),

                  // Shutter / Analyze button
                  GestureDetector(
                    onTap: _isAnalyzing ? null : _runAnalysis,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isAnalyzing
                              ? AppColors.primary
                              : Colors.white,
                          width: 4,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _isAnalyzing
                              ? AppColors.primary
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: _capturedImageBytes != null ||
                                _capturedImagePath != null
                            ? const Icon(
                                Icons.search,
                                color: AppColors.primaryDark,
                                size: 32,
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Retake or Flash button
                  if (_capturedImageBytes != null || _capturedImagePath != null)
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _capturedImagePath = null;
                          _capturedImageBytes = null;
                        });
                      },
                    )
                  else
                    IconButton(
                      icon: Icon(
                        _flashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _flashOn = !_flashOn;
                        });
                      },
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
