import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/theme/app_theme.dart';

// Auth
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/otp_verification_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';

// Home
import 'features/home/screens/main_screen.dart';

// My Farm
import 'features/my_farm/screens/my_farm_screen.dart';
import 'features/my_farm/screens/add_crop_screen.dart';
import 'features/my_farm/screens/edit_farm_screen.dart';
import 'features/my_farm/screens/calendar_timeline_screen.dart';
import 'features/my_farm/screens/farm_expenses_screen.dart';

// AI Assistant
import 'features/ai_assistant/screens/ai_chat_screen.dart';
import 'features/ai_assistant/screens/voice_assistant_screen.dart';
import 'features/ai_assistant/screens/scan_leaf_screen.dart';
import 'features/ai_assistant/screens/select_photo_screen.dart';
import 'features/ai_assistant/screens/smart_crop_advisor_screen.dart';
import 'features/ai_assistant/screens/smart_crop_calendar_screen.dart';

// Marketplace
import 'features/marketplace/screens/land_marketplace_screen.dart';
import 'features/marketplace/screens/sell_land_screen.dart';
import 'features/marketplace/screens/land_detail_screen.dart';
import 'features/marketplace/screens/farmland_map_screen.dart';

// Services
import 'features/services/screens/tractor_hire_screen.dart';
import 'features/services/screens/machinery_detail_screen.dart';
import 'core/models/machinery_model.dart';
import 'core/services/machinery_service.dart';

// Notifications
import 'features/notifications/screens/notifications_screen.dart';

// Profile
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/settings_screen.dart';
import 'features/profile/screens/help_center_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const KhedutRiseApp());
}

class KhedutRiseApp extends StatelessWidget {
  const KhedutRiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KhedutRise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        if (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS)) {
          return child ?? const SizedBox.shrink();
        }
        final windowSize = MediaQuery.sizeOf(context);
        if (windowSize.width <= 500) return child ?? const SizedBox.shrink();
        return _MobileEmulatorFrame(child: child ?? const SizedBox.shrink());
      },
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/otp': (_) => const OtpVerificationScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/forgot_password': (_) => const ForgotPasswordScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/reset_password': (_) => const ResetPasswordScreen(),
        '/edit-profile': (_) => const EditProfileScreen(),
        '/edit_profile': (_) => const EditProfileScreen(),
        '/home': (_) => const MainScreen(initialIndex: 0),
        '/main': (_) => const MainScreen(initialIndex: 0),
        '/my-farm': (_) => const MyFarmScreen(),
        '/my_farm': (_) => const MyFarmScreen(),
        '/add-crop': (_) => const AddCropScreen(),
        '/add_crop': (_) => const AddCropScreen(),
        '/edit-crop': (_) => const AddCropScreen(isEdit: true),
        '/edit_crop': (_) => const AddCropScreen(isEdit: true),
        '/edit-farm': (_) => const EditFarmScreen(),
        '/edit_farm': (_) => const EditFarmScreen(),
        '/calendar': (_) => const CalendarTimelineScreen(),
        '/calendar_timeline': (_) => const CalendarTimelineScreen(),
        '/expenses': (_) => const FarmExpensesScreen(),
        '/farm-expenses': (_) => const FarmExpensesScreen(),
        '/farm_expenses': (_) => const FarmExpensesScreen(),
        '/ai-chat': (_) => const AiChatScreen(),
        '/ai_chat': (_) => const AiChatScreen(),
        '/voice-assistant': (_) => const VoiceAssistantScreen(),
        '/voice_assistant': (_) => const VoiceAssistantScreen(),
        '/scan-leaf': (_) => const ScanLeafScreen(),
        '/scan_leaf': (_) => const ScanLeafScreen(),
        '/select-photo': (_) => const SelectPhotoScreen(),
        '/select_photo': (_) => const SelectPhotoScreen(),
        '/smart-crop-advisor': (_) => const SmartCropAdvisorScreen(),
        '/crop_advisor': (_) => const SmartCropAdvisorScreen(),
        '/crop-calendar': (_) => const SmartCropCalendarScreen(),
        '/crop_calendar': (_) => const SmartCropCalendarScreen(),
        '/land-marketplace': (_) => const LandMarketplaceScreen(),
        '/land_marketplace': (_) => const LandMarketplaceScreen(),
        '/sell-land': (_) => const SellLandScreen(),
        '/sell_land': (_) => const SellLandScreen(),
        '/land-detail': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return LandDetailScreen(landData: args);
        },
        '/land_details': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return LandDetailScreen(landData: args);
        },
        '/farmland-map': (_) => const FarmlandMapScreen(),
        '/farmland_maps': (_) => const FarmlandMapScreen(),
        '/tractor-hire': (_) => const TractorHireScreen(),
        '/tractor_hire': (_) => const TractorHireScreen(),
        '/machinery-detail': (context) {
          final item =
              ModalRoute.of(context)?.settings.arguments as MachineryItem? ??
              MachineryService.instance.machineries.first;
          return MachineryDetailScreen(machinery: item);
        },
        '/machinery_detail': (context) {
          final item =
              ModalRoute.of(context)?.settings.arguments as MachineryItem? ??
              MachineryService.instance.machineries.first;
          return MachineryDetailScreen(machinery: item);
        },
        '/notifications': (_) => const NotificationsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/help-center': (_) => const HelpCenterScreen(),
        '/help_center': (_) => const HelpCenterScreen(),
      },
    );
  }
}

