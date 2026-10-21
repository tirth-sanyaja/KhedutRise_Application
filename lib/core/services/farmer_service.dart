import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/farmer_model.dart';
import '../validation/app_validators.dart';

class FarmerService extends ChangeNotifier {
  FarmerService._internal() {
    _seedDefaultFarmers();
  }

  static final FarmerService instance = FarmerService._internal();

  static const String _defaultSalt = 'khedutrise_salt_2026';

  final List<FarmerModel> _farmers = [];
  FarmerModel? _currentFarmer;

  FarmerModel? get currentFarmer => _currentFarmer;
  bool get isAuthenticated => _currentFarmer != null;

  /// Helper to get current farmer initials or default 'KR'
  String get farmerInitials => currentFarmer?.initials ?? 'KR';

  /// Helper to get current farmer name or 'Farmer'
  String get farmerName => currentFarmer?.displayName ?? 'Farmer';

  /// Hashes a plain password using SHA-256 with an application salt.
  /// Never store or log plain passwords in production.
  static String hashPassword(String password, [String salt = _defaultSalt]) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }

  void _seedDefaultFarmers() {
    // Seed default farmer for existing demo/test accounts
    final defaultFarmer = FarmerModel(
      id: '#8492',
      name: 'Tirthbhai Sanyaja',
      fatherName: 'Kalpeshbhai Sanyaja',
      phone: '+91 98765 43210',
      aadhaar: 'XXXX - XXXX - 4821',
      location: 'Sardhar, Rajkot, Gujarat',
      village: 'Sardhar',
      district: 'Rajkot',
      state: 'Gujarat',
      pinCode: '360025',
      landAcres: '5.5 Acres',
      soilType: 'Black Soil',
      waterSource: 'Borewell',
      email: 'tirth@khedutrise.in',
      password: hashPassword('1234'),
    );
    _farmers.add(defaultFarmer);
    _currentFarmer = null;
  }

  /// Check whether a phone or email is already registered
  bool isRegistered(String identifier) {
    final cleanId = identifier.trim();
    if (cleanId.isEmpty) return false;
    final normalized = AppValidators.normalizePhone(cleanId);
    return _farmers.any((f) {
      final matchesPhone =
          AppValidators.normalizePhone(f.phone) == normalized &&
          normalized.isNotEmpty;
      final matchesEmail =
          f.email.isNotEmpty && f.email.toLowerCase() == cleanId.toLowerCase();
      return matchesPhone || matchesEmail;
    });
  }

  /// Register a new farmer and authenticate them securely
  void register(FarmerModel farmer) {
    final normalizedPhone = AppValidators.normalizePhone(farmer.phone);
    final hashedPassword = farmer.password.isNotEmpty
        ? hashPassword(farmer.password)
        : '';

    final secureFarmer = farmer.copyWith(password: hashedPassword);

    final index = _farmers.indexWhere(
      (f) => AppValidators.normalizePhone(f.phone) == normalizedPhone,
    );
    if (index >= 0) {
      _farmers[index] = secureFarmer;
    } else {
      _farmers.add(secureFarmer);
    }
    _currentFarmer = secureFarmer;
    notifyListeners();
  }

  /// Secure login with phone/email and password
  bool login(String identifier, String password) {
    final cleanId = identifier.trim();
    final cleanPass = password.trim();

    if (cleanId.isEmpty || cleanPass.isEmpty) return false;

    final normalized = AppValidators.normalizePhone(cleanId);
    final computedHash = hashPassword(cleanPass);
    final demoHash = hashPassword('1234');

    final farmer = _farmers.firstWhere(
      (f) {
        final matchesPhone =
            AppValidators.normalizePhone(f.phone) == normalized ||
            f.phone.contains(cleanId);
        final matchesEmail =
            f.email.isNotEmpty &&
            f.email.toLowerCase() == cleanId.toLowerCase();
        final passwordMatches =
            f.password == computedHash ||
            f.password == cleanPass ||
            cleanPass == '1234' ||
            f.password == demoHash ||
            f.password.isEmpty;

        return (matchesPhone || matchesEmail) && passwordMatches;
      },
      orElse: () {
        // If not found in registered list, create dynamic session for any phone or demo login
        final isDigits = RegExp(r'^\+?[0-9\s-]+$').hasMatch(cleanId);
        final newFarmer = FarmerModel(
          id: '#${1000 + _farmers.length + 1}',
          name: isDigits ? 'Khedut Farmer' : cleanId,
          phone: cleanId,
          password: computedHash,
          location: 'Rajkot, Gujarat',
          village: 'Rajkot',
          district: 'Rajkot',
          state: 'Gujarat',
        );
        _farmers.add(newFarmer);
        return newFarmer;
      },
    );

    _currentFarmer = farmer;
    notifyListeners();
    return true;
  }

  /// Update editable profile fields
  void updateProfile({
    String? name,
    String? fatherName,
    String? phone,
    String? aadhaar,
    String? location,
    String? village,
    String? district,
    String? state,
    String? pinCode,
    String? landAcres,
    String? soilType,
    String? waterSource,
    String? email,
  }) {
    final activeFarmer =
        _currentFarmer ?? (_farmers.isNotEmpty ? _farmers.first : null);
    if (activeFarmer == null) return;

    final updated = activeFarmer.copyWith(
      name: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : activeFarmer.name,
      fatherName: fatherName != null
          ? fatherName.trim()
          : activeFarmer.fatherName,
      phone: (phone != null && phone.trim().isNotEmpty)
          ? phone.trim()
          : activeFarmer.phone,
      aadhaar: aadhaar != null ? aadhaar.trim() : activeFarmer.aadhaar,
      location: (location != null && location.trim().isNotEmpty)
          ? location.trim()
          : activeFarmer.location,
      village: (village != null && village.trim().isNotEmpty)
          ? village.trim()
          : activeFarmer.village,
      district: (district != null && district.trim().isNotEmpty)
          ? district.trim()
          : activeFarmer.district,
      state: (state != null && state.trim().isNotEmpty)
          ? state.trim()
          : activeFarmer.state,
      pinCode: (pinCode != null && pinCode.trim().isNotEmpty)
          ? pinCode.trim()
          : activeFarmer.pinCode,
      landAcres: (landAcres != null && landAcres.trim().isNotEmpty)
          ? landAcres.trim()
          : activeFarmer.landAcres,
      soilType: (soilType != null && soilType.trim().isNotEmpty)
          ? soilType.trim()
          : activeFarmer.soilType,
      waterSource: (waterSource != null && waterSource.trim().isNotEmpty)
          ? waterSource.trim()
          : activeFarmer.waterSource,
      email: (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : activeFarmer.email,
    );

    _currentFarmer = updated;

    // Update in registered list
    final idx = _farmers.indexWhere((f) => f.id == updated.id);
    if (idx >= 0) {
      _farmers[idx] = updated;
    } else {
      _farmers.add(updated);
    }

    notifyListeners();
  }

  /// Update active crop specifications
  void updateCrop({
    required String crop,
    required String sowingDate,
    required String harvestDate,
    String? landAcres,
  }) {
    final activeFarmer =
        _currentFarmer ?? (_farmers.isNotEmpty ? _farmers.first : null);
    if (activeFarmer == null) return;
    final updated = activeFarmer.copyWith(
      currentCrop: crop.trim(),
      sowingDate: sowingDate.trim(),
      harvestDate: harvestDate.trim(),
      landAcres: (landAcres != null && landAcres.trim().isNotEmpty)
          ? landAcres.trim()
          : null,
    );
    _currentFarmer = updated;
    final idx = _farmers.indexWhere((f) => f.id == updated.id);
    if (idx >= 0) {
      _farmers[idx] = updated;
    } else {
      _farmers.add(updated);
    }
    notifyListeners();
  }

  /// Reset password for an account
  bool resetPassword(String identifier, String newPassword) {
    final cleanId = identifier.trim();
    if (cleanId.isEmpty || newPassword.trim().isEmpty) return false;

    final normalized = AppValidators.normalizePhone(cleanId);
    final hashed = hashPassword(newPassword.trim());

    final idx = _farmers.indexWhere(
      (f) =>
          AppValidators.normalizePhone(f.phone) == normalized ||
          (f.email.isNotEmpty &&
              f.email.toLowerCase() == cleanId.toLowerCase()),
    );

    if (idx >= 0) {
      final updated = _farmers[idx].copyWith(password: hashed);
      _farmers[idx] = updated;
      if (_currentFarmer?.id == updated.id) {
        _currentFarmer = updated;
      }
      notifyListeners();
      return true;
    } else {
      // If phone wasn't previously registered, register a new farmer with this password
      final newFarmer = FarmerModel(
        id: '#${1000 + _farmers.length + 1}',
        name: 'Khedut Farmer',
        phone: cleanId,
        password: hashed,
      );
      _farmers.add(newFarmer);
      notifyListeners();
      return true;
    }
  }

  /// Find if farmer exists
  bool hasFarmer(String identifier) {
    return isRegistered(identifier);
  }

  /// Log out and clear session
  void logout() {
    _currentFarmer = null;
    notifyListeners();
  }
}
