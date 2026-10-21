import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/land_service.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class LandMarketplaceScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const LandMarketplaceScreen({super.key, this.onSwitchTab});

  @override
  State<LandMarketplaceScreen> createState() => _LandMarketplaceScreenState();
}

class _LandMarketplaceScreenState extends State<LandMarketplaceScreen> {
  String _tradeType = 'All'; // 'All', 'Buy', 'Sell'
  bool _nearMeActive = false;
  bool _verifiedActive = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    LandService.instance.addListener(_onLandChanged);
  }

  void _onLandChanged() {
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _allLands => LandService.instance.lands;

  @override
  void dispose() {
    LandService.instance.removeListener(_onLandChanged);
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilter =>
      _tradeType != 'All' ||
      _nearMeActive ||
      _verifiedActive ||
      _searchQuery.isNotEmpty;

  List<Map<String, dynamic>> get _filteredLands {
    return _allLands.where((land) {
      // 1. Trade type filter (Buy / Sell)
      if (_tradeType == 'Buy' && land['type'] != 'Buy') {
        return false;
      }
      if (_tradeType == 'Sell' &&
          land['type'] != 'Sell' &&
          land['type'] != 'Buy') {
        return false;
      }

      // 2. Near Me filter (toggled independently or in combination)
      if (_nearMeActive) {
        final dist = (land['distanceKm'] as num?)?.toDouble() ?? 999.0;
        if (dist > 15.0) return false;
      }

      // 3. Verified filter (toggled independently or in combination)
      if (_verifiedActive) {
        if (land['isVerified'] != true) return false;
      }

      // 4. Search query
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        final matches =
            (land['title'] as String).toLowerCase().contains(q) ||
            (land['location'] as String).toLowerCase().contains(q) ||
            (land['village'] as String).toLowerCase().contains(q) ||
            (land['district'] as String).toLowerCase().contains(q) ||
            (land['soilType'] as String).toLowerCase().contains(q) ||
            (land['crops'] as String).toLowerCase().contains(q);
        if (!matches) return false;
      }

      return true;
    }).toList()..sort((a, b) {
      if (_nearMeActive) {
        final da = (a['distanceKm'] as num?)?.toDouble() ?? 999.0;
        final db = (b['distanceKm'] as num?)?.toDouble() ?? 999.0;
        return da.compareTo(db);
      }
      return 0;
    });
  }

  void _showContactOwnerSheet(Map<String, dynamic> land) {
    final ownerName = land['ownerName'] as String;
    final ownerPhone = land['ownerPhone'] as String;
    final title = land['title'] as String;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Contact Landowner',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '7/12 Verified',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.person, color: AppColors.primaryDark),
              ),
              title: Text(
                ownerName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                ownerPhone,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.call, size: 16),
                label: const Text('Call Now'),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling $ownerName at $ownerPhone...'),
                      backgroundColor: AppColors.primaryDark,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _resetAllFilters() {
    setState(() {
      _tradeType = 'All';
      _nearMeActive = false;
      _verifiedActive = false;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFA7F3D0),
                width: 1.3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? Colors.white : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primaryDark,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lands = _filteredLands;
    final isAllSelected =
        _tradeType == 'All' && !_nearMeActive && !_verifiedActive;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(
        title: 'Land Marketplace',
        subtitle: 'Buy & Sell Agricultural Land | Verified',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Green Card
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
                        Icons.landscape_outlined,
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
                            'Find Perfect Farm Land',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Buy or sell agricultural land easily and securely with AnyRoR verification.',
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

              // Interactive Search Bar - Single Clean Box with no overlapping borders
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _searchQuery.isNotEmpty
                        ? AppColors.primary
                        : const Color(0xFFA7F3D0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _searchQuery.isNotEmpty
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  textAlignVertical: TextAlignVertical.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Village, Taluka, District, Soil...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Interactive Filter Chips: Multi-combinable (Near Me + Verified work together!)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // All Pill
                    _buildFilterPill(
                      label: 'All',
                      isSelected: isAllSelected,
                      onTap: () {
                        setState(() {
                          _tradeType = 'All';
                          _nearMeActive = false;
                          _verifiedActive = false;
                        });
                      },
                    ),

                    // Buy Pill
                    _buildFilterPill(
                      label: 'Buy',
                      isSelected: _tradeType == 'Buy',
                      onTap: () {
                        setState(() {
                          _tradeType = (_tradeType == 'Buy') ? 'All' : 'Buy';
                        });
                      },
                    ),

                    // Sell Pill
                    _buildFilterPill(
                      label: 'Sell',
                      isSelected: _tradeType == 'Sell',
                      onTap: () {
                        setState(() {
                          _tradeType = (_tradeType == 'Sell') ? 'All' : 'Sell';
                        });
                      },
                    ),

                    // Near Me Pill (Toggles independently, combinable with Verified)
                    _buildFilterPill(
                      label: 'Near Me',
                      icon: Icons.near_me,
                      isSelected: _nearMeActive,
                      onTap: () {
                        setState(() {
                          _nearMeActive = !_nearMeActive;
                        });
                      },
                    ),

                    // Verified Pill (Toggles independently, combinable with Near Me)
                    _buildFilterPill(
                      label: 'Verified',
                      icon: Icons.check,
                      isSelected: _verifiedActive,
                      onTap: () {
                        setState(() {
                          _verifiedActive = !_verifiedActive;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Active Filters Notification Banner (When Near Me or Verified is Active)
              if (_nearMeActive || _verifiedActive || _tradeType != 'All') ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tune,
                        color: AppColors.primaryDark,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          [
                            if (_tradeType != 'All') 'Type: $_tradeType',
                            if (_nearMeActive) '📍 Near You (<= 15 km)',
                            if (_verifiedActive) '✓ 7/12 Verified Only',
                          ].join(' • '),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: _resetAllFilters,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Fast Action for "Sell" Filter: Sell Land Banner
              if (_tradeType == 'Sell') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_home_work_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Want to Sell Your Agricultural Land?',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'List for free and connect with genuine local farmers.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/sell_land'),
                        child: const Text(
                          'Post Land',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Results Count Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Properties (${lands.length})',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  if (_hasActiveFilter)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _resetAllFilters,
                      child: const Text(
                        'Reset Filters',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Empty state
              if (lands.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No farm lands found matching your selected filters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: _resetAllFilters,
                        child: const Text('Show All Properties'),
                      ),
                    ],
                  ),
                ),

              // Land Cards List
              ...lands.map((land) {
                final isVerified = land['isVerified'] == true;
                final title = land['title'] as String;
                final location = land['location'] as String;
                final acres = land['acres'] as String;
                final soil = land['soilType'] as String;
                final water = land['waterSource'] as String;
                final crops = land['crops'] as String;
                final price = land['price'] as String;
                final ratePerAcre = land['ratePerAcre'] as String;
                final distance = land['distance'] as String;
                final distanceKm =
                    (land['distanceKm'] as num?)?.toDouble() ?? 0.0;
                final isNearby = distanceKm <= 15.0;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          (_verifiedActive && isVerified) ||
                              (_nearMeActive && isNearby)
                          ? AppColors.primary
                          : const Color(0xFFA7F3D0),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Image Header
                      Stack(
                        children: [
                          Container(
                            height: 130,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2E7D32),
                                  Colors.green.shade800,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(19),
                                topRight: Radius.circular(19),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 10,
                                  bottom: -10,
                                  child: Icon(
                                    Icons.terrain,
                                    size: 100,
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.landscape,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Badges (Verified & Distance)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Row(
                              children: [
                                if (isVerified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.verified,
                                          color: AppColors.primaryDark,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '7/12 VERIFIED',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primaryDark,
                                                fontSize: 10,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isNearby
                                        ? const Color(
                                            0xFF1B5E20,
                                          ).withValues(alpha: 0.85)
                                        : Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isNearby
                                        ? Border.all(
                                            color: const Color(0xFFA7F3D0),
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.near_me,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        distance,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$location  •  $acres  •  $soil',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$water  •  $crops',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  price,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0),
                                    ),
                                  ),
                                  child: Text(
                                    ratePerAcre,
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/land_details',
                                        arguments: land,
                                      );
                                    },
                                    child: Text(
                                      'View Details',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showContactOwnerSheet(land),
                                    child: Text(
                                      'Contact Owner',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),

              // Two Action Buttons: Sell Land & View On Map
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/sell_land'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFA7F3D0),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Sell Your Land',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, '/farmland_maps'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFA7F3D0),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'View on Map',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Need Tractor Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primary, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Tractor for this land?',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Book nearby operators at best hourly rates',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 140,
                        height: 38,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/tractor_hire'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Book',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
