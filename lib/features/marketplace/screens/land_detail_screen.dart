import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class LandDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? landData;

  const LandDetailScreen({super.key, this.landData});

  void _showContactModal(
    BuildContext context,
    String ownerName,
    String ownerPhone,
    String location,
  ) {
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
            Text(
              'Contact Land Seller',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.person, color: AppColors.primaryDark),
              ),
              title: Text(
                ownerName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('$location • Verified Landowner'),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.call, size: 16),
                label: const Text('Call'),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling $ownerName ($ownerPhone)...'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primaryDark,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVisitBooking(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Schedule Land Visit',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Our rural field coordinator will assist you with free on-site farm boundary inspection and 7/12 document verification.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Visit appointment scheduled for tomorrow 11:00 AM!',
                  ),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            },
            child: const Text('Book Visit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> data =
        landData ??
        (routeArgs is Map<String, dynamic> ? routeArgs : null) ??
        {
          'title': 'Green Farm Land - Sardhar',
          'location': 'Sardhar Taluka, Rajkot District',
          'acres': '5.0 Acres (20 Vigha)',
          'price': '₹32,00,000',
          'ratePerAcre': '₹6,40,000 / Acre',
          'soilType': 'Deep Black Cotton',
          'waterSource': '1 Borewell + Canal',
          'powerSupply': '3-Phase AG 5HP',
          'roadAccess': '18ft Pucca Road',
          'ownerName': 'Mansukhbhai Vekariya',
          'ownerPhone': '+91 98251 77665',
          'crops': 'Cotton, Groundnut, Cumin (Jeeru), Wheat',
          'distance': '9.5 km to Gondal / Rajkot APMC',
          'isVerified': true,
        };

    final title = data['title'] as String? ?? 'Green Farm Land - Sardhar';
    final location =
        data['location'] as String? ?? 'Sardhar Taluka, Rajkot District';
    final acres = data['acres'] as String? ?? '5.0 Acres (20 Vigha)';
    final price = data['price'] as String? ?? '₹32,00,000';
    final ratePerAcre = data['ratePerAcre'] as String? ?? '₹6,40,000 / Acre';
    final soilType = data['soilType'] as String? ?? 'Deep Black Cotton';
    final waterSource = data['waterSource'] as String? ?? '1 Borewell + Canal';
    final powerSupply = data['powerSupply'] as String? ?? '3-Phase AG 5HP';
    final roadAccess = data['roadAccess'] as String? ?? '18ft Pucca Road';
    final ownerName = data['ownerName'] as String? ?? 'Mansukhbhai Vekariya';
    final ownerPhone = data['ownerPhone'] as String? ?? '+91 98251 77665';
    final crops =
        data['crops'] as String? ?? 'Cotton, Groundnut, Cumin (Jeeru), Wheat';
    final distance =
        data['distance'] as String? ?? '9.5 km to Gondal / Rajkot APMC';
    final isVerified = data['isVerified'] as bool? ?? true;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(
        title: 'Land Details',
        subtitle: 'Verified Agricultural Property',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image / Graphic Container
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.landscape,
                        size: 160,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '7/12 ANYROR VERIFIED',
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Clear Title',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTypography.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$location • $acres',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Price & Quick specs bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Demand Price',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          price,
                          style: AppTypography.headline.copyWith(
                            color: AppColors.primaryDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Rate per Acre',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          ratePerAcre,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Key Highlights Grid
              Text(
                'Property Highlights',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _buildHighlightTile(Icons.terrain, 'Soil Type', soilType),
                  _buildHighlightTile(
                    Icons.water_drop,
                    'Water Source',
                    waterSource,
                  ),
                  _buildHighlightTile(
                    Icons.electric_bolt,
                    'Power Supply',
                    powerSupply,
                  ),
                  _buildHighlightTile(
                    Icons.add_road,
                    'Road Access',
                    roadAccess,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Agronomic Details
              Text(
                'Suitable Crops & Irrigation',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSpecRow(
                      'Primary Season',
                      'Kharif & Rabi Dual Season',
                    ),
                    _buildSpecRow('Best Yield Crops', crops),
                    _buildSpecRow(
                      'Water Table Level',
                      '160 - 180 feet (High recharge zone)',
                    ),
                    _buildSpecRow('Distance to APMC Mandi', distance),
                    _buildSpecRow(
                      'Legal Title',
                      isVerified
                          ? '100% 7/12 Clear AnyRoR Title'
                          : 'Direct Landowner Title',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Seller Profile
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.person, color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ownerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Direct Landowner • Member since 2024',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.call,
                        color: AppColors.primaryDark,
                      ),
                      onPressed: () => _showContactModal(
                        context,
                        ownerName,
                        ownerPhone,
                        location,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.event_available,
                        color: AppColors.primaryDark,
                      ),
                      label: const Text(
                        'Book Visit',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => _showVisitBooking(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.phone),
                      label: const Text(
                        'Contact Owner',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => _showContactModal(
                        context,
                        ownerName,
                        ownerPhone,
                        location,
                      ),
                    ),
                  ),
                ],
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

  static Widget _buildHighlightTile(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
