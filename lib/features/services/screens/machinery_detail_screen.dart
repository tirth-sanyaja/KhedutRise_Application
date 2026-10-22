import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/machinery_model.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/services/expense_service.dart';
import '../../../core/services/machinery_service.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class MachineryDetailScreen extends StatefulWidget {
  final MachineryItem machinery;

  const MachineryDetailScreen({super.key, required this.machinery});

  @override
  State<MachineryDetailScreen> createState() => _MachineryDetailScreenState();
}

class _MachineryDetailScreenState extends State<MachineryDetailScreen> {
  late MachineryItem _machinery;

  @override
  void initState() {
    super.initState();
    _machinery = widget.machinery;
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
            content: Text(
              'Calling ${_machinery.provider.name} at $phoneNumber',
            ),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showBookingSheet() {
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
    String implementSelected = _machinery.implementsAttached
        .split(',')
        .first
        .trim();
    bool needDriver = _machinery.withDriver;
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
            final estimatedTotal = _machinery.hourlyRate * hours;
            final isConflicting = MachineryService.instance.hasConflict(
              _machinery.id,
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
                top: 18,
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
                    const SizedBox(height: 14),
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
                                _machinery.name,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${_machinery.provider.name} • ${_machinery.location}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_machinery.hourlyRateFormatted}/hr',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Booking Date
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

                    // Duration Selection
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

                    // Implement Attached
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

                    const SizedBox(height: 14),

                    // Driver Switch
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

                    const SizedBox(height: 14),

                    // Delivery Location Input
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

                    const SizedBox(height: 12),

                    // Conflict Banner
                    if (isConflicting)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
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
                              size: 22,
                            ),
                            const SizedBox(width: 10),
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

                    // Farmer Contact info
                    Text(
                      'Farmer Contact: ${FarmerService.instance.farmerName} (${FarmerService.instance.currentFarmer?.phone ?? '+91 98765 43210'})',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Divider(height: 24),

                    // Booking Summary Bar
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
      machinery: _machinery,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      bookingDate: selectedDate,
      startTime: startTime,
      durationHours: hours,
      implementAttached: implementSelected,
      needDriver: needDriver,
      deliveryPlot: deliveryPlot,
      hourlyRate: _machinery.hourlyRate,
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
              'Date & Time',
              '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} • ${booking.startTime}',
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
                        fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    final isAvailable = _machinery.isAvailable;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KhedutAppBar(
        title: _machinery.name,
        subtitle: '${_machinery.brand} • ${_machinery.category}',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card / Hero View
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF0FDF4),
                            Colors.grey.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAvailable
                              ? const Color(0xFFA7F3D0)
                              : AppColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _machinery.badge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: isAvailable
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _machinery.availabilityText,
                                    style: TextStyle(
                                      color: isAvailable
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.agriculture,
                                  color: AppColors.primaryDark,
                                  size: 42,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _machinery.name,
                                      style: AppTypography.headline.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_machinery.brand} • ${_machinery.hp}',
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Color(0xFFFFB800),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_machinery.provider.rating} (${_machinery.provider.totalBookings} rentals completed)',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Pricing Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Hourly Rental',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_machinery.hourlyRateFormatted} / hr',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.grey.shade300,
                          ),
                          Column(
                            children: [
                              const Text(
                                'Full Day Rental',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_machinery.dailyRateFormatted} / day',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Provider / Owner Card
                    Text(
                      'Machinery Owner & Provider',
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
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFE8F5E9),
                            child: Text(
                              _machinery.provider.name
                                  .split(' ')
                                  .map((e) => e.isNotEmpty ? e[0] : '')
                                  .take(2)
                                  .join(),
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _machinery.provider.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.verified,
                                      color: AppColors.primaryDark,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_machinery.location} (${_machinery.distanceKm} km away)',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _machinery.provider.phone,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFE8F5E9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.call,
                              color: AppColors.primaryDark,
                            ),
                            onPressed: () =>
                                _makePhoneCall(_machinery.provider.phone),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'Overview & Highlights',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _machinery.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Key Specifications
                    Text(
                      'Technical Specifications',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _buildSpecRow('Category', _machinery.category),
                          const Divider(height: 1),
                          _buildSpecRow('Horsepower', _machinery.hp),
                          const Divider(height: 1),
                          _buildSpecRow(
                            'Implements Attached',
                            _machinery.implementsAttached,
                          ),
                          const Divider(height: 1),
                          _buildSpecRow(
                            'Driver / Operator',
                            _machinery.withDriver
                                ? 'Driver Included'
                                : 'Self Driven',
                          ),
                          const Divider(height: 1),
                          _buildSpecRow(
                            'Fuel Policy',
                            _machinery.fuelIncluded
                                ? 'Diesel Included'
                                : 'Diesel Not Included',
                          ),
                          ..._machinery.specifications.entries.map(
                            (e) => Column(
                              children: [
                                const Divider(height: 1),
                                _buildSpecRow(e.key, e.value),
                              ],
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
          ),
        ),

        // Sticky Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_machinery.hourlyRateFormatted} / hr',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            isAvailable
                                ? 'Available for instant booking'
                                : 'Currently booked today',
                            style: TextStyle(
                              color: isAvailable
                                  ? Colors.green.shade700
                                  : Colors.orange.shade800,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable
                            ? AppColors.primary
                            : Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isAvailable ? _showBookingSheet : null,
                      child: Text(
                        isAvailable ? 'Book Now' : 'Not Available',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
