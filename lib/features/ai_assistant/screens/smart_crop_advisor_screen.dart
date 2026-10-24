import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/crop_recommendation_model.dart';
import '../../../core/models/weather_model.dart';
import '../../../core/services/crop_recommendation_service.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/services/weather_service.dart';
import '../../../core/widgets/khedut_app_bar.dart';
import '../../../core/widgets/khedut_button.dart';

class SmartCropAdvisorScreen extends StatefulWidget {
  const SmartCropAdvisorScreen({super.key});

  @override
  State<SmartCropAdvisorScreen> createState() => _SmartCropAdvisorScreenState();
}

class _SmartCropAdvisorScreenState extends State<SmartCropAdvisorScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedSoilType = 'Black Soil';
  String _selectedSeason = 'Kharif (Monsoon)';
  String _selectedWater = 'Borewell / Tube Well';
  String _selectedPreviousCrop = 'Cotton';
  final _areaController = TextEditingController(text: '5.5 Acres');

  bool _hasMeasuredSoilTest = false;
  final _nController = TextEditingController(text: '140');
  final _pController = TextEditingController(text: '45');
  final _kController = TextEditingController(text: '280');
  final _phController = TextEditingController(text: '7.4');

  bool _isGenerating = false;
  CropRecommendationResult? _result;
  FarmWeather? _liveWeather;
  bool _isLoadingWeather = false;

  final List<String> _soilTypes = [
    'Black Soil',
    'Alluvial / Sandy Loam',
    'Red Soil',
    'Clayey Soil',
  ];

  final List<String> _seasons = [
    'Kharif (Monsoon)',
    'Rabi (Winter)',
    'Zaid (Summer)',
  ];

  final List<String> _waterSources = [
    'Borewell / Tube Well',
    'Canal Irrigation',
    'Drip / Sprinkler',
    'Rainfed Only',
  ];

  final List<String> _previousCrops = [
    'Cotton',
    'Groundnut',
    'Wheat',
    'Cumin / Jeeru',
    'Pulses / Legumes',
    'Fallow / None',
  ];

  @override
  void initState() {
    super.initState();
    _loadFarmerDefaults();
    _fetchLiveWeather();
  }

  void _loadFarmerDefaults() {
    final farmer = FarmerService.instance.currentFarmer;
    if (farmer != null) {
      if (farmer.soilType.isNotEmpty && _soilTypes.contains(farmer.soilType)) {
        _selectedSoilType = farmer.soilType;
      }
      if (farmer.waterSource.isNotEmpty && _waterSources.contains(farmer.waterSource)) {
        _selectedWater = farmer.waterSource;
      }
      if (farmer.landAcres.isNotEmpty) {
        _areaController.text = farmer.landAcres;
      }
    }
  }

  Future<void> _fetchLiveWeather() async {
    setState(() => _isLoadingWeather = true);
    try {
      final farmer = FarmerService.instance.currentFarmer;
      final district = farmer?.district ?? 'Rajkot';
      final weather = await WeatherService.instance.fetchWeather(districtName: district);
      if (mounted) {
        setState(() {
          _liveWeather = weather;
          _isLoadingWeather = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingWeather = false);
    }
  }

  Future<void> _onGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    double? nVal = _hasMeasuredSoilTest ? double.tryParse(_nController.text) : null;
    double? pVal = _hasMeasuredSoilTest ? double.tryParse(_pController.text) : null;
    double? kVal = _hasMeasuredSoilTest ? double.tryParse(_kController.text) : null;
    double? phVal = _hasMeasuredSoilTest ? double.tryParse(_phController.text) : null;

    final farmer = FarmerService.instance.currentFarmer;
    final location = farmer != null && farmer.district.isNotEmpty
        ? '${farmer.district}, Gujarat'
        : 'Rajkot, Gujarat';

    final input = CropRecommendationInput(
      soilType: _selectedSoilType,
      season: _selectedSeason,
      waterSource: _selectedWater,
      landArea: _areaController.text.trim(),
      previousCrop: _selectedPreviousCrop,
      hasMeasuredSoilTest: _hasMeasuredSoilTest,
      nitrogen: nVal,
      phosphorus: pVal,
      potassium: kVal,
      ph: phVal,
      location: location,
    );

    try {
      final outcome = await CropRecommendationService.instance.recommendCrops(
        input: input,
      );

      if (mounted) {
        setState(() {
          _result = outcome;
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI Crop Recommendations generated successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating recommendations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    _phController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(title: 'AI Crop Recommendation'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Hero Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDeep,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Smart Crop Advisor',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Multimodal AI agronomist analyzing soil, season, and live climate.",
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live Weather Banner
                    _buildWeatherBanner(),
                    const SizedBox(height: 16),

                    // Farm Parameters Section
                    Text(
                      'Farm & Crop Parameters :',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFA7F3D0),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  'SOIL TYPE',
                                  _selectedSoilType,
                                  _soilTypes,
                                  (val) => setState(() => _selectedSoilType = val!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown(
                                  'SEASON',
                                  _selectedSeason,
                                  _seasons,
                                  (val) => setState(() => _selectedSeason = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  'WATER SOURCE',
                                  _selectedWater,
                                  _waterSources,
                                  (val) => setState(() => _selectedWater = val!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown(
                                  'PREVIOUS CROP',
                                  _selectedPreviousCrop,
                                  _previousCrops,
                                  (val) => setState(() => _selectedPreviousCrop = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildTextInput(
                            'FARM LAND AREA',
                            _areaController,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Enter area' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Soil Test Health Card Toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _hasMeasuredSoilTest
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Soil Health Card Data',
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _hasMeasuredSoilTest
                                          ? 'Using verified laboratory soil readings'
                                          : 'Using estimated agro-climatic baseline',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _hasMeasuredSoilTest,
                                activeThumbColor: AppColors.primary,
                                onChanged: (val) =>
                                    setState(() => _hasMeasuredSoilTest = val),
                              ),
                            ],
                          ),

                          if (_hasMeasuredSoilTest) ...[
                            const SizedBox(height: 14),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              'Enter Measured Laboratory Soil Nutrients :',
                              style: AppTypography.labelUppercase.copyWith(
                                color: AppColors.primaryDark,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNumberInput(
                                    'N (kg/ha)',
                                    _nController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildNumberInput(
                                    'P (kg/ha)',
                                    _pController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildNumberInput(
                                    'K (kg/ha)',
                                    _kController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildNumberInput(
                                    'pH (0-14)',
                                    _phController,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Generate Button
                    KhedutButton(
                      text: _isGenerating
                          ? 'Generating Multi-Parameter AI Recommendations...'
                          : 'Generate AI Recommendations',
                      onPressed: _isGenerating ? null : _onGenerate,
                    ),
                    const SizedBox(height: 24),

                    // Results List
                    if (_result != null) ...[
                      Text(
                        'AI Recommended Crops for Your Field :',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${_result!.soilMeasurementStatus}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),

                      ..._result!.recommendations.map((item) => _buildRecommendationCard(item)),

                      // Advisory Notice Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFFB45309),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _result!.advisoryNotice,
                                style: AppTypography.bodySmall.copyWith(
                                  color: const Color(0xFF78350F),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      // Placeholder hint before generation
                      Center(
                        child: Text(
                          'Tap "Generate AI Recommendations" to calculate crop viability and net profit.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherBanner() {
    final weather = _liveWeather;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_sunny, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      weather != null ? '${weather.locationName} Weather' : 'Live Farm Weather',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: weather?.isLive == true
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        weather?.isLive == true ? 'Live API' : 'Regional Baseline',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: weather?.isLive == true
                              ? AppColors.primaryDark
                              : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_isLoadingWeather)
                  const Text('Fetching live agrometeorological data...')
                else if (weather != null)
                  Text(
                    '${weather.temperature}°C  |  Humidity: ${weather.humidity}%  |  Rain: ${weather.precipitation} mm  |  ${weather.condition}',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF1E40AF),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  )
                else
                  const Text('Weather forecast ready for analysis'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(CropRecommendationItem item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.cropName,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${item.matchScore}% Match',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Yield & Profit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCol('Expected Yield', item.expectedYield),
              _buildStatCol('Expected Net Profit', item.expectedProfit),
            ],
          ),
          const SizedBox(height: 12),

          // Duration & Market Demand
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCol('Crop Duration', item.durationDays),
              _buildStatCol('Market Demand', item.marketDemand),
            ],
          ),
          const SizedBox(height: 14),

          // Agronomic Reason
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item.whyRecommended,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Precautions
          if (item.precautions.isNotEmpty) ...[
            Text(
              'Key Precautions :',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.primaryDark,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            ...item.precautions.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.primary)),
                    Expanded(
                      child: Text(
                        p,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.primaryDark,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderInput),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextInput(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.primaryDark,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderInput),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderInput),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
