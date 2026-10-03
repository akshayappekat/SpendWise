import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/goal_model.dart';
import '../models/recurring_model.dart';
import '../services/database_service.dart';
import '../utils/helpers.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  BudgetModel? _currentBudget;
  final List<GoalModel> _goals = [];
  final List<RecurringModel> _recurring = [];
  bool _isLoading = false;
  int? _currentUserId;
  String _selectedCurrency = '₹';
  bool _isDarkMode = true;
  String _searchQuery = '';
  String _filterCategory = 'All';
  String _filterType = 'All';

  // Getters
  List<TransactionModel> get transactions => _transactions;
  BudgetModel? get currentBudget => _currentBudget;
  List<GoalModel> get goals => _goals;
  List<RecurringModel> get recurring => _recurring;
  bool get isLoading => _isLoading;
  int? get currentUserId => _currentUserId;
  String get selectedCurrency => _selectedCurrency;
  bool get isDarkMode => _isDarkMode;
  String get searchQuery => _searchQuery;
  String get filterCategory => _filterCategory;
  String get filterType => _filterType;

  // Calculated properties
  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpenses => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalBalance => totalIncome - totalExpenses;

  double get monthlyBudgetAmount => _currentBudget?.amount ?? 20000.0;

  double get budgetRemaining => monthlyBudgetAmount - totalExpenses;

  double get budgetUtilizationPercentage {
    if (monthlyBudgetAmount <= 0) return 0.0;
    return ((totalExpenses / monthlyBudgetAmount) * 100).clamp(0.0, 100.0);
  }

  List<TransactionModel> get filteredTransactions {
    return _transactions.where((t) {
      final matchesSearch = t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _filterCategory == 'All' || t.category == _filterCategory;
      final matchesType = _filterType == 'All' ||
          (_filterType == 'Income' && t.isIncome) ||
          (_filterType == 'Expense' && t.isExpense);
      return matchesSearch && matchesCategory && matchesType;
    }).toList();
  }

  Map<String, double> get categoryExpenseTotals {
    final Map<String, double> totals = {};
    for (var t in _transactions.where((t) => t.isExpense)) {
      totals[t.category] = (totals[t.category] ?? 0.0) + t.amount;
    }
    return totals;
  }

  // Actions

  /// Fetch user-specific transactions and budget
  Future<void> fetchTransactionsForUser(int userId) async {
    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    _transactions = await DatabaseService.instance.getTransactionsByUser(userId);
    final currentMonthKey = AppHelpers.formatMonthKey(DateTime.now());
    _currentBudget = await DatabaseService.instance.getBudget(currentMonthKey, userId);
    
    if (_currentBudget == null) {
      _currentBudget = BudgetModel(month: currentMonthKey, amount: 20000.0, userId: userId);
      await DatabaseService.instance.setBudget(_currentBudget!);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    if (_currentUserId != null) {
      await fetchTransactionsForUser(_currentUserId!);
    } else {
      _isLoading = true;
      notifyListeners();

      _transactions = await DatabaseService.instance.getAllTransactions();
      final currentMonthKey = AppHelpers.formatMonthKey(DateTime.now());
      _currentBudget = await DatabaseService.instance.getBudget(currentMonthKey, 0);

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final txWithUser = transaction.copyWith(userId: _currentUserId);
    final newTx = await DatabaseService.instance.createTransaction(txWithUser);
    _transactions.insert(0, newTx);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final txWithUser = transaction.userId == null ? transaction.copyWith(userId: _currentUserId) : transaction;
    await DatabaseService.instance.updateTransaction(txWithUser);
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = txWithUser;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseService.instance.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double amount) async {
    final currentMonthKey = AppHelpers.formatMonthKey(DateTime.now());
    final budget = BudgetModel(month: currentMonthKey, amount: amount, userId: _currentUserId);
    await DatabaseService.instance.setBudget(budget);
    _currentBudget = budget;
    notifyListeners();
  }

  void clearUserData() {
    _transactions = [];
    _currentBudget = null;
    _currentUserId = null;
    notifyListeners();
  }

  void setCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilters({String? category, String? type}) {
    if (category != null) _filterCategory = category;
    if (type != null) _filterType = type;
    notifyListeners();
  }

  void refreshState() {
    notifyListeners();
  }
}
