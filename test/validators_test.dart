import 'package:flutter_test/flutter_test.dart';
import 'package:khedutrise/core/services/farmer_service.dart';
import 'package:khedutrise/core/services/land_service.dart';
import 'package:khedutrise/core/validation/app_validators.dart';

void main() {
  group('1. Name Validation Tests', () {
    test('Valid Indian and international names pass', () {
      expect(AppValidators.validateName('Tirth Sanyaja'), isNull);
      expect(AppValidators.validateName('Rahul Patel'), isNull);
      expect(AppValidators.validateName('Mary-Jane'), isNull);
      expect(AppValidators.validateName("O'Connor"), isNull);
      expect(AppValidators.validateName('Dr. M. K. Gandhi'), isNull);
      expect(
        AppValidators.validateName('તીર્થ સંયાજા'),
        isNull,
      ); // Gujarati Unicode
      expect(
        AppValidators.validateName('रमेश पटेल'),
        isNull,
      ); // Devanagari Unicode
    });

    test('Empty and whitespace-only names fail', () {
      expect(AppValidators.validateName(''), contains('cannot be empty'));
      expect(AppValidators.validateName(null), contains('cannot be empty'));
      expect(AppValidators.validateName('   '), contains('cannot be empty'));
    });

    test('Numeric and space-only names fail', () {
      expect(
        AppValidators.validateName('123456'),
        contains('cannot consist only of numbers'),
      );
      expect(
        AppValidators.validateName('98251 77665'),
        contains('cannot consist only of numbers'),
      );
    });

    test('Names with consecutive spaces fail', () {
      expect(
        AppValidators.validateName('Tirth   Sanyaja'),
        contains('cannot contain consecutive spaces'),
      );
    });

    test('Too short and too long names fail', () {
      expect(
        AppValidators.validateName('A'),
        contains('at least 2 characters'),
      );
      final longName = 'A' * 65;
      expect(
        AppValidators.validateName(longName),
        contains('cannot exceed 60 characters'),
      );
    });

    test('Names with disallowed symbols fail', () {
      expect(
        AppValidators.validateName('Rahul@Patel'),
        contains('letters, spaces, hyphens and apostrophes only'),
      );
      expect(
        AppValidators.validateName('Farmer #X'),
        contains('letters, spaces, hyphens and apostrophes only'),
      );
    });
  });

  group('2. Email Validation Tests', () {
    test('Valid standard email addresses pass', () {
      expect(AppValidators.validateEmail('user@example.com'), isNull);
      expect(AppValidators.validateEmail('farmer.khedut@gmail.com'), isNull);
      expect(AppValidators.validateEmail('tirth@khedutrise.in'), isNull);
      expect(AppValidators.validateEmail('support@gov.in'), isNull);
    });

    test('Optional email returns null when blank', () {
      expect(AppValidators.validateEmail('', required: false), isNull);
      expect(AppValidators.validateEmail(null, required: false), isNull);
      expect(AppValidators.validateEmail('   ', required: false), isNull);
    });

    test('Required email fails when blank', () {
      expect(
        AppValidators.validateEmail('', required: true),
        contains('cannot be empty'),
      );
      expect(
        AppValidators.validateEmail(null, required: true),
        contains('cannot be empty'),
      );
    });

    test('Malformed emails fail', () {
      expect(
        AppValidators.validateEmail('user@'),
        contains('valid email address'),
      );
      expect(
        AppValidators.validateEmail('@example.com'),
        contains('valid email address'),
      );
      expect(
        AppValidators.validateEmail('user.example.com'),
        contains('valid email address'),
      );
      expect(
        AppValidators.validateEmail('user@com'),
        contains('valid email address'),
      );
      expect(
        AppValidators.validateEmail('user @example.com'),
        contains('cannot contain spaces'),
      );
    });
  });

  group('3. Phone Number Validation Tests', () {
    test('Valid Indian 10-digit mobile numbers pass', () {
      expect(AppValidators.validatePhone('9876543210'), isNull);
      expect(AppValidators.validatePhone('8765432109'), isNull);
      expect(AppValidators.validatePhone('7654321098'), isNull);
      expect(AppValidators.validatePhone('6543210987'), isNull);
      expect(AppValidators.validatePhone('+91 98765 43210'), isNull);
      expect(AppValidators.validatePhone('09876543210'), isNull);
      expect(AppValidators.validatePhone('91-9876543210'), isNull);
    });

    test('Empty phone fails when required', () {
      expect(
        AppValidators.validatePhone('', required: true),
        contains('cannot be empty'),
      );
      expect(
        AppValidators.validatePhone(null, required: true),
        contains('cannot be empty'),
      );
      expect(
        AppValidators.validatePhone('   ', required: true),
        contains('cannot be empty'),
      );
    });

    test('Invalid phone prefixes fail', () {
      // Must start with 6, 7, 8, or 9
      expect(
        AppValidators.validatePhone('5555555555'),
        contains('must start with 6, 7, 8, or 9'),
      );
      expect(
        AppValidators.validatePhone('1234567890'),
        contains('must start with 6, 7, 8, or 9'),
      );
    });

    test('Invalid phone length fails', () {
      expect(AppValidators.validatePhone('98765'), contains('too short'));
      expect(
        AppValidators.validatePhone('987654321099'),
        contains('cannot exceed 10 digits'),
      );
    });

    test('Alphabetic characters in phone fail', () {
      expect(
        AppValidators.validatePhone('98765ABCD0'),
        contains('must only contain digits'),
      );
    });

    test('Phone normalization strips prefix properly', () {
      expect(AppValidators.normalizePhone('+91 98765 43210'), '9876543210');
      expect(AppValidators.normalizePhone('09876543210'), '9876543210');
      expect(AppValidators.normalizePhone('98765-43210'), '9876543210');
    });
  });

  group('4. Strong Password Validation & Live Strength Tests', () {
    test('Password strength scoring correctly categorizes passwords', () {
      // Empty
      final emptyResult = AppValidators.calculatePasswordStrength('');
      expect(emptyResult.strength, PasswordStrength.none);
      expect(emptyResult.score, 0);

      // Weak
      final weak1 = AppValidators.calculatePasswordStrength('12345');
      expect(weak1.strength, PasswordStrength.weak);

      final weak2 = AppValidators.calculatePasswordStrength('password');
      expect(weak2.strength, PasswordStrength.weak);

      // Fair (meets 2 criteria: length >= 8 and digits)
      final fair = AppValidators.calculatePasswordStrength('pass12345');
      expect(fair.strength, PasswordStrength.fair);

      // Strong (meets 3 criteria: length >= 8, upper+lower, and digits)
      final strong = AppValidators.calculatePasswordStrength('Khedut1234');
      expect(strong.strength, PasswordStrength.strong);

      // Very Strong
      final veryStrong = AppValidators.calculatePasswordStrength(
        'KhedutRise#2026Secure!',
      );
      expect(veryStrong.strength, PasswordStrength.veryStrong);
      expect(veryStrong.hasMinLength, isTrue);
      expect(veryStrong.hasUppercase, isTrue);
      expect(veryStrong.hasLowercase, isTrue);
      expect(veryStrong.hasDigit, isTrue);
      expect(veryStrong.hasSpecialChar, isTrue);
    });

    test('Strict password validation checks all required policies', () {
      // Empty
      expect(AppValidators.validatePassword(''), contains('cannot be empty'));
      expect(AppValidators.validatePassword(null), contains('cannot be empty'));

      // Spaces
      expect(
        AppValidators.validatePassword('Pass word1!'),
        contains('cannot contain spaces'),
      );

      // Min 8 characters
      expect(
        AppValidators.validatePassword('Pass1!'),
        contains('at least 8 characters'),
      );

      // Missing lowercase
      expect(
        AppValidators.validatePassword('PASS12345!', strict: true),
        contains('at least one lowercase letter'),
      );

      // Missing uppercase
      expect(
        AppValidators.validatePassword('pass12345!', strict: true),
        contains('at least one uppercase letter'),
      );

      // Missing digit
      expect(
        AppValidators.validatePassword('Password!!', strict: true),
        contains('at least one number'),
      );

      // Missing special character
      expect(
        AppValidators.validatePassword('Password12', strict: true),
        contains('at least one special character'),
      );

      // Valid strong password
      expect(
        AppValidators.validatePassword('Khedut@2026', strict: true),
        isNull,
      );
    });
  });

  group('5. Confirm Password Validation Tests', () {
    test('Matching passwords return null', () {
      expect(
        AppValidators.validateConfirmPassword('Secret123!', 'Secret123!'),
        isNull,
      );
    });

    test('Mismatched passwords return error', () {
      expect(
        AppValidators.validateConfirmPassword('Secret123!', 'Different123!'),
        'Passwords do not match',
      );
    });

    test('Empty confirm password returns error', () {
      expect(
        AppValidators.validateConfirmPassword('', 'Secret123!'),
        'Please confirm your password',
      );
      expect(
        AppValidators.validateConfirmPassword(null, 'Secret123!'),
        'Please confirm your password',
      );
    });
  });

  group('6. Numeric & Field Specific Validation Tests', () {
    test('Price validation handles currency symbols and formats', () {
      expect(AppValidators.validatePrice('₹ 35,00,000'), isNull);
      expect(AppValidators.validatePrice('2700'), isNull);
      expect(AppValidators.validatePrice('150.50'), isNull);

      // Errors
      expect(AppValidators.validatePrice(''), contains('cannot be empty'));
      expect(AppValidators.validatePrice('0'), contains('greater than zero'));
      expect(
        AppValidators.validatePrice('-500'),
        contains('greater than zero'),
      );
      expect(
        AppValidators.validatePrice('abc'),
        contains('valid numeric amount'),
      );
    });

    test('Land acres validation handles numbers and suffixes', () {
      expect(AppValidators.validateAcres('5.5'), isNull);
      expect(AppValidators.validateAcres('5.0 Acres'), isNull);
      expect(AppValidators.validateAcres('12.75 Acres'), isNull);

      // Errors
      expect(AppValidators.validateAcres(''), contains('cannot be empty'));
      expect(
        AppValidators.validateAcres('0'),
        contains('greater than 0 acres'),
      );
      expect(
        AppValidators.validateAcres('-2.5'),
        contains('greater than 0 acres'),
      );
      expect(
        AppValidators.validateAcres('invalid'),
        contains('valid land area'),
      );
      expect(
        AppValidators.validateAcres('50000'),
        contains('cannot exceed 10,000 acres'),
      );
    });

    test('PIN code validation enforces 6-digit Indian Postal format', () {
      expect(AppValidators.validatePinCode('360025'), isNull); // Rajkot
      expect(AppValidators.validatePinCode('380001'), isNull); // Ahmedabad

      // Errors
      expect(AppValidators.validatePinCode(''), contains('cannot be empty'));
      expect(
        AppValidators.validatePinCode('012345'),
        contains('valid 6-digit PIN code'),
      ); // Cannot start with 0
      expect(
        AppValidators.validatePinCode('36002'),
        contains('valid 6-digit PIN code'),
      ); // Too short
      expect(
        AppValidators.validatePinCode('3600251'),
        contains('valid 6-digit PIN code'),
      ); // Too long
      expect(
        AppValidators.validatePinCode('36002A'),
        contains('valid 6-digit PIN code'),
      ); // Non-digit
    });

    test('Aadhaar number validation handles 12-digit and masked formats', () {
      expect(AppValidators.validateAadhaar('XXXX-XXXX-4821'), isNull);
      expect(AppValidators.validateAadhaar('XXXX - XXXX - 4821'), isNull);
      expect(AppValidators.validateAadhaar('9876 5432 1098'), isNull);
      expect(AppValidators.validateAadhaar('', required: false), isNull);

      // Errors
      expect(
        AppValidators.validateAadhaar('12345', required: true),
        contains('12 digits'),
      );
      expect(
        AppValidators.validateAadhaar('087654321098', required: true),
        contains('Invalid Aadhaar'),
      ); // Starts with 0
    });

    test('Hours validation ensures valid equipment booking duration', () {
      expect(AppValidators.validateHours('4'), isNull);
      expect(AppValidators.validateHours('1'), isNull);
      expect(AppValidators.validateHours('24'), isNull);

      expect(
        AppValidators.validateHours('0'),
        contains('between 1 and 24 hours'),
      );
      expect(
        AppValidators.validateHours('25'),
        contains('between 1 and 24 hours'),
      );
      expect(AppValidators.validateHours(''), contains('cannot be empty'));
    });
  });

  group('7. Security & Session Service Tests', () {
    test('SHA-256 password hashing works consistently and is salted', () {
      final hash1 = FarmerService.hashPassword('MyPassword@123');
      final hash2 = FarmerService.hashPassword('MyPassword@123');
      final hashDiff = FarmerService.hashPassword('OtherPassword@123');

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals('MyPassword@123'))); // Never plain text
      expect(hash1, isNot(equals(hashDiff)));
      expect(hash1.length, equals(64)); // 256 bits = 64 hex chars
    });

    test('FarmerService detects registered phones correctly', () {
      expect(FarmerService.instance.isRegistered('+91 98765 43210'), isTrue);
      expect(FarmerService.instance.isRegistered('9876543210'), isTrue);
      expect(FarmerService.instance.isRegistered('9999999999'), isFalse);
    });

    test(
      'LandService maintains reactive listings and supports adding new land',
      () {
        final initialCount = LandService.instance.lands.length;
        expect(initialCount, equals(8));

        final testListing = {
          'id': 'LND-TEST',
          'title': 'Test Organic Orchard',
          'location': 'Gondal, Rajkot',
          'acres': '10.0 Acres',
          'acresNum': 10.0,
          'price': '₹ 50,00,000',
          'isVerified': true,
          'type': 'Sell',
        };

        LandService.instance.addLand(testListing);
        expect(LandService.instance.lands.length, equals(initialCount + 1));
        expect(
          LandService.instance.lands.first['title'],
          equals('Test Organic Orchard'),
        );

        // Clean up
        LandService.instance.resetToDefaults();
        expect(LandService.instance.lands.length, equals(initialCount));
      },
    );
  });
}
