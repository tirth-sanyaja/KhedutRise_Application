import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khedutrise/core/constants/app_constants.dart';
import 'package:khedutrise/core/models/farmer_model.dart';
import 'package:khedutrise/core/services/farmer_service.dart';
import 'package:khedutrise/core/widgets/khedut_button.dart';
import 'package:khedutrise/features/auth/screens/forgot_password_screen.dart';
import 'package:khedutrise/features/auth/screens/login_screen.dart';
import 'package:khedutrise/features/auth/screens/otp_verification_screen.dart';
import 'package:khedutrise/features/auth/screens/register_screen.dart';
import 'package:khedutrise/features/auth/screens/reset_password_screen.dart';
import 'package:khedutrise/features/auth/screens/splash_screen.dart';
import 'package:khedutrise/features/home/screens/home_screen.dart';
import 'package:khedutrise/features/home/screens/main_screen.dart';
import 'package:khedutrise/features/profile/screens/profile_screen.dart';
import 'package:khedutrise/core/services/expense_service.dart';
import 'package:khedutrise/features/services/screens/tractor_hire_screen.dart';
import 'package:khedutrise/features/my_farm/screens/edit_farm_screen.dart';
import 'package:khedutrise/features/my_farm/screens/my_farm_screen.dart';
import 'package:khedutrise/features/my_farm/screens/farm_expenses_screen.dart';
import 'package:khedutrise/features/ai_assistant/screens/smart_crop_calendar_screen.dart';
import 'package:khedutrise/core/services/machinery_service.dart';
import 'package:khedutrise/features/profile/screens/help_center_screen.dart';
import 'package:khedutrise/features/services/screens/machinery_detail_screen.dart';
import 'package:khedutrise/main.dart';

