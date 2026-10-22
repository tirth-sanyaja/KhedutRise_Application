import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/khedut_app_bar.dart';
import '../../../core/widgets/khedut_button.dart';
import '../../../core/widgets/khedut_text_field.dart';
import '../../../core/widgets/responsive_body.dart';

class AddCropScreen extends StatefulWidget {
  final bool isEdit;

  const AddCropScreen({super.key, this.isEdit = true});

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
    final farmer = FarmerService.instance.currentFarmer;
    final isEditingCrop = widget.isEdit || (farmer != null && farmer.currentCrop.isNotEmpty);
    final screenTitle = isEditingCrop ? 'Edit Crop Details' : 'Add New Crop';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KhedutAppBar(title: screenTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveBody(
            maxWidth: 720,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clean Text-based Crop Information Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFA7F3D0),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.eco,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Crop Information Overview',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildCropInfoText('Active Crop', _selectedCrop),
                        const SizedBox(height: 6),
                        _buildCropInfoText('Sowing Date', _sowingDateController.text),
                        const SizedBox(height: 6),
                        _buildCropInfoText('Harvest Timeline', _harvestDateController.text),
                        const SizedBox(height: 6),
                        _buildCropInfoText(
                          'Land Allocation',
                          _areaController.text.isNotEmpty ? _areaController.text : '5.0 Acres',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'EDIT CROP SPECIFICATIONS',
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
                    onChanged: (val) {
                      setState(() {});
                    },
                    validator: (val) => AppValidators.validateAcres(val),
                  ),
                  const SizedBox(height: 20),

                  // Optimal Soil Health Match Card (Clean text presentation)
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
      ),
    );
  }

  Widget _buildCropInfoText(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 125,
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(':  ', style: TextStyle(color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Dedicated EditCropScreen wrapper for explicit route and class references
class EditCropScreen extends StatelessWidget {
  const EditCropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddCropScreen(isEdit: true);
  }
}
