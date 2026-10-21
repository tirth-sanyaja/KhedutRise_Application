import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/machinery_model.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/services/expense_service.dart';
import '../../../core/services/machinery_service.dart';
import '../../../core/widgets/khedut_app_bar.dart';
import 'machinery_detail_screen.dart';

class TractorHireScreen extends StatefulWidget {
  final int initialTabIndex;

  const TractorHireScreen({super.key, this.initialTabIndex = 0});

  @override
  State<TractorHireScreen> createState() => _TractorHireScreenState();
}

class _TractorHireScreenState extends State<TractorHireScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _bookingFilter = 'All';

  final List<String> _categories = [
    'All',
    'Tractor',
    'Tractors (40-55 HP)',
    'Mini Tractors',
    'Drone Sprayer',
    'Rotavator',
    'Cultivator',
    'Seed Drill',
    'Harvester',
    'Baler & Loader',
    'Implements',
    'Other Farm Machinery',
  ];

  final List<String> _bookingFilters = [
    'All',
    'Upcoming',
    'Active',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dialer opened for $phoneNumber'),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<MachineryItem> get _filteredMachinery {
    final all = MachineryService.instance.machineries;
    return all.where((item) {
      bool matchesCategory = true;
      final hpMatch = RegExp(r'(\d+)').firstMatch(item.hp);
      final hpVal = hpMatch != null ? int.tryParse(hpMatch.group(1)!) ?? 0 : 0;
      final nameLower = item.name.toLowerCase();
      final categoryLower = item.category.toLowerCase();
      final implementsLower = item.implementsAttached.toLowerCase();
      final badgeLower = item.badge.toLowerCase();

      switch (_selectedCategory) {
        case 'All':
          matchesCategory = true;
          break;
        case 'Tractor':
          matchesCategory = item.category == 'Tractor';
          break;
        case 'Tractors (40-55 HP)':
          matchesCategory =
              item.category == 'Tractor' && hpVal >= 40 && hpVal <= 55;
          break;
        case 'Mini Tractors':
          matchesCategory =
              (item.category == 'Tractor' && hpVal > 0 && hpVal <= 30) ||
              nameLower.contains('mini') ||
              badgeLower.contains('mini');
          break;
        case 'Drone Sprayer':
          matchesCategory =
              nameLower.contains('drone') || badgeLower.contains('drone');
          break;
        case 'Rotavator':
          matchesCategory =
              categoryLower == 'rotavator' ||
              nameLower.contains('rotavator') ||
              implementsLower.contains('rotavator');
          break;
        case 'Cultivator':
          matchesCategory =
              categoryLower == 'cultivator' ||
              nameLower.contains('cultivator') ||
              implementsLower.contains('cultivator') ||
              implementsLower.contains('plough');
          break;
        case 'Seed Drill':
          matchesCategory =
              categoryLower == 'seed drill' ||
              nameLower.contains('seed drill') ||
              nameLower.contains('seeder') ||
              implementsLower.contains('seed') ||
              implementsLower.contains('seeder');
          break;
        case 'Harvester':
          matchesCategory =
              categoryLower == 'harvester' || nameLower.contains('harvester');
          break;
        case 'Baler & Loader':
          matchesCategory =
              nameLower.contains('baler') ||
              nameLower.contains('jcb') ||
              nameLower.contains('loader') ||
              badgeLower.contains('baler');
          break;
        case 'Implements':
          matchesCategory =
              item.category == 'Rotavator' ||
              item.category == 'Cultivator' ||
              item.category == 'Seed Drill' ||
              (item.implementsAttached.isNotEmpty &&
                  item.category != 'Tractor');
          break;
        case 'Other Farm Machinery':
          matchesCategory =
              item.category == 'Other Farm Machinery' ||
              nameLower.contains('drone') ||
              nameLower.contains('leveler') ||
              nameLower.contains('baler') ||
              nameLower.contains('jcb') ||
              nameLower.contains('sprayer') ||
              nameLower.contains('tiller') ||
              nameLower.contains('weeder') ||
              nameLower.contains('thresher');
          break;
        default:
          matchesCategory = categoryLower == _selectedCategory.toLowerCase();
      }

      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.brand.toLowerCase().contains(query) ||
          item.implementsAttached.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          item.provider.name.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<MachineryBooking> get _filteredBookings {
    final all = MachineryService.instance.bookings;
    switch (_bookingFilter) {
      case 'Upcoming':
        return all.where((b) => b.status == BookingStatus.confirmed).toList();
      case 'Active':
        return all.where((b) => b.status == BookingStatus.active).toList();
      case 'Completed':
        return all.where((b) => b.status == BookingStatus.completed).toList();
      case 'Cancelled':
        return all.where((b) => b.status == BookingStatus.cancelled).toList();
      default:
        return all;
    }
  }

  void _showBookingSheet(MachineryItem item) {
    int hours = 4;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String startTime = '08:00 AM';
    final startTimes = [
      '06:00 AM',
      '08:00 AM',
      '10:00 AM',
      '01:00 PM',
      '03:00 PM',
      '05:00 PM',
    ];
    String implementSelected = item.implementsAttached.split(',').first.trim();
    bool needDriver = item.withDriver;
    final farmerLoc =
        FarmerService.instance.currentFarmer?.village.isNotEmpty == true
        ? 'Vishvas Plot A, ${FarmerService.instance.currentFarmer!.village}'
        : 'Vishvas Plot A, Sardhar';
    String deliveryPlot = farmerLoc;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final estimatedTotal = item.hourlyRate * hours;
            final isConflicting = MachineryService.instance.hasConflict(
              item.id,
              selectedDate,
              startTime,
              hours,
            );

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            color: AppColors.primaryDark,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${item.provider.name} • ${item.location}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.hourlyRateFormatted}/hr',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    Text(
                      'Booking Date',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (picked != null) {
                          setSheetState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Change',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Start Time Selection
                    Text(
                      'Start Time Slot',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: startTimes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final time = startTimes[index];
                          final isSel = startTime == time;
                          return ChoiceChip(
                            label: Text(time),
                            selected: isSel,
                            onSelected: (_) {
                              setSheetState(() => startTime = time);
                            },
                            selectedColor: AppColors.primaryDark,
                            backgroundColor: Colors.grey.shade100,
                            labelStyle: TextStyle(
                              color: isSel
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: isSel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            showCheckmark: false,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Required Duration (Hours)',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [2, 4, 6, 8].map((h) {
                        final isSel = hours == h;
                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              setSheetState(() => hours = h);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primary : Colors.white,
                                border: Border.all(
                                  color: isSel
                                      ? AppColors.primary
                                      : AppColors.borderLight,
                                  width: 1.2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$h hrs',
                                style: TextStyle(
                                  color: isSel
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Implement Attached',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      implementSelected,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Include Operator/Driver',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Switch(
                          value: needDriver,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            setSheetState(() => needDriver = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Farm Plot / Delivery Location *',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: deliveryPlot,
                      decoration: InputDecoration(
                        hintText: 'Enter farm plot or delivery address',
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryDark,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                            width: 1.2,
                          ),
                        ),
                      ),
                      onChanged: (val) => deliveryPlot = val,
                    ),

                    if (isConflicting) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.errorRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This machinery is already booked on this date at $startTime. Please pick another date or time slot.',
                                style: const TextStyle(
                                  color: Color(0xFF991B1B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),
                    Text(
                      'Farmer Contact: ${FarmerService.instance.farmerName} (${FarmerService.instance.currentFarmer?.phone ?? '+91 98765 43210'})',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estimated Fare',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '₹$estimatedTotal',
                                style: AppTypography.headline.copyWith(
                                  color: AppColors.primaryDark,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isConflicting
                                ? Colors.grey.shade400
                                : AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isConflicting
                              ? null
                              : () {
                                  if (deliveryPlot.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a delivery plot location',
                                        ),
                                        backgroundColor: AppColors.errorRed,
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.pop(ctx);
                                  _processBooking(
                                    item: item,
                                    selectedDate: selectedDate,
                                    startTime: startTime,
                                    hours: hours,
                                    needDriver: needDriver,
                                    implementSelected: implementSelected,
                                    deliveryPlot: deliveryPlot,
                                    estimatedTotal: estimatedTotal,
                                  );
                                },
                          child: const Text(
                            'Confirm Booking',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _processBooking({
    required MachineryItem item,
    required DateTime selectedDate,
    required String startTime,
    required int hours,
    required bool needDriver,
    required String implementSelected,
    required String deliveryPlot,
    required int estimatedTotal,
  }) {
    final farmerName = FarmerService.instance.farmerName;
    final farmerPhone =
        FarmerService.instance.currentFarmer?.phone ?? '+91 98765 43210';

    final booking = MachineryService.instance.createBooking(
      machinery: item,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      bookingDate: selectedDate,
      startTime: startTime,
      durationHours: hours,
      implementAttached: implementSelected,
      needDriver: needDriver,
      deliveryPlot: deliveryPlot,
      hourlyRate: item.hourlyRate,
      totalAmount: estimatedTotal,
    );

    _showBookingConfirmationDialog(booking);
  }

  void _showBookingConfirmationDialog(MachineryBooking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Booking Confirmed!',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Booking ID: #${booking.id}',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Divider(height: 24),
            _buildConfirmationRow('Equipment', booking.machineryName),
            _buildConfirmationRow(
              'Owner',
              '${booking.ownerName} (${booking.ownerPhone})',
            ),
            _buildConfirmationRow('Farmer', booking.farmerName),
            _buildConfirmationRow(
              'Date',
              '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
            ),
            _buildConfirmationRow(
              'Duration',
              '${booking.durationHours} Hours (${booking.needDriver ? 'With Driver' : 'Without Driver'})',
            ),
            _buildConfirmationRow('Delivery To', booking.deliveryPlot),
            const Divider(height: 18),
            _buildConfirmationRow(
              'Total Fare',
              '₹${booking.totalAmount}',
              isBold: true,
            ),
            const SizedBox(height: 14),
            Text(
              'The equipment partner will contact you shortly to coordinate arrival.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text(
                      'Add to Expenses',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      ExpenseService.instance.addExpense(
                        title: 'Tractor Hire (${booking.machineryName})',
                        category: 'Machinery',
                        amount: booking.totalAmount,
                        date:
                            '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Added ₹${booking.totalAmount} to Farm Expenses! Total is now ${ExpenseService.instance.totalExpenseFormatted}',
                          ),
                          backgroundColor: AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildConfirmationRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
                color: isBold ? AppColors.primaryDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelBookingDialog(MachineryBooking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Booking?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to cancel booking #${booking.id} for ${booking.machineryName}?\n\nNo cancellation fee will be charged.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Keep Booking',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              MachineryService.instance.cancelBooking(booking.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking #${booking.id} has been cancelled.'),
                  backgroundColor: AppColors.errorRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Cancel Booking',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MachineryService.instance,
      builder: (context, _) {
        final list = _filteredMachinery;
        final totalBookings = MachineryService.instance.bookings.length;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const KhedutAppBar(
            title: 'Tractor & Machinery Hire',
            subtitle: 'Verified Equipment Near Your Farm',
            showBackButton: true,
          ),
          body: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderLight, width: 1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primaryDark,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  tabs: [
                    const Tab(text: 'Browse Machinery'),
                    Tab(text: 'My Bookings ($totalBookings)'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: BROWSE MACHINERY
                    _buildBrowseTab(list),

                    // TAB 2: MY BOOKINGS
                    _buildMyBookingsTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrowseTab(List<MachineryItem> list) {
    return SafeArea(
      child: Column(
        children: [
          // Location Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: const Color(0xFFF0FDF4),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.primaryDark,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Serving: Sardhar, Rajkot (Within 15 km)',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Text(
                    'Live GPS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search tractor model, rotavator, harvester...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryDark,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                fillColor: Colors.grey.shade50,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  selectedColor: AppColors.primaryDark,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.borderLight,
                    ),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Equipment List
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No machinery found for "$_searchQuery"',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final isAvailable = item.isAvailable;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isAvailable
                                ? const Color(0xFFA7F3D0)
                                : AppColors.borderLight,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top badge bar
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? const Color(0xFFF0FDF4)
                                    : Colors.grey.shade50,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryDark,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            item.badge,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            item.hp,
                                            style: const TextStyle(
                                              color: AppColors.primaryDark,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: isAvailable
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.availabilityText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isAvailable
                                              ? Colors.green.shade800
                                              : Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.agriculture,
                                          color: AppColors.primaryDark,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: AppTypography.titleSmall
                                                  .copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                  ),
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Color(0xFFFFB800),
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '${item.provider.rating} (${item.provider.totalBookings} bookings)',
                                                  style: AppTypography.bodySmall
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 11,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    '• ${item.provider.name}',
                                                    style: AppTypography
                                                        .bodySmall
                                                        .copyWith(
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontSize: 11,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              item.location,
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 11,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.build_circle_outlined,
                                          size: 16,
                                          color: AppColors.primaryDark,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Implements: ${item.implementsAttached}',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${item.hourlyRateFormatted} / hr',
                                              style: AppTypography.titleMedium
                                                  .copyWith(
                                                    color:
                                                        AppColors.primaryDark,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 18,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'or ${item.dailyRateFormatted} / day',
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 11,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => _makePhoneCall(
                                              item.provider.phone,
                                            ),
                                            style: IconButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFE8F5E9,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.call,
                                              color: AppColors.primaryDark,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: AppColors.primary,
                                              ),
                                              foregroundColor:
                                                  AppColors.primaryDark,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10,
                                                  ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      MachineryDetailScreen(
                                                        machinery: item,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Details',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isAvailable
                                                  ? AppColors.primary
                                                  : Colors.grey.shade400,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                            ),
                                            onPressed: isAvailable
                                                ? () => _showBookingSheet(item)
                                                : null,
                                            child: const Text(
                                              'Book Now',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBookingsTab() {
    final bookings = _filteredBookings;

    return Column(
      children: [
        // Sub-filter tabs
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _bookingFilters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _bookingFilters[index];
              final isSel = _bookingFilter == filter;
              return ChoiceChip(
                label: Text(filter),
                selected: isSel,
                onSelected: (_) => setState(() => _bookingFilter = filter),
                selectedColor: AppColors.primaryDark,
                backgroundColor: Colors.grey.shade100,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                showCheckmark: false,
              );
            },
          ),
        ),

        // Bookings List
        Expanded(
          child: bookings.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No $_bookingFilter Bookings Found',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Rent verified tractors, rotavators, and harvesters for your farm plots.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.agriculture, size: 18),
                          label: const Text(
                            'Browse Machinery',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            _tabController.animateTo(0);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    Color statusColor;
                    Color statusBg;
                    switch (booking.status) {
                      case BookingStatus.confirmed:
                        statusColor = Colors.green.shade800;
                        statusBg = const Color(0xFFDCFCE7);
                        break;
                      case BookingStatus.active:
                        statusColor = Colors.blue.shade800;
                        statusBg = const Color(0xFFDBEAFE);
                        break;
                      case BookingStatus.completed:
                        statusColor = Colors.grey.shade800;
                        statusBg = Colors.grey.shade200;
                        break;
                      case BookingStatus.cancelled:
                        statusColor = Colors.red.shade800;
                        statusBg = const Color(0xFFFEE2E2);
                        break;
                    }

                    final canCancel =
                        booking.status == BookingStatus.confirmed ||
                        booking.status == BookingStatus.active;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Booking ID and Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.receipt,
                                      size: 16,
                                      color: AppColors.primaryDark,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '#${booking.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    booking.statusDisplay,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),

                            // Machinery Info
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.agriculture,
                                    color: AppColors.primaryDark,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.machineryName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        'Owner: ${booking.ownerName} (${booking.ownerPhone})',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Details Grid
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildBookingDetailRow(
                                    'Date & Time',
                                    '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} • ${booking.startTime}',
                                  ),
                                  const SizedBox(height: 6),
                                  _buildBookingDetailRow(
                                    'Duration',
                                    '${booking.durationHours} Hours (${booking.needDriver ? 'With Driver' : 'Self Driven'})',
                                  ),
                                  const SizedBox(height: 6),
                                  _buildBookingDetailRow(
                                    'Delivery Plot',
                                    booking.deliveryPlot,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildBookingDetailRow(
                                    'Total Amount',
                                    '₹${booking.totalAmount}',
                                    isBold: true,
                                  ),
                                  if (booking.cancellationReason != null) ...[
                                    const SizedBox(height: 6),
                                    _buildBookingDetailRow(
                                      'Cancellation',
                                      booking.cancellationReason!,
                                      isWarning: true,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Action Buttons
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    foregroundColor: AppColors.primaryDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: const Icon(Icons.call, size: 14),
                                  label: const Text(
                                    'Call Owner',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _makePhoneCall(booking.ownerPhone),
                                ),
                                const SizedBox(width: 8),
                                if (canCancel)
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.errorRed,
                                      ),
                                      foregroundColor: AppColors.errorRed,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showCancelBookingDialog(booking),
                                    child: const Text(
                                      'Cancel Booking',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                if (booking.status != BookingStatus.cancelled)
                                  IconButton(
                                    tooltip: 'Add to Expenses',
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFFE8F5E9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.receipt_long,
                                      color: AppColors.primaryDark,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      ExpenseService.instance.addExpense(
                                        title:
                                            'Tractor Hire (${booking.machineryName})',
                                        category: 'Machinery',
                                        amount: booking.totalAmount,
                                        date:
                                            '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added ₹${booking.totalAmount} to Farm Expenses!',
                                          ),
                                          backgroundColor:
                                              AppColors.primaryDark,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookingDetailRow(
    String label,
    String value, {
    bool isBold = false,
    bool isWarning = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12,
              color: isWarning
                  ? AppColors.errorRed
                  : (isBold ? AppColors.primaryDark : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
