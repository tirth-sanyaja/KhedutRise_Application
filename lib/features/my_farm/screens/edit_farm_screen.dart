import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/widgets/khedut_app_bar.dart';
import '../../../core/widgets/khedut_button.dart';
import '../../../core/widgets/khedut_text_field.dart';

class EditFarmScreen extends StatefulWidget {
  const EditFarmScreen({super.key});

  @override
  State<EditFarmScreen> createState() => _EditFarmScreenState();
}

class _EditFarmScreenState extends State<EditFarmScreen> {
  final _nameController = TextEditingController(text: 'Vishvas Plot A');
  late String _selectedLocation;
  late String _selectedSoil;
  late String _selectedWater;
  late final TextEditingController _areaController;

  @override
  void initState() {
    super.initState();
    final farmer = FarmerService.instance.currentFarmer;
    final loc = farmer != null && farmer.village.isNotEmpty
        ? '${farmer.village}, ${farmer.district}, Gujarat'
        : 'Sardhar, Rajkot, Gujarat';
    _selectedLocation =
        [
          'Sardhar, Rajkot, Gujarat',
          'Gondal, Rajkot, Gujarat',
          'Jetpur, Rajkot, Gujarat',
        ].contains(loc)
        ? loc
        : 'Sardhar, Rajkot, Gujarat';
    _selectedSoil =
        (farmer?.soilType.isNotEmpty == true &&
            [
              'Black Soil',
              'Alluvial Soil',
              'Red Soil',
              'Sandy Loam',
            ].contains(farmer!.soilType))
        ? farmer.soilType
        : 'Black Soil';
    _selectedWater =
        (farmer?.waterSource.isNotEmpty == true &&
            ['Borewell', 'Canal', 'Rainfed'].contains(farmer!.waterSource))
        ? farmer.waterSource
        : 'Borewell';
    _areaController = TextEditingController(
      text: farmer?.landAcres ?? '5.5 Acres',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _onSave() {
    FarmerService.instance.updateProfile(
      landAcres: _areaController.text.trim(),
      soilType: _selectedSoil,
      waterSource: _selectedWater,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Farm details updated successfully!'),
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
      appBar: const KhedutAppBar(title: 'Edit Farm details'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Farm Name
              KhedutTextField(
                label: 'FARM/PLOT NAME',
                controller: _nameController,
              ),
              const SizedBox(height: 18),

              // Location Dropdown
              Text(
                'LOCATION (VILLAGE, TALUKA, DISTRICT)',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderInput, width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLocation,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textPrimary,
                    ),
                    items:
                        {
                          _selectedLocation,
                          'Sardhar, Rajkot, Gujarat',
                          'Gondal, Rajkot, Gujarat',
                          'Jetpur, Rajkot, Gujarat',
                        }.map((loc) {
                          return DropdownMenuItem(
                            value: loc,
                            child: Text(
                              loc,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLocation = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

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
                  border: Border.all(color: AppColors.borderInput, width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSoil,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textPrimary,
                    ),
                    items:
                        {
                          _selectedSoil,
                          'Black Soil',
                          'Alluvial Soil',
                          'Red Soil',
                          'Sandy Loam',
                        }.map((s) {
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
              const SizedBox(height: 18),

              // Water Source chips
              Text(
                'WATER SOURCE',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Borewell', 'Canal', 'Rainfed'].map((source) {
                  final isSelected = _selectedWater == source;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedWater = source;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
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
              const SizedBox(height: 18),

              // Total Area Size
              KhedutTextField(
                label: 'TOTAL AREA SIZE (ACRES)',
                controller: _areaController,
              ),
              const SizedBox(height: 40),

              // Button
              KhedutButton(text: 'Save Changes', onPressed: _onSave),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}
