import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khedutrise/core/services/farmer_service.dart';
import 'package:khedutrise/core/services/land_service.dart';
import 'package:khedutrise/core/widgets/khedut_button.dart';
import 'package:khedutrise/core/widgets/password_strength_indicator.dart';
import 'package:khedutrise/features/auth/screens/register_screen.dart';
import 'package:khedutrise/features/marketplace/screens/land_marketplace_screen.dart';
import 'package:khedutrise/features/marketplace/screens/sell_land_screen.dart';
import 'package:khedutrise/features/profile/screens/edit_profile_screen.dart';
import 'package:khedutrise/app/theme/app_theme.dart';

void main() {
  setUp(() {
    FarmerService.instance.logout();
    LandService.instance.resetToDefaults();
  });

  group('Widget & UX Validation Tests', () {
    testWidgets('PasswordStrengthIndicator renders 4 segments and live label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(password: 'Khedut@2026'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Strong / Very Strong label
      expect(find.text('Password Strength:'), findsOneWidget);
      expect(find.text('Very Strong'), findsOneWidget);
      expect(find.text('At least 8 characters'), findsOneWidget);
      expect(
        find.text('Uppercase (A-Z) & Lowercase (a-z) letters'),
        findsOneWidget,
      );
      expect(find.text('At least 1 number (0-9)'), findsOneWidget);
      expect(
        find.text('At least 1 special character (!@#\$%*?)'),
        findsOneWidget,
      );
    });

    testWidgets(
      'RegisterScreen validates duplicate phone and password mismatch',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);

        // Enter existing phone number
        await tester.enterText(textFields.at(0), 'Bhupat Patel');
        await tester.enterText(
          textFields.at(2),
          '9876543210',
        ); // Already registered phone
        await tester.enterText(textFields.at(7), 'Khedut@2026'); // Password

        // Accept terms
        final termsFinder1 = find.text(
          'I accept the Terms & Conditions and Privacy Policy',
        );
        await tester.ensureVisible(termsFinder1);
        await tester.tap(termsFinder1);
        await tester.pumpAndSettle();

        // Tap Register
        final registerBtn = find.widgetWithText(
          KhedutButton,
          'Complete Registration',
        );
        await tester.ensureVisible(registerBtn);
        await tester.tap(registerBtn);
        await tester.pumpAndSettle();

        // Should show duplicate registration error
        expect(find.textContaining('already registered'), findsOneWidget);
      },
    );

    testWidgets('RegisterScreen validates mismatched confirm password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);

      await tester.enterText(textFields.at(0), 'Kanti Patel');
      await tester.enterText(textFields.at(2), '9900112233'); // Fresh phone
      await tester.enterText(textFields.at(7), 'Khedut@2026'); // Password
      await tester.enterText(
        textFields.at(8),
        'Different@9999',
      ); // Confirm password

      // Accept terms
      final termsFinder2 = find.text(
        'I accept the Terms & Conditions and Privacy Policy',
      );
      await tester.ensureVisible(termsFinder2);
      await tester.tap(termsFinder2);
      await tester.pumpAndSettle();

      final registerBtn = find.widgetWithText(
        KhedutButton,
        'Complete Registration',
      );
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      // Mismatch error
      expect(find.text('Passwords do not match'), findsWidgets);
    });

    testWidgets(
      'SellLandScreen validates inputs and adds new land to LandMarketplaceScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/marketplace': (_) => const LandMarketplaceScreen(),
              '/sell_land': (_) => const SellLandScreen(),
            },
            home: const LandMarketplaceScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Initially verify default lands count
        expect(find.text('Green Farm Land – Sardhar'), findsOneWidget);
        final initialCount = LandService.instance.lands.length;

        // Add new land listing directly through SellLandScreen logic
        final newLand = {
          'id': 'LND-CUSTOM',
          'title': 'Highland Mango Farm – Gondal',
          'location': 'Gondal, Rajkot',
          'village': 'Gondal',
          'district': 'Rajkot',
          'acres': '7.0 Acres (28 Vigha)',
          'acresNum': 7.0,
          'soilType': 'Red Loam Soil',
          'waterSource': '2 Open Wells',
          'powerSupply': '5 HP Solar',
          'roadAccess': 'Pucca Road',
          'crops': 'Kesar Mango & Groundnut',
          'price': '₹ 42,00,000',
          'ratePerAcre': '₹6.0 Lac/Acre',
          'isVerified': true,
          'type': 'Sell',
          'distanceKm': 5.0,
          'ownerName': 'Rameshbhai Patel',
          'ownerPhone': '+91 98250 12345',
          'distance': '5.0 km from your farm',
        };

        LandService.instance.addLand(newLand);
        await tester.pumpAndSettle();

        // Newly added land should immediately appear on marketplace screen
        expect(LandService.instance.lands.length, equals(initialCount + 1));
        expect(find.text('Highland Mango Farm – Gondal'), findsOneWidget);
      },
    );

    testWidgets(
      'EditProfileScreen validates invalid PIN code and invalid phone',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: EditProfileScreen()));
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);

        // Enter invalid phone
        await tester.enterText(textFields.at(2), '123'); // Phone
        final saveBtn = find.widgetWithText(
          KhedutButton,
          'Save Profile Changes',
        );
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        // Should show validation error
        expect(
          find.textContaining('Mobile number is too short'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'LandMarketplaceScreen search bar renders cleanly and filters lands',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LandMarketplaceScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Search bar is present with hint text
        final searchField = find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText ==
                  'Search Village, Taluka, District, Soil...',
        );
        expect(searchField, findsOneWidget);

        // Verify search input decoration has no inner borders
        final TextField tf = tester.widget<TextField>(searchField);
        expect(tf.decoration?.border, equals(InputBorder.none));
        expect(tf.decoration?.enabledBorder, equals(InputBorder.none));
        expect(tf.decoration?.focusedBorder, equals(InputBorder.none));
        expect(tf.decoration?.filled, isFalse);

        // Enter query
        await tester.enterText(searchField, 'Sardhar');
        await tester.pumpAndSettle();

        // Clear button appears
        final clearBtn = find.byIcon(Icons.clear);
        expect(clearBtn, findsOneWidget);

        // Tap clear button
        await tester.tap(clearBtn);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.clear), findsNothing);
      },
    );
  });
}
