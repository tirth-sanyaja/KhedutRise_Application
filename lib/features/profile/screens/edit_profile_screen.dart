import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/khedut_app_bar.dart';
import '../../../core/widgets/khedut_button.dart';
import '../../../core/widgets/khedut_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _fatherNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _districtController;
  late final TextEditingController _villageController;
  late final TextEditingController _stateController;
  late final TextEditingController _pinCodeController;
  late final TextEditingController _landController;

  late String _selectedSoil;
  late String _selectedWater;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final farmer = FarmerService.instance.currentFarmer;

    _nameController = TextEditingController(text: farmer?.name ?? '');
    _fatherNameController = TextEditingController(
      text: farmer?.fatherName ?? '',
    );
    _phoneController = TextEditingController(text: farmer?.phone ?? '');
    _emailController = TextEditingController(text: farmer?.email ?? '');
    _districtController = TextEditingController(
      text: farmer?.district.isNotEmpty == true ? farmer!.district : 'Rajkot',
    );
    _villageController = TextEditingController(
      text: farmer?.village.isNotEmpty == true ? farmer!.village : 'Sardhar',
    );
    _stateController = TextEditingController(
      text: farmer?.state.isNotEmpty == true ? farmer!.state : 'Gujarat',
    );
    _pinCodeController = TextEditingController(
      text: farmer?.pinCode.isNotEmpty == true ? farmer!.pinCode : '360025',
    );
    _landController = TextEditingController(
      text: farmer?.landAcres.isNotEmpty == true
          ? farmer!.landAcres
          : '5.5 Acres',
    );

    _selectedSoil = (farmer?.soilType.isNotEmpty == true)
        ? farmer!.soilType
        : 'Black Soil';
    _selectedWater = (farmer?.waterSource.isNotEmpty == true)
        ? farmer!.waterSource
        : 'Borewell';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _landController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final pinCode = _pinCodeController.text.trim();
    final land = _landController.text.trim();

    // 1. Name validation
    final nameErr = AppValidators.validateName(name, fieldName: 'Farmer Name');
    if (nameErr != null) {
      setState(() => _errorMessage = nameErr);
      return;
    }

    // 2. Phone validation
    final phoneErr = AppValidators.validatePhone(phone);
    if (phoneErr != null) {
      setState(() => _errorMessage = phoneErr);
      return;
    }

    // 3. Email validation (if provided)
    if (email.isNotEmpty) {
      final emailErr = AppValidators.validateEmail(email);
      if (emailErr != null) {
        setState(() => _errorMessage = emailErr);
        return;
      }
    }

    // 4. PIN code validation
    if (pinCode.isNotEmpty) {
      final pinErr = AppValidators.validatePinCode(pinCode);
      if (pinErr != null) {
        setState(() => _errorMessage = pinErr);
        return;
      }
    }

    // 5. Land Area validation
    if (land.isNotEmpty) {
      final landErr = AppValidators.validateAcres(land);
      if (landErr != null) {
        setState(() => _errorMessage = landErr);
        return;
      }
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final district = _districtController.text.trim();
    final village = _villageController.text.trim();
    final state = _stateController.text.trim();
    final location = '$village, $district, $state';

    FarmerService.instance.updateProfile(
      name: name,
      fatherName: _fatherNameController.text.trim(),
      phone: phone,
      email: email,
      district: district,
      village: village,
      state: state,
      pinCode: pinCode,
      location: location,
      landAcres: land,
      soilType: _selectedSoil,
      waterSource: _selectedWater,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Farmer profile updated successfully!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(
        title: 'Edit Farmer Profile',
        subtitle: 'Personal & Farm Details',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Personal
                Text(
                  'PERSONAL DETAILS',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                KhedutTextField(
                  label: 'FARMER FULL NAME *',
                  controller: _nameController,
                  validator: (val) =>
                      AppValidators.validateName(val, fieldName: 'Farmer Name'),
                ),
                const SizedBox(height: 14),

                KhedutTextField(
                  label: "FATHER'S NAME",
                  controller: _fatherNameController,
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

                KhedutTextField(
                  label: 'MOBILE NUMBER *',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_android,
                    color: AppColors.primaryDark,
                  ),
                  validator: (val) => AppValidators.validatePhone(val),
                ),
                const SizedBox(height: 14),

                KhedutTextField(
                  label: 'EMAIL ADDRESS',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryDark,
                  ),
                  validator: (val) =>
                      AppValidators.validateEmail(val, required: false),
                ),
                const SizedBox(height: 24),

                // Section 2: Address / Location
                Text(
                  'ADDRESS & LOCATION',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: KhedutTextField(
                        label: 'VILLAGE',
                        controller: _villageController,
                        validator: (val) => AppValidators.validateRequired(
                          val,
                          'Village',
                          minLength: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KhedutTextField(
                        label: 'DISTRICT',
                        controller: _districtController,
                        validator: (val) => AppValidators.validateRequired(
                          val,
                          'District',
                          minLength: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: KhedutTextField(
                        label: 'STATE',
                        controller: _stateController,
                        validator: (val) => AppValidators.validateRequired(
                          val,
                          'State',
                          minLength: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KhedutTextField(
                        label: 'PIN CODE',
                        controller: _pinCodeController,
                        keyboardType: TextInputType.number,
                        validator: (val) => AppValidators.validatePinCode(val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section 3: Farm Information
                Text(
                  'FARM & LAND INFORMATION',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                KhedutTextField(
                  label: 'TOTAL LAND SIZE (ACRES)',
                  controller: _landController,
                  keyboardType: TextInputType.number,
                  validator: (val) => AppValidators.validateAcres(val),
                ),
                const SizedBox(height: 14),

                // Soil Type Dropdown
                Text(
                  'SOIL TYPE',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderInput,
                      width: 1.2,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          [
                            'Black Soil',
                            'Alluvial Soil',
                            'Red Soil',
                            'Sandy Loam',
                          ].contains(_selectedSoil)
                          ? _selectedSoil
                          : 'Black Soil',
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textPrimary,
                      ),
                      items:
                          [
                            'Black Soil',
                            'Alluvial Soil',
                            'Red Soil',
                            'Sandy Loam',
                          ].map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSoil = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Water Source chips
                Text(
                  'WATER SOURCE',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Borewell', 'Canal', 'River', 'Rainfed'].map((
                    source,
                  ) {
                    final isSelected = _selectedWater == source;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedWater = source;
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
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textPrimary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                          size: 16,
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

                const SizedBox(height: 32),

                KhedutButton(
                  text: _isLoading ? 'Saving...' : 'Save Profile Changes',
                  onPressed: _onSave,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
