import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/expense_service.dart';
import '../../../core/services/farmer_service.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class FarmExpensesScreen extends StatefulWidget {
  const FarmExpensesScreen({super.key});

  @override
  State<FarmExpensesScreen> createState() => _FarmExpensesScreenState();
}

class _FarmExpensesScreenState extends State<FarmExpensesScreen> {
  String _selectedCategoryFilter = 'All';

  static const List<String> _categories = [
    'Seeds',
    'Fertilizer',
    'Machinery',
    'Pesticide',
    'Labour',
    'Irrigation',
    'Fuel',
    'Other',
  ];

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Fertilizer';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
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
                    Text(
                      'Add New Expense',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Record costs to keep accurate farm accounts and profit tracking.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Expense Title
                    Text(
                      'EXPENSE TITLE *',
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g. DAP Fertilizer (2 Bags)',
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
                    ),
                    const SizedBox(height: 14),

                    // Amount
                    Text(
                      'AMOUNT (₹) *',
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                        hintText: 'e.g. 2700',
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
                    ),
                    const SizedBox(height: 14),

                    // Category Dropdown
                    Text(
                      'CATEGORY *',
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1.2,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primaryDark,
                          ),
                          items: _categories.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Icon(
                                    _categoryIcon(c),
                                    size: 18,
                                    color: AppColors.primaryDark,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    c,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() => selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date Picker
                    Text(
                      'DATE',
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${selectedDate.day} ${_monthShort(selectedDate.month)} ${selectedDate.year}',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.primaryDark,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final title = titleController.text.trim();
                          final cleanAmount = amountController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          final amount = int.tryParse(cleanAmount) ?? 0;

                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter an expense title'),
                                backgroundColor: AppColors.errorRed,
                              ),
                            );
                            return;
                          }

                          if (amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid amount'),
                                backgroundColor: AppColors.errorRed,
                              ),
                            );
                            return;
                          }

                          final dateStr =
                              '${selectedDate.day} ${_monthShort(selectedDate.month)} ${selectedDate.year}';
                          ExpenseService.instance.addExpense(
                            title: title,
                            category: selectedCategory,
                            amount: amount,
                            date: dateStr,
                          );

                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added ₹${ExpenseService.formatAmount(amount)} for $title! Total is now ${ExpenseService.instance.totalExpenseFormatted}',
                              ),
                              backgroundColor: AppColors.primaryDark,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text(
                          'Add Expense',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
        );
      },
    );
  }

  void _confirmDeleteExpense(ExpenseItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete Expense?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to remove "${item.title}" (${item.formattedAmount})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ExpenseService.instance.removeExpense(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Expense removed. Total is now ${ExpenseService.instance.totalExpenseFormatted}',
                  ),
                  backgroundColor: AppColors.primaryDark,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'seeds':
        return Icons.eco_outlined;
      case 'fertilizer':
        return Icons.science_outlined;
      case 'machinery':
        return Icons.agriculture_outlined;
      case 'pesticide':
        return Icons.pest_control_outlined;
      case 'labour':
        return Icons.group_outlined;
      case 'irrigation':
        return Icons.water_drop_outlined;
      case 'fuel':
        return Icons.local_gas_station_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  static String _monthShort(int month) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 1 && month <= 12) return m[month - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final farmer = FarmerService.instance.currentFarmer;
    final plotText = farmer?.village.isNotEmpty == true
        ? 'For Cotton Crop (Vishvas Plot A, ${farmer!.village}) • Kharif 2026'
        : 'For Cotton Crop (Plot A) • Kharif 2026';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(
        title: 'Farm Expenses',
        subtitle: 'Track season input costs & machine rents',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white, size: 22),
        label: const Text(
          'Add Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ExpenseService.instance,
          builder: (context, _) {
            final allExpenses = ExpenseService.instance.expenses;
            final totalFormatted =
                ExpenseService.instance.totalExpenseFormatted;
            final count = allExpenses.length;
            final avgFormatted = count > 0
                ? '₹${ExpenseService.formatAmount((ExpenseService.instance.totalExpense / count).round())}'
                : '₹0';

            final filteredExpenses = _selectedCategoryFilter == 'All'
                ? allExpenses
                : allExpenses
                      .where((e) => e.category == _selectedCategoryFilter)
                      .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Crop Expense Banner - Updates Dynamically!
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF064E3B), Color(0xFF047857)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x331B5E20),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL CROP EXPENSE',
                              style: AppTypography.labelUppercase.copyWith(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x2EFFFFFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$count entries',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // DYNAMIC TOTAL
                        Text(
                          totalFormatted,
                          style: AppTypography.display.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          plotText,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Average / Item',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  avgFormatted,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Season Budget Used',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  count > 0
                                      ? '${((ExpenseService.instance.totalExpense / 50000) * 100).clamp(0, 100).toStringAsFixed(1)}%'
                                      : '0%',
                                  style: const TextStyle(
                                    color: Color(0xFF6EE7B7),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', ..._categories].map((cat) {
                        final isSelected = _selectedCategoryFilter == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedCategoryFilter = cat);
                            },
                            selectedColor: AppColors.primaryLight,
                            backgroundColor: Colors.grey.shade50,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expense Details Header with count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expense Details',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${filteredExpenses.length} ${filteredExpenses.length == 1 ? 'record' : 'records'}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Empty State or Expense List Cards
                  if (filteredExpenses.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 20,
                      ),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedCategoryFilter == 'All'
                                ? 'No farm expenses recorded yet'
                                : 'No expenses under "$_selectedCategoryFilter"',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap the button below to add seeds, machinery, or fertilizer costs.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _showAddExpenseDialog,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add First Expense'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredExpenses.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Category Icon Pill
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _categoryIcon(item.category),
                                color: AppColors.primaryDark,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Title & Category/Date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Category: ${item.category} • ${item.date}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Amount and Delete Button
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.formattedAmount,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: const Color(0xFFB91C1C),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                InkWell(
                                  onTap: () => _confirmDeleteExpense(item),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
        ),
      ),
    );
  }
}
