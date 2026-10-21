import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/services/land_service.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/khedut_app_bar.dart';
import '../../../core/widgets/khedut_button.dart';
import '../../../core/widgets/khedut_text_field.dart';

class SellLandScreen extends StatefulWidget {
  const SellLandScreen({super.key});

  @override
  State<SellLandScreen> createState() => _SellLandScreenState();
}

class _SellLandScreenState extends State<SellLandScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController(
    text: 'Fertile Land for lease/sale',
  );
  final _priceController = TextEditingController(text: '₹ 35,00,000');
  final _areaController = TextEditingController(text: '5.0 Acres');
  final _locationController = TextEditingController(text: 'Sardhar, Rajkot');
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_isLoading) return;

    if (_formKey.currentState?.validate() == false) {
      return;
    }

    setState(() => _isLoading = true);

    final title = _titleController.text.trim();
    final rawPrice =
        double.tryParse(
          _priceController.text.replaceAll(RegExp(r'[₹,\s]'), ''),
        ) ??
        3500000;
    final acres =
        double.tryParse(
          _areaController.text.replaceAll(RegExp(r'[^\d.]'), ''),
        ) ??
        5.0;
    final location = _locationController.text.trim();

    final locParts = location.split(',').map((s) => s.trim()).toList();
    final village = locParts.isNotEmpty ? locParts[0] : 'Sardhar';
    final district = locParts.length > 1 ? locParts[1] : 'Rajkot';
    final rate = (rawPrice / (acres > 0 ? acres : 1) / 100000).toStringAsFixed(
      1,
    );

    final newLand = {
      'id': 'LND-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'title': title,
      'location': location,
      'village': village,
      'district': district,
      'acres':
          '${acres.toStringAsFixed(1)} Acres (${(acres * 4).toStringAsFixed(0)} Vigha)',
      'acresNum': acres,
      'soilType': 'Black Soil',
      'waterSource': 'Borewell Available',
      'powerSupply': '3-Phase AG 5HP',
      'roadAccess': '18ft Pucca Road',
      'crops': 'Cotton & Groundnut Suitable',
      'price': '₹ ${_priceController.text.replaceAll(RegExp(r'[₹\s]'), '')}',
      'ratePerAcre': '₹$rate Lac/Acre',
      'isVerified': true,
      'type': 'Sell',
      'distanceKm': 2.0,
      'ownerName': FarmerService.instance.farmerName,
      'ownerPhone':
          FarmerService.instance.currentFarmer?.phone ?? '+91 98765 43210',
      'distance': '2.0 km from your farm',
    };

    LandService.instance.addLand(newLand);

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Land Listing Submitted for Verification!'),
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
      appBar: const KhedutAppBar(title: 'Sell Your Land'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing Title
                KhedutTextField(
                  label: 'LISTING TITLE',
                  controller: _titleController,
                  validator: (val) => AppValidators.validateRequired(
                    val,
                    'Listing Title',
                    minLength: 4,
                  ),
                ),
                const SizedBox(height: 18),

                // Total Target Price
                KhedutTextField(
                  label: 'TOTAL TARGET PRICE (₹)',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  validator: (val) => AppValidators.validatePrice(
                    val,
                    fieldName: 'Target Price',
                  ),
                ),
                const SizedBox(height: 18),

                // Total Land Area
                KhedutTextField(
                  label: 'TOTAL LAND AREA (ACRES)',
                  controller: _areaController,
                  validator: (val) => AppValidators.validateAcres(val),
                ),
                const SizedBox(height: 18),

                // Location
                KhedutTextField(
                  label: 'VILLAGE & DIST. LOCATION',
                  controller: _locationController,
                  validator: (val) => AppValidators.validateRequired(
                    val,
                    'Location',
                    minLength: 3,
                  ),
                ),
                const SizedBox(height: 20),

                // Upload Land Pictures
                Text(
                  'UPLOAD LAND PICTURES',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Dashed add box
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Select land photos from gallery'),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.borderInput,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Placeholder 1
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Placeholder 2
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Submit Button
                KhedutButton(
                  text: _isLoading
                      ? 'Submitting...'
                      : 'Submit Listing for Verification',
                  onPressed: _onSubmit,
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
