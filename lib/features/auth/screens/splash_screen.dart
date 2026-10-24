import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../resources/resources.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Responsive Logo Emblem
                  Builder(
                    builder: (context) {
                      final logoSize = (size.width * 0.44).clamp(160.0, 220.0);
                      return Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppImages.appLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildFallbackLogo(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Title: KhedutRise
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Khedut',
                          style: AppTypography.display.copyWith(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Rise',
                          style: AppTypography.display.copyWith(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF208B28),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    'Welcome To KhedutRise...',
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Loading text
                  Text(
                    'Loading...',
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom illustration (hills with sun, palm trees and version)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              width: size.width,
              height: size.height * 0.40,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AppImages.hillsLandscape,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (_, _, _) => _buildFallbackLandscape(),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    child: Text(
                      'Version ${AppConstants.appVersion}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 4),
        color: AppColors.primaryLight,
      ),
      child: const Icon(Icons.agriculture, size: 80, color: AppColors.primary),
    );
  }

  Widget _buildFallbackLandscape() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(80),
          topRight: Radius.circular(80),
        ),
      ),
    );
  }
}
