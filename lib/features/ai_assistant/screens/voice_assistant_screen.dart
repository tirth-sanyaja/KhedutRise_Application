import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(title: 'Voice Assistant'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // Mic Icon
              Icon(Icons.mic_none, size: 90, color: AppColors.primaryDark),
              const SizedBox(height: 50),

              // Sound Waveform Bars
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final heights = [24, 38, 48, 30, 60, 42, 28, 45, 34, 22];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(heights.length, (i) {
                      final factor = (_animController.value + (i * 0.1)) % 1.0;
                      final h = (heights[i] * (0.6 + 0.5 * factor)).clamp(
                        15.0,
                        65.0,
                      );
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 7,
                        height: h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 36),

              // Title
              Text(
                'Listening...',
                style: AppTypography.headline.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Speak now to ask AI about crop disease,\nirrigation calendar or tractor booking',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),

              // Stop Recording Button
              SizedBox(
                width: 220,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 1.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    'Stop Recording',
                    style: AppTypography.titleSmall.copyWith(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
