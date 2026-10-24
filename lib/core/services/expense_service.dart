import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class ExpenseItem {
  final String id;
  final String title;
  final String category;
  final String date;
  final int amount;
  final String notes;

  const ExpenseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    this.notes = '',
  });

  String get formattedAmount => '₹${ExpenseService.formatAmount(amount)}';

  ExpenseItem copyWith({
    String? id,
    String? title,
    String? category,
    String? date,
    int? amount,
    String? notes,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }
}

class ExpenseService extends ChangeNotifier {
  ExpenseService._internal() {
    _loadInitialExpenses();
  }

  static final ExpenseService instance = ExpenseService._internal();

  final List<ExpenseItem> _expenses = [];

  List<ExpenseItem> get expenses => List.unmodifiable(_expenses);

  void _loadInitialExpenses() {
    _expenses.addAll([
      const ExpenseItem(
        id: 'exp-1',
        title: 'Cotton Seeds Purchase',
        category: 'Seeds',
        date: '15 July 2026',
        amount: 4000,
      ),
      const ExpenseItem(
        id: 'exp-2',
        title: 'Tractor Rental (Ploughing)',
        category: 'Machinery',
        date: '18 July 2026',
        amount: 5500,
      ),
      const ExpenseItem(
        id: 'exp-3',
        title: 'NPK 19-19-19 Fertilizer',
        category: 'Fertilizer',
        date: '22 July 2026',
        amount: 3000,
      ),
    ]);
  }

  /// Total sum of all expenses in integer
  int get totalExpense =>
      _expenses.fold<int>(0, (sum, item) => sum + item.amount);

  /// Total sum formatted in Indian Currency representation (e.g. ₹12,500)
  String get totalExpenseFormatted => '₹${formatAmount(totalExpense)}';

  /// Add a new expense item and notify listeners so UI updates instantly
  void addExpense({
    required String title,
    required String category,
    required int amount,
    String? date,
    String? notes,
  }) {
    final now = DateTime.now();
    final defaultDate = '${now.day} ${_monthName(now.month)} ${now.year}';
    final newItem = ExpenseItem(
      id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      category: category.trim().isNotEmpty ? category.trim() : 'General',
      date: date ?? defaultDate,
      amount: amount,
      notes: notes ?? '',
    );

    _expenses.insert(0, newItem);
    FirestoreService.instance.saveExpense({
      'id': newItem.id,
      'title': newItem.title,
      'category': newItem.category,
      'date': newItem.date,
      'amount': newItem.amount,
      'notes': newItem.notes,
    });
    notifyListeners();
  }

  /// Remove an expense item by id
  void removeExpense(String id) {
    _expenses.removeWhere((item) => item.id == id);
    FirestoreService.instance.deleteExpense(id);
    notifyListeners();
  }

  /// Reset to seed data
  void resetToDefaults() {
    _expenses.clear();
    _loadInitialExpenses();
    notifyListeners();
  }

  /// Utility to format Indian numbers (e.g. 12500 -> 12,500, 100000 -> 1,00,000)
  static String formatAmount(int amount) {
    final str = amount.abs().toString();
    if (str.length <= 3) {
      return amount < 0 ? '-$str' : str;
    }
    final lastThree = str.substring(str.length - 3);
    final otherNumbers = str.substring(0, str.length - 3);
    final formattedOther = otherNumbers.replaceAllMapped(
      RegExp(r'\B(?=(\d{2})+(?!\d))'),
      (match) => ',',
    );
    final result = '$formattedOther,$lastThree';
    return amount < 0 ? '-$result' : result;
  }

  static String _monthName(int month) {
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
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
