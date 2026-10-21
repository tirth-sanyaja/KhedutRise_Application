import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/khedut_app_bar.dart';
import '../../../core/widgets/khedut_button.dart';
import '../../../core/widgets/khedut_text_field.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedCrop = 'Cotton';
  final _sowingDateController = TextEditingController(text: '24 July 2026');
  final _harvestDateController = TextEditingController(
    text: '24 November 2026 (120 Days)',
  );
  late final TextEditingController _areaController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final farmer = FarmerService.instance.currentFarmer;
    _areaController = TextEditingController(
      text: farmer?.landAcres ?? '5.0 Acres',
    );
    if (farmer != null && farmer.currentCrop.isNotEmpty) {
      if ([
        'Cotton',
        'Wheat',
        'Groundnut',
        'Soybean',
        'Bajra',
      ].contains(farmer.currentCrop)) {
        _selectedCrop = farmer.currentCrop;
      }
    }
  }

  @override
  void dispose() {
    _sowingDateController.dispose();
    _harvestDateController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _pickSowingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 7, 24),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _sowingDateController.text =
            '${picked.day} ${_monthName(picked.month)} ${picked.year}';
        final harvest = picked.add(const Duration(days: 120));
        _harvestDateController.text =
            '${harvest.day} ${_monthName(harvest.month)} ${harvest.year} (120 Days)';
      });
    }
  }

  Future<void> _pickHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 11, 24),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _harvestDateController.text =
            '${picked.day} ${_monthName(picked.month)} ${picked.year}';
      });
    }
  }

  static String _monthName(int m) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return (m >= 1 && m <= 12) ? months[m - 1] : '';
  }

  void _onSave() {
    if (_isLoading) return;

    if (_formKey.currentState?.validate() == false) {
      return;
    }

    if (_sowingDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sowing date')),
      );
      return;
    }

    if (_harvestDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expected harvest date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    FarmerService.instance.updateCrop(
      crop: _selectedCrop,
      sowingDate: _sowingDateController.text.trim(),
      harvestDate: _harvestDateController.text.trim(),
      landAcres: _areaController.text.trim(),
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_selectedCrop crop specifications saved successfully!'),
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
      appBar: const KhedutAppBar(title: 'Add New Crop'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP 1 OF 2: CROP SPECS',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),

                // Select Crop Name dropdown
                Text(
                  'SELECT CROP NAME',
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
                      value: _selectedCrop,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textPrimary,
                      ),
                      items:
                          [
                            'Cotton',
                            'Wheat',
                            'Groundnut',
                            'Soybean',
                            'Bajra',
                          ].map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCrop = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Sowing Date
                KhedutTextField(
                  label: 'SOWING DATE',
                  controller: _sowingDateController,
                  readOnly: true,
                  onTap: _pickSowingDate,
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _pickSowingDate,
                  ),
                ),
                const SizedBox(height: 18),

                // Expected Harvest Date
                KhedutTextField(
                  label: 'EXPECTED HARVEST DATE',
                  controller: _harvestDateController,
                  readOnly: true,
                  onTap: _pickHarvestDate,
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _pickHarvestDate,
                  ),
                ),
                const SizedBox(height: 18),

                // Land Area Size
                KhedutTextField(
                  label: 'LAND AREA SIZE (ACRES)',
                  controller: _areaController,
                  keyboardType: TextInputType.number,
                  validator: (val) => AppValidators.validateAcres(val),
                ),
                const SizedBox(height: 20),

                // Optimal Soil Health Match Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Optimal Soil Health Match',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Black Soil matches perfectly with $_selectedCrop.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Button
                KhedutButton(
                  text: _isLoading ? 'Saving...' : 'Save Crop details',
                  onPressed: _onSave,
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
