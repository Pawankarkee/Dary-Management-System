import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../services/hive_service.dart';

class ExpenseController extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> _filteredExpenses = [];
  bool _isLoading = false;
  String _searchQuery = '';
  ExpenseCategory? _selectedCategory;
  PaymentMethod? _selectedPaymentMethod;
  DateTimeRange? _selectedDateRange;

  List<ExpenseModel> get expenses => _searchQuery.isEmpty && _selectedCategory == null && _selectedPaymentMethod == null && _selectedDateRange == null
      ? _expenses
      : _filteredExpenses;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  ExpenseCategory? get selectedCategory => _selectedCategory;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  // Load all expenses
  Future<void> loadExpenses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final box = await HiveService.getExpensesBox();
      _expenses = box.values.map((e) {
        if (e is Map) {
          return ExpenseModel.fromJson(Map<String, dynamic>.from(e));
        }
        return e as ExpenseModel;
      }).toList();

      // Sort by expense date (newest first)
      _expenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

      _filteredExpenses = _expenses;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading expenses: $e');
      rethrow;
    }
  }

  // Add new expense
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final box = await HiveService.getExpensesBox();
      await box.put(expense.id, expense.toJson());
      await loadExpenses();
      debugPrint('Expense added: ${expense.id}');
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  // Update expense
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      final box = await HiveService.getExpensesBox();
      expense.updatedAt = DateTime.now();
      await box.put(expense.id, expense.toJson());
      await loadExpenses();
      debugPrint('Expense updated: ${expense.id}');
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      final box = await HiveService.getExpensesBox();
      await box.delete(expenseId);
      await loadExpenses();
      debugPrint('Expense deleted: $expenseId');
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  // Get expense by ID
  ExpenseModel? getExpenseById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search expenses
  void searchExpenses(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  // Filter by category
  void filterByCategory(ExpenseCategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Filter by payment method
  void filterByPaymentMethod(PaymentMethod? method) {
    _selectedPaymentMethod = method;
    _applyFilters();
  }

  // Filter by date range
  void filterByDateRange(DateTimeRange? range) {
    _selectedDateRange = range;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedPaymentMethod = null;
    _selectedDateRange = null;
    _filteredExpenses = _expenses;
    notifyListeners();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredExpenses = _expenses.where((expense) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = expense.title.toLowerCase().contains(_searchQuery) ||
            expense.description.toLowerCase().contains(_searchQuery) ||
            (expense.paidTo?.toLowerCase().contains(_searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // Category filter
      if (_selectedCategory != null && expense.category != _selectedCategory) {
        return false;
      }

      // Payment method filter
      if (_selectedPaymentMethod != null && expense.paymentMethod != _selectedPaymentMethod) {
        return false;
      }

      // Date range filter
      if (_selectedDateRange != null) {
        final startDate = _selectedDateRange!.start;
        final endDate = _selectedDateRange!.end;
        if (expense.expenseDate.isBefore(startDate) || expense.expenseDate.isAfter(endDate)) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Get expenses by category
  List<ExpenseModel> getExpensesByCategory(ExpenseCategory category) {
    return _expenses.where((e) => e.category == category).toList();
  }

  // Get expenses by date range
  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses.where((e) {
      return e.expenseDate.isAfter(start.subtract(const Duration(days: 1))) &&
          e.expenseDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get recurring expenses
  List<ExpenseModel> getRecurringExpenses() {
    return _expenses.where((e) => e.isRecurring).toList();
  }

  // Get today's expenses
  List<ExpenseModel> getTodaysExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _expenses.where((e) {
      return e.expenseDate.isAfter(today.subtract(const Duration(seconds: 1))) &&
          e.expenseDate.isBefore(tomorrow);
    }).toList();
  }

  // Get this month's expenses
  List<ExpenseModel> getThisMonthExpenses() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getExpensesByDateRange(firstDayOfMonth, lastDayOfMonth);
  }

  // Get expense statistics
  Map<String, dynamic> getExpenseStatistics() {
    final totalExpenses = _expenses.length;
    final totalAmount = _expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Category-wise breakdown
    final categoryBreakdown = <ExpenseCategory, double>{};
    for (var expense in _expenses) {
      categoryBreakdown[expense.category] = 
          (categoryBreakdown[expense.category] ?? 0.0) + expense.amount;
    }

    // Payment method breakdown
    final paymentMethodBreakdown = <PaymentMethod, double>{};
    for (var expense in _expenses) {
      paymentMethodBreakdown[expense.paymentMethod] = 
          (paymentMethodBreakdown[expense.paymentMethod] ?? 0.0) + expense.amount;
    }

    // This month's total
    final thisMonthTotal = getThisMonthExpenses().fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Today's total
    final todaysTotal = getTodaysExpenses().fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Recurring expenses count and amount
    final recurringExpenses = getRecurringExpenses();
    final recurringCount = recurringExpenses.length;
    final recurringAmount = recurringExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    return {
      'totalExpenses': totalExpenses,
      'totalAmount': totalAmount,
      'categoryBreakdown': categoryBreakdown,
      'paymentMethodBreakdown': paymentMethodBreakdown,
      'thisMonthTotal': thisMonthTotal,
      'todaysTotal': todaysTotal,
      'recurringCount': recurringCount,
      'recurringAmount': recurringAmount,
    };
  }

  // Get expenses summary for date range
  Map<String, dynamic> getExpensesSummary(DateTime start, DateTime end) {
    final expenses = getExpensesByDateRange(start, end);
    
    final totalAmount = expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    final categoryBreakdown = <ExpenseCategory, double>{};
    for (var expense in expenses) {
      categoryBreakdown[expense.category] = 
          (categoryBreakdown[expense.category] ?? 0.0) + expense.amount;
    }

    return {
      'count': expenses.length,
      'totalAmount': totalAmount,
      'categoryBreakdown': categoryBreakdown,
      'expenses': expenses,
    };
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}
