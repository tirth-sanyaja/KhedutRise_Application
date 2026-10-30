import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/config/ai_config.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/widgets/gemini_api_key_dialog.dart';
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
    AiConfig.instance.addListener(_onAiConfigUpdate);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Auto-launch camera when user arrives on this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_capturedImageBytes == null && _capturedImagePath == null) {
        _captureFromCamera();
      }
    });
  }

  void _onAiConfigUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AiConfig.instance.removeListener(_onAiConfigUpdate);
    _animController.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
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
        // Automatically start AI diagnosis once photo is captured
        _runAnalysis();
      }
    } catch (e) {
      debugPrint('Camera capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e. You can also pick from gallery.'),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Gallery',
              textColor: Colors.white,
              onPressed: _pickFromGallery,
            ),
          ),
        );
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
        _runAnalysis();
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  Future<void> _analyzeSample(String assetPath) async {
    setState(() => _isAnalyzing = true);
    final result = await AiService.instance.detectCropDisease(
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

    final result = await AiService.instance.detectCropDisease(
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
        actions: [
          IconButton(
            icon: Icon(
              AiConfig.instance.isConfigured ? Icons.psychology : Icons.vpn_key_outlined,
              color: AiConfig.instance.isConfigured ? const Color(0xFF86EFAC) : Colors.amber,
            ),
            tooltip: 'Gemini AI Setup',
            onPressed: () => GeminiApiKeyDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // AI Mode Strip
            InkWell(
              onTap: () => GeminiApiKeyDialog.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                color: AiConfig.instance.isConfigured
                    ? const Color(0xFF14532D)
                    : const Color(0xFF78350F),
                child: Row(
                  children: [
                    Icon(
                      AiConfig.instance.isConfigured ? Icons.check_circle : Icons.tune,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AiConfig.instance.isConfigured
                            ? 'Gemini 1.5 Vision Live AI Active (₹0)'
                            : 'Offline Diagnostic Engine (Tap to activate Live Gemini AI)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AiConfig.instance.isConfigured ? 'Active' : 'Setup Key',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                            : Center(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(22),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primaryLight,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 56,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        'Capture Crop Leaf Photo',
                                        style: AppTypography.titleMedium.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'રોગિષ્ટ પાનનો કેમેરાથી ફોટો પાડો અથવા ગેલેરીમાંથી પસંદ કરો',
                                        textAlign: TextAlign.center,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton.icon(
                                        onPressed: _captureFromCamera,
                                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                                        label: const Text(
                                          'Open Camera / કેમેરા ખોલો',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton.icon(
                                        onPressed: _pickFromGallery,
                                        icon: const Icon(Icons.photo_library, color: Colors.white70),
                                        label: const Text(
                                          'Choose from Gallery / ગેલેરી',
                                          style: TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.white30),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _showSamplePickerNotice,
                                        child: const Text(
                                          'Try with Sample Leaf / નમૂના પાંદડું',
                                          style: TextStyle(
                                            color: AppColors.primaryLight,
                                            fontSize: 13,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
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