void main() {
  setUp(() {
    FarmerService.instance.logout();
    ExpenseService.instance.resetToDefaults();
  });

  testWidgets('1. Splash screen displays version text exactly once', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // Should find 'Version 1.0.0' text exactly once in the widget tree
    final versionFinder = find.text('Version ${AppConstants.appVersion}');
    expect(versionFinder, findsOneWidget);
  });

  testWidgets('2. Registration, dynamic farmer name and initials flow', (
    WidgetTester tester,
  ) async {
    const testFarmer = FarmerModel(
      id: '#9999',
      name: 'Ramesh Patel',
      fatherName: 'Mohanbhai',
      phone: '+91 9988776655',
      village: 'Sardhar',
      district: 'Rajkot',
      landAcres: '6.0 Acres',
      soilType: 'Black Soil',
    );

    // Initial state: not authenticated
    expect(FarmerService.instance.isAuthenticated, isFalse);

    // Register farmer
    FarmerService.instance.register(testFarmer);
    expect(FarmerService.instance.isAuthenticated, isTrue);
    expect(FarmerService.instance.farmerName, 'Ramesh Patel');
    expect(FarmerService.instance.farmerInitials, 'RP');

    // Pump MainScreen
    await tester.pumpWidget(
      const MaterialApp(home: MainScreen(initialIndex: 0)),
    );
    await tester.pumpAndSettle();

    // Top-left must show 'Ramesh Patel'
    expect(find.text('Ramesh Patel'), findsOneWidget);
    // Initials in avatar must show 'RP'
    expect(find.text('RP'), findsOneWidget);
  });

  testWidgets(
    '3. Login Screen does not have hardcoded user names and validates input',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Verify no hardcoded farmer name is present on login screen
      expect(find.text('Tirthbhai Sanyaja'), findsNothing);
      expect(find.text('Sanyaja Tirth Kalpeshbhai'), findsNothing);

      // Tap Login button with empty fields
      final loginBtn = find.widgetWithText(KhedutButton, 'Login');
      expect(loginBtn, findsOneWidget);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      // Shows validation error
      expect(
        find.text('Please enter your mobile number or email'),
        findsOneWidget,
      );
    },
  );

  testWidgets('4. Forgot Password Screen validates and accepts input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

    expect(find.text('Reset Your Password'), findsOneWidget);

    // Tap button with empty field
    await tester.tap(find.text('Send Verification Code'));
    await tester.pumpAndSettle();
    expect(
      find.text('Please enter your registered mobile number or email'),
      findsOneWidget,
    );

    // Enter phone
    await tester.enterText(find.byType(TextFormField), '+91 98765 43210');
    await tester.pumpAndSettle();

    expect(find.text('+91 98765 43210'), findsOneWidget);
  });

  testWidgets('5. Reset Password Screen validates matching passwords', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResetPasswordScreen(phoneNumber: '+91 98765 43210'),
      ),
    );

    // Tap without entering
    await tester.tap(find.text('Save New Password'));
    await tester.pumpAndSettle();
    expect(find.text('Please fill in both password fields'), findsOneWidget);

    // Enter non-matching passwords
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), '1234');
    await tester.enterText(textFields.at(1), '5678');
    await tester.tap(find.text('Save New Password'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets(
    '6. OTP Screen validates incomplete OTP and shows backspace icon',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OtpVerificationScreen())),
      );

      // Verify backspace icon is present
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

      // Verify tapping verify without entering OTP shows error
      final verifyBtn = find.text('Verify & Continue');
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pumpAndSettle();
      expect(find.text('Please enter all 4 digits of the OTP'), findsOneWidget);
    },
  );

  testWidgets(
    '7. Home Page Search Bar filters items, handles no-match and clear',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/my-farm': (_) => const Scaffold(body: Text('My Farm Page')),
            '/tractor_hire': (_) =>
                const Scaffold(body: Text('Tractor Hire Page')),
          },
          home: const HomeScreen(),
        ),
      );

      // Initially Quick Services is visible
      expect(find.text('Quick Services'), findsOneWidget);

      // Enter search query 'Wheat'
      final searchInput = find.byType(TextField);
      await tester.enterText(searchInput, 'Wheat');
      await tester.pumpAndSettle();

      // Results view should show Wheat
      expect(find.textContaining('Search Results'), findsOneWidget);
      expect(find.text('Wheat Crop (Gehun)'), findsOneWidget);

      // Enter query with no results
      await tester.enterText(searchInput, 'NonExistentItemXYZ');
      await tester.pumpAndSettle();
      expect(
        find.text('No results found for "NonExistentItemXYZ"'),
        findsOneWidget,
      );

      // Clear search
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(find.text('Quick Services'), findsOneWidget);
    },
  );

  testWidgets(
    '8. Profile Screen displays dynamic data and updates from Edit Profile',
    (WidgetTester tester) async {
      const farmer = FarmerModel(
        id: '#7777',
        name: 'Pravinbhai Vala',
        phone: '+91 97123 45678',
        village: 'Gondal',
        district: 'Rajkot',
        landAcres: '10 Acres',
        soilType: 'Alluvial Soil',
      );
      FarmerService.instance.register(farmer);

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pravinbhai Vala'), findsOneWidget);
      // Initials appear in AppBar avatar and Card header avatar
      expect(find.text('PV'), findsNWidgets(2));
      expect(find.text('10 Acres'), findsOneWidget);

      // Update profile
      FarmerService.instance.updateProfile(name: 'Kishorbhai Vala');
      await tester.pumpAndSettle();
      expect(find.text('Kishorbhai Vala'), findsOneWidget);
      expect(find.text('KV'), findsNWidgets(2));
    },
  );

  testWidgets('9. Tractor Hire page displays equipment and booking sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TractorHireScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Mahindra 575 DI XP Plus'), findsOneWidget);
    expect(find.text('John Deere 5050 D 4WD'), findsOneWidget);

    // Tap Book Now on first available tractor
    await tester.tap(find.text('Book Now').first);
    await tester.pumpAndSettle();

    // Booking sheet should open
    expect(find.text('Booking Date'), findsOneWidget);
    expect(find.text('Required Duration (Hours)'), findsOneWidget);
    expect(find.text('Confirm Booking'), findsOneWidget);
  });

  testWidgets('10. Responsive layout test on small device width (320px)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320 * 2, 700 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump();

    // Verify splash screen renders on 320px without overflow exception
    expect(tester.takeException(), isNull);
    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets(
    '11. Full End-to-End: Register -> OTP -> Home -> Profile with dynamic farmer data',
    (WidgetTester tester) async {
      await tester.pumpWidget(const KhedutRiseApp());
      await tester.pump(const Duration(seconds: 4)); // transition to login
      await tester.pumpAndSettle();

      // From Login tap Register
      final registerLink = find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Register'),
      );
      expect(registerLink, findsOneWidget);
      await tester.ensureVisible(registerLink);
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);

      // Enter registration fields
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Anandbhai Patel'); // Full name
      await tester.enterText(textFields.at(1), 'Kantibhai'); // Father name
      await tester.enterText(textFields.at(2), '9825511223'); // Phone
      await tester.enterText(textFields.at(3), 'XXXX-XXXX-9999'); // Aadhaar
      await tester.enterText(textFields.at(4), 'Gondal, Rajkot'); // Location
      await tester.enterText(textFields.at(7), '123456'); // Password

      // Accept terms
      final termsText = find.text(
        'I accept the Terms & Conditions and Privacy Policy',
      );
      await tester.ensureVisible(termsText);
      await tester.tap(termsText);
      await tester.pumpAndSettle();

      // Submit registration
      final registerBtn = find.widgetWithText(
        KhedutButton,
        'Complete Registration',
      );
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      // Now on OTP Screen
      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      expect(find.text('9825511223'), findsOneWidget);

      // Enter 4 digits on custom keypad: 1, 2, 3, 4
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();

      // Verify
      final verifyBtn = find.widgetWithText(KhedutButton, 'Verify & Continue');
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pumpAndSettle();

      // Should now be on MainScreen Home
      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.text('Anandbhai Patel'), findsOneWidget);
      expect(find.text('AP'), findsOneWidget);

      // Tap Profile avatar
      final avatar = find.text('AP');
      await tester.tap(avatar);
      await tester.pumpAndSettle();

      // Should see Anandbhai Patel in profile
      expect(find.text('Anandbhai Patel'), findsOneWidget);
      expect(find.text('AP'), findsNWidgets(2));
    },
  );

  testWidgets(
    '12. Tractor Hire booking flow with plot validation and confirmation dialog',
    (WidgetTester tester) async {
      final testFarmer = const FarmerModel(
        id: '#5555',
        name: 'Bhavesh Chudasama',
        phone: '+91 98980 11223',
        village: 'Sardhar',
      );
      FarmerService.instance.register(testFarmer);

      await tester.pumpWidget(const MaterialApp(home: TractorHireScreen()));
      await tester.pumpAndSettle();

      // Tap Book Now on first tractor
      await tester.tap(find.text('Book Now').first);
      await tester.pumpAndSettle();

      // Verify booking sheet opened
      expect(find.text('Confirm Booking'), findsOneWidget);

      // Tap Confirm Booking
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Confirm Booking');
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appeared
      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.textContaining('TR-'), findsWidgets);
      expect(find.text('Bhavesh Chudasama'), findsOneWidget);

      // Tap Done to close dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Booking Confirmed!'), findsNothing);
    },
  );

  testWidgets(
    '13. EditFarmScreen renders dropdowns with Sardhar location without assertion error',
    (WidgetTester tester) async {
      const testFarmer = FarmerModel(
        id: '#1001',
        name: 'Kisan Kumar',
        phone: '+91 9876543210',
        village: 'Sardhar',
        district: 'Rajkot',
        landAcres: '5.5 Acres',
        soilType: 'Black Soil',
      );
      FarmerService.instance.register(testFarmer);

      await tester.pumpWidget(const MaterialApp(home: EditFarmScreen()));
      await tester.pumpAndSettle();

      // Verify Edit Farm details header rendered
      expect(find.text('Edit Farm details'), findsOneWidget);
      // Verify Sardhar dropdown value is rendered
      expect(find.text('Sardhar, Rajkot, Gujarat'), findsOneWidget);
      expect(find.text('Black Soil'), findsOneWidget);
    },
  );

  testWidgets(
    '14. SmartCropCalendarScreen renders without overflow on narrow device',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(home: SmartCropCalendarScreen()),
      );
      await tester.pumpAndSettle();

      // Verify screen title and Cotton Crop header render cleanly
      expect(find.text('Smart Crop Calendar'), findsOneWidget);
      expect(find.text('Cotton Crop (Day 35/120) :'), findsOneWidget);
      expect(find.text('July 2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '15. Adding and deleting farm expenses dynamically updates the total banner',
    (WidgetTester tester) async {
      // Initial total is 4000 + 5500 + 3000 = 12500
      expect(ExpenseService.instance.totalExpense, 12500);
      expect(ExpenseService.instance.totalExpenseFormatted, '₹12,500');

      await tester.pumpWidget(const MaterialApp(home: FarmExpensesScreen()));
      await tester.pumpAndSettle();

      // Verify initial total banner shows ₹12,500
      expect(find.text('₹12,500'), findsOneWidget);

      // Add a new expense of ₹4,500
      ExpenseService.instance.addExpense(
        title: 'DAP Fertilizer (3 Bags)',
        category: 'Fertilizer',
        amount: 4500,
      );
      await tester.pumpAndSettle();

      // Total should now be 12500 + 4500 = 17000
      expect(ExpenseService.instance.totalExpense, 17000);
      expect(find.text('₹17,000'), findsOneWidget);
      expect(find.text('DAP Fertilizer (3 Bags)'), findsOneWidget);

      // Delete one expense
      final firstExpenseId = ExpenseService.instance.expenses.first.id;
      ExpenseService.instance.removeExpense(firstExpenseId);
      await tester.pumpAndSettle();

      // Total drops back to 12500
      expect(ExpenseService.instance.totalExpense, 12500);
      expect(find.text('₹12,500'), findsOneWidget);
    },
  );

  testWidgets(
    '16. Tractor booking section includes 4 newly added tractors with full specs',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TractorHireScreen()));
      await tester.pumpAndSettle();

      // Verify Sonalika via search
      await tester.enterText(find.byType(TextField), 'Sonalika');
      await tester.pumpAndSettle();
      expect(find.text('Sonalika Tiger DI 55 CRDS 4WD'), findsOneWidget);

      // Verify New Holland via search
      await tester.enterText(find.byType(TextField), 'New Holland');
      await tester.pumpAndSettle();
      expect(find.text('New Holland 3630 TX Special Edition'), findsOneWidget);

      // Verify Eicher via search
      await tester.enterText(find.byType(TextField), 'Eicher');
      await tester.pumpAndSettle();
      expect(find.text('Eicher 485 Super DI'), findsOneWidget);

      // Clear search and filter Mini Tractors to verify Captain
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mini Tractors'));
      await tester.pumpAndSettle();
      expect(find.text('Captain 280 DI 4WD Mini Tractor'), findsOneWidget);
      expect(find.text('Kubota Neostar B2741S (4WD)'), findsOneWidget);
    },
  );

  testWidgets(
    '17. Adding crop updates FarmerService and displays on MyFarmScreen',
    (WidgetTester tester) async {
      const testFarmer = FarmerModel(
        id: '#7777',
        name: 'Ramesh Patel',
        phone: '+91 99887 76655',
        currentCrop: 'Cotton',
      );
      FarmerService.instance.register(testFarmer);

      await tester.pumpWidget(const MaterialApp(home: MyFarmScreen()));
      await tester.pumpAndSettle();

      // Verify initial crop is Cotton
      expect(find.text('Current Crop: Cotton'), findsOneWidget);
      // Verify View Expenses displays live total
      expect(find.text('₹12,500'), findsOneWidget);

      // Now update crop to Groundnut via FarmerService
      FarmerService.instance.updateCrop(
        crop: 'Groundnut',
        sowingDate: '10 July 2026',
        harvestDate: '10 Nov 2026 (Day 25/120)',
      );
      await tester.pumpAndSettle();

      // MyFarmScreen should reflect Groundnut dynamically
      expect(find.text('Current Crop: Groundnut'), findsOneWidget);
      expect(find.text('Sowing Date: 10 July 2026'), findsOneWidget);
    },
  );

  testWidgets(
    '18. Land Records dialog opens, displays AnyRoR Verified badge and details without RenderFlex overflow on small screen width (320px)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      const testFarmer = FarmerModel(
        id: '#8492',
        name: 'Tirthbhai Sanyaja',
        phone: '+91 98765 43210',
        village: 'Sardhar',
        district: 'Rajkot',
        landAcres: '5.5 Acres',
        soilType: 'Medium Black (Kali Jameen)',
        waterSource: 'Borewell + Drip System',
      );
      FarmerService.instance.register(testFarmer);

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Tap on Land Records & 7/12 Documents
      final landRecordsTile = find.text('Land Records & 7/12 Documents');
      expect(landRecordsTile, findsOneWidget);
      await tester.tap(landRecordsTile);
      await tester.pumpAndSettle();

      // Check title and AnyRoR badge
      expect(find.text('Land Records (7/12 & 8A)'), findsOneWidget);
      expect(find.text('AnyRoR Verified'), findsOneWidget);

      // Check fields
      expect(find.text('Khata No.'), findsOneWidget);
      expect(find.text('8492 / Sardhar'), findsOneWidget);
      expect(find.text('Survey / Block No.'), findsOneWidget);
      expect(find.text('142 / Paiki 1'), findsOneWidget);
      expect(find.text('Total Area'), findsOneWidget);
      expect(find.text('5.5 Acres'), findsNWidgets(2));
      expect(find.text('Soil Classification'), findsOneWidget);
      expect(find.text('Medium Black (Kali Jameen)'), findsOneWidget);
      expect(find.text('Irrigation Source'), findsOneWidget);
      expect(find.text('Borewell + Drip System'), findsOneWidget);

      // Close button should be present and close the dialog smoothly
      final closeBtn = find.widgetWithText(ElevatedButton, 'Close');
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.text('AnyRoR Verified'), findsNothing);
    },
  );

  testWidgets(
    '19. Help Center Screen displays 1800-180-1551 helpline, categories, expandable FAQs, and query submission',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));
      await tester.pumpAndSettle();

      // Verify Kisan Helpline Card
      expect(find.text('1800-180-1551'), findsOneWidget);
      expect(find.text('Call Now'), findsOneWidget);
      expect(find.text('Kisan Call Center (Toll Free)'), findsOneWidget);

      // Verify categories chips exist
      expect(find.text('Account & Profile'), findsOneWidget);
      expect(find.text('Land Records'), findsOneWidget);
      expect(find.text('Crops & Farming'), findsOneWidget);
      expect(find.text('Tractor & Machinery'), findsOneWidget);
      expect(find.text('Payments & Bookings'), findsOneWidget);

      // Verify FAQ items are present
      expect(find.text('How can I update my farmer profile?'), findsOneWidget);
      expect(
        find.text('How can I add or manage land records?'),
        findsOneWidget,
      );
      expect(
        find.text('How can I book a tractor or farm machinery?'),
        findsOneWidget,
      );

      // Expand FAQ
      await tester.tap(
        find.text('How can I book a tractor or farm machinery?'),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Open "Tractor & Machinery Rentals"'),
        findsOneWidget,
      );

      // Test Question Submission
      final submitBtn = find.text('Submit Question');
      expect(submitBtn, findsOneWidget);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Verify validation
      expect(
        find.text('Please enter your question before submitting.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    '20. Machinery Detail Screen displays specifications, provider contact, and pricing',
    (WidgetTester tester) async {
      final item = MachineryService.instance.machineries.first;

      await tester.pumpWidget(
        MaterialApp(home: MachineryDetailScreen(machinery: item)),
      );
      await tester.pumpAndSettle();

      // Verify Title & Brand
      expect(find.text(item.name), findsWidgets);
      expect(find.text('${item.brand} • ${item.hp}'), findsOneWidget);
      expect(find.text('${item.hourlyRateFormatted} / hr'), findsWidgets);
      expect(find.text('${item.dailyRateFormatted} / day'), findsOneWidget);

      // Verify Provider info
      expect(find.text(item.provider.name), findsOneWidget);
      expect(find.text(item.provider.phone), findsOneWidget);

      // Verify Technical Specifications section
      expect(find.text('Technical Specifications'), findsOneWidget);
      expect(find.text('Engine Power'), findsOneWidget);

      // Verify Book Now is present
      expect(find.text('Book Now'), findsOneWidget);
    },
  );

  testWidgets(
    '21. Tractor booking conflict prevention and My Bookings tab management with cancellation',
    (WidgetTester tester) async {
      const testFarmer = FarmerModel(
        id: '#1234',
        name: 'Haresh Vala',
        phone: '+91 97123 99887',
        village: 'Sardhar',
      );
      FarmerService.instance.register(testFarmer);

      await tester.pumpWidget(const MaterialApp(home: TractorHireScreen()));
      await tester.pumpAndSettle();

      // Verify Tab bar
      expect(find.text('Browse Machinery'), findsOneWidget);
      expect(find.textContaining('My Bookings'), findsOneWidget);

      // Switch to My Bookings tab
      await tester.tap(find.textContaining('My Bookings'));
      await tester.pumpAndSettle();

      // Verify seed bookings exist
      expect(find.text('John Deere 5050 D 4WD'), findsOneWidget);
      expect(find.text('#TR-8491'), findsOneWidget);

      // Cancel booking #TR-8491
      final cancelBtn = find.text('Cancel Booking').first;
      expect(cancelBtn, findsOneWidget);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      // Verify confirmation prompt
      expect(find.text('Cancel Booking?'), findsOneWidget);
      final confirmCancel = find.widgetWithText(
        ElevatedButton,
        'Cancel Booking',
      );
      await tester.tap(confirmCancel);
      await tester.pumpAndSettle();

      // Status updated
      expect(find.text('Cancelled'), findsWidgets);
    },
  );

  testWidgets(
    '22. Tractor & Machinery rentals filters by categories including Rotavator, Cultivator, Harvester',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TractorHireScreen()));
      await tester.pumpAndSettle();

      // Tap on Rotavator category chip
      await tester.tap(find.text('Rotavator'));
      await tester.pumpAndSettle();
      expect(
        find.text('Shaktiman Semi Champion 7ft Rotavator'),
        findsOneWidget,
      );

      // Drag category chip row to reveal Harvester
      await tester.drag(find.text('Rotavator'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      final harvesterChip = find.text('Harvester');
      await tester.tap(harvesterChip);
      await tester.pumpAndSettle();
      expect(find.text('Claas Crop Tiger 30 Harvester'), findsOneWidget);
    },
  );
}