class _MobileEmulatorFrame extends StatelessWidget {
  final Widget child;

  const _MobileEmulatorFrame({required this.child});

  static const double _screenWidth = 390.0;
  static const double _screenHeight = 804.0;
  static const double _statusBarHeight = 28.0;
  static const double _navBarHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    final parentMedia = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF141920),
      body: Stack(
        children: [
          // Subtle studio ambient glow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    const Color(0xFF2E7D32).withValues(alpha: 0.16),
                    const Color(0xFF141920),
                  ],
                ),
              ),
            ),
          ),
          // Centered scaled mobile emulator frame
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Phone Chassis + Screen
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Right-side hardware buttons (Power + Volume)
                        Positioned(
                          right: -5,
                          top: 160,
                          child: Container(
                            width: 5,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3A4149),
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -5,
                          top: 230,
                          child: Container(
                            width: 5,
                            height: 92,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3A4149),
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        // Outer Phone Body Bezel
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C2026),
                            borderRadius: BorderRadius.circular(48),
                            border: Border.all(
                              color: const Color(0xFF3E4652),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.65),
                                blurRadius: 40,
                                spreadRadius: 4,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(37),
                            child: Container(
                              width: _screenWidth,
                              height:
                                  _screenHeight +
                                  _statusBarHeight +
                                  _navBarHeight,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  // Top Mobile Status Bar + Camera Punch-Hole
                                  Container(
                                    height: _statusBarHeight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    color: const Color(0xFF1B5E20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          '9:41',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        // Punch-hole front camera
                                        Container(
                                          width: 11,
                                          height: 11,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0D1014),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF2C323B),
                                              width: 1.2,
                                            ),
                                          ),
                                        ),
                                        const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.signal_cellular_alt_rounded,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.wifi_rounded,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.battery_full_rounded,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Main App Screen Viewport (390 x 804)
                                  SizedBox(
                                    width: _screenWidth,
                                    height: _screenHeight,
                                    child: MediaQuery(
                                      data: parentMedia.copyWith(
                                        size: const Size(
                                          _screenWidth,
                                          _screenHeight,
                                        ),
                                        padding: EdgeInsets.zero,
                                        viewPadding: EdgeInsets.zero,
                                      ),
                                      child: child,
                                    ),
                                  ),
                                  // Bottom Android Gesture Navigation Bar
                                  Container(
                                    width: _screenWidth,
                                    height: _navBarHeight,
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 128,
                                      height: 4.5,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.35,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
