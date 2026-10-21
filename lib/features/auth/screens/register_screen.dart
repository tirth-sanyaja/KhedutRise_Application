import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/farmer_model.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/khedut_button.dart';
import '../../../core/widgets/khedut_text_field.dart';
import '../../../core/widgets/password_strength_indicator.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _locationController = TextEditingController();
  final _landController = TextEditingController();
  final _soilController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedWaterSource = 'Borewell';
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    _locationController.dispose();
    _landController.dispose();
    _soilController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    final phone = _phoneController.text.trim();
    final phoneErr = AppValidators.validatePhone(phone);
    if (phoneErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneErr),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (FarmerService.instance.isRegistered(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This mobile number is already registered. Please sign in instead.',
          ),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent successfully to $phone'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onCompleteRegistration() {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Name Validation
    final nameErr = AppValidators.validateName(name);
    if (nameErr != null) {
      setState(() => _errorMessage = nameErr);
      return;
    }

    // 2. Phone Validation
    final phoneErr = AppValidators.validatePhone(phone);
    if (phoneErr != null) {
      setState(() => _errorMessage = phoneErr);
      return;
    }

    // 3. Duplicate phone registration check
    if (FarmerService.instance.isRegistered(phone)) {
      setState(
        () => _errorMessage =
            'This mobile number is already registered. Please sign in.',
      );
      return;
    }

    // 4. Password validation
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password cannot be empty');
      return;
    }

    if (password.length < 4) {
      setState(
        () => _errorMessage = 'Password must be at least 4 characters long',
      );
      return;
    }

    // 5. Confirm Password validation
    if (confirmPassword.isNotEmpty && confirmPassword != password) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    // 6. Terms & Conditions
    if (!_acceptTerms) {
      setState(
        () => _errorMessage = 'Please accept the Terms & Conditions to proceed',
      );
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final locationText = _locationController.text.trim();
    final locParts = locationText
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final district = locParts.isNotEmpty ? locParts[0] : 'Rajkot';
    final village = locParts.length > 1 ? locParts.last : 'Sardhar';

    final pendingFarmer = FarmerModel(
      id: '#${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}',
      name: name,
      fatherName: _fatherNameController.text.trim(),
      phone: phone,
      aadhaar: _aadhaarController.text.trim(),
      location: locationText.isNotEmpty
          ? locationText
          : '$district, $village, Gujarat',
      district: district,
      village: village,
      state: 'Gujarat',
      landAcres: _landController.text.trim().isNotEmpty
          ? _landController.text.trim()
          : '5.0 Acres',
      soilType: _soilController.text.trim().isNotEmpty
          ? _soilController.text.trim()
          : 'Black Soil',
      waterSource: _selectedWaterSource,
      password: password,
    );

    setState(() => _isLoading = false);

    Navigator.of(context).pushNamed(
      '/otp',
      arguments: OtpScreenArgs(
        phoneNumber: phone,
        flow: OtpFlow.registration,
        pendingFarmer: pendingFarmer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: Personal Information
                Text(
                  '1. (PERSONAL INFORMATION)',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                // Full Name
                KhedutTextField(
                  label: 'FULL NAME *',
                  controller: _nameController,
                  hintText: 'e.g. Ramesh Patel',
                  validator: (val) => AppValidators.validateName(val),
                ),
                const SizedBox(height: 14),

                // Father Name
                KhedutTextField(
                  label: 'FATHER NAME :',
                  controller: _fatherNameController,
                  hintText: 'e.g. Mohanbhai Patel',
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty) {
                      return AppValidators.validateName(
                        val,
                        fieldName: "Father's Name",
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Mobile & OTP
                Text(
                  'MOBILE NUMBER & OTP * :',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (val) => AppValidators.validatePhone(val),
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: '+91 98765 43210',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderInput,
                              width: 1.2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderInput,
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.errorRed,
                              width: 1.2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.errorRed,
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primaryDark,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: _onSendOtp,
                        child: Text(
                          'Send OTP',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Aadhaar No
                KhedutTextField(
                  label: 'AADHAAR NO :',
                  controller: _aadhaarController,
                  hintText: 'XXXX - XXXX - XXXX',
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      AppValidators.validateAadhaar(val, required: false),
                ),
                const SizedBox(height: 24),

                // SECTION 2: Farm Details
                Text(
                  '2. (FARM DETAILS)',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                // Location
                KhedutTextField(
                  label: 'DISTRICT, TALUKA & VILLAGE :',
                  controller: _locationController,
                  hintText: 'e.g. Rajkot, Rajkot, Sardhar',
                  validator: (val) => AppValidators.validateRequired(
                    val,
                    'Location',
                    minLength: 3,
                  ),
                ),
                const SizedBox(height: 14),

                // Land & Soil side-by-side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: KhedutTextField(
                        label: 'LAND (ACRES) :',
                        controller: _landController,
                        hintText: 'e.g. 5 Acres',
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty) {
                            return AppValidators.validateAcres(val);
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KhedutTextField(
                        label: 'SOIL TYPE :',
                        controller: _soilController,
                        hintText: 'e.g. Black Soil',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Water Source
                Text(
                  'WATER SOURCE',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Borewell', 'River', 'Rain'].map((source) {
                    final isSelected = _selectedWaterSource == source;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedWaterSource = source;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.borderInput,
                                width: 1.2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              source,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Create Password
                KhedutTextField(
                  label: 'CREATE PASSWORD * :',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  hintText: 'Min 8 chars, 1 uppercase, 1 digit, 1 special',
                  onChanged: (val) {
                    setState(() {});
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password cannot be empty';
                    }
                    if (val.length < 4) {
                      return 'Password must be at least 4 characters long';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                // Live Password Strength Indicator
                PasswordStrengthIndicator(password: _passwordController.text),
                const SizedBox(height: 14),

                // Confirm Password
                KhedutTextField(
                  label: 'CONFIRM PASSWORD * :',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  hintText: 'Re-enter your password',
                  onChanged: (val) {
                    setState(() {});
                  },
                  validator: (val) {
                    if (_confirmPasswordController.text.isNotEmpty &&
                        val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Accept Terms
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _acceptTerms = !_acceptTerms;
                    });
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _acceptTerms,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _acceptTerms = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'I accept the Terms & Conditions and Privacy Policy',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Button
                KhedutButton(
                  text: _isLoading ? 'Registering...' : 'Complete Registration',
                  showArrow: false,
                  onPressed: _onCompleteRegistration,
                ),
                const SizedBox(height: 20),

                // Already have account
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushReplacementNamed('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
