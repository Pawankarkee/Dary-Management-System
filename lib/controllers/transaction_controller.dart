import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';
import 'farmer_controller.dart';

class TransactionController extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  bool _isLoading = false;
  String? _selectedFarmerId;
  TransactionType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  List<TransactionModel> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;

  TransactionController() {
    loadTransactions();
  }

  // Load all transactions
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await HiveService.getTransactionsBox();
      _transactions = box.values
          .map((json) => TransactionModel.fromJson(Map<String, dynamic>.from(json)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      
      _applyFilters();
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add milk payment transaction (auto-created from milk collection)
  Future<bool> addMilkPaymentTransaction({
    required String farmerId,
    required double amount,
    required String milkCollectionId,
    required FarmerController farmerController,
  }) async {
    return await _addTransaction(
      farmerId: farmerId,
      type: TransactionType.milkPayment,
      amount: amount,
      description: 'Milk Payment',
      referenceId: milkCollectionId,
      farmerController: farmerController,
    );
  }

  // Add advance transaction
  Future<bool> addAdvanceTransaction({
    required String farmerId,
    required double amount,
    required String description,
    required FarmerController farmerController,
  }) async {
    return await _addTransaction(
      farmerId: farmerId,
      type: TransactionType.advance,
      amount: amount,
      description: description,
      farmerController: farmerController,
    );
  }

  // Add credit transaction
  Future<bool> addCreditTransaction({
    required String farmerId,
    required double amount,
    required String description,
    required FarmerController farmerController,
  }) async {
    return await _addTransaction(
      farmerId: farmerId,
      type: TransactionType.credit,
      amount: amount,
      description: description,
      farmerController: farmerController,
    );
  }

  // Add product purchase transaction
  Future<bool> addProductPurchaseTransaction({
    required String farmerId,
    required double amount,
    required String saleId,
    required FarmerController farmerController,
  }) async {
    return await _addTransaction(
      farmerId: farmerId,
      type: TransactionType.productPurchase,
      amount: amount,
      description: 'Product Purchase',
      referenceId: saleId,
      farmerController: farmerController,
    );
  }

  // Add settlement transaction
  Future<bool> addSettlementTransaction({
    required String farmerId,
    required double amount,
    required String paymentMode,
    required FarmerController farmerController,
  }) async {
    return await _addTransaction(
      farmerId: farmerId,
      type: TransactionType.settlement,
      amount: amount,
      description: 'Settlement - $paymentMode',
      farmerController: farmerController,
    );
  }

  // Generic add transaction
  Future<bool> _addTransaction({
    required String farmerId,
    required TransactionType type,
    required double amount,
    required String description,
    String? referenceId,
    required FarmerController farmerController,
  }) async {
    try {
      // Get current balance
      final farmer = farmerController.getFarmerById(farmerId);
      if (farmer == null) return false;

      double currentBalance = farmer.runningBalance;

      // Calculate new balance
      double newBalance;
      if (type == TransactionType.milkPayment || type == TransactionType.advance) {
        newBalance = currentBalance + amount; // Credit (increases balance)
      } else {
        newBalance = currentBalance - amount; // Debit (decreases balance)
      }

      final transaction = TransactionModel(
        id: const Uuid().v4(),
        farmerId: farmerId,
        type: type,
        amount: amount,
        description: description,
        date: DateTime.now(),
        runningBalance: newBalance,
        isSynced: false,
        createdAt: DateTime.now(),
        referenceId: referenceId,
      );

      // Save to Hive
      final box = await HiveService.getTransactionsBox();
      await box.put(transaction.id, transaction.toJson());

      _transactions.insert(0, transaction);
      _applyFilters();

      // Update farmer balance
      await farmerController.updateFarmerBalance(farmerId, newBalance);

      notifyListeners();

      // Queue for sync
      await _queueForSync(transaction.id, 'create');

      return true;
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }

  // Get transactions by farmer
  List<TransactionModel> getTransactionsByFarmer(String farmerId) {
    return _transactions
        .where((transaction) => transaction.farmerId == farmerId)
        .toList();
  }

  // Get farmer ledger
  List<TransactionModel> getFarmerLedger(String farmerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _transactions.where((transaction) {
      if (transaction.farmerId != farmerId) return false;

      if (startDate != null && transaction.date.isBefore(startDate)) {
        return false;
      }

      if (endDate != null && transaction.date.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  // Get outstanding credits
  Map<String, double> getOutstandingCredits() {
    final Map<String, double> credits = {};
    
    for (var transaction in _transactions) {
      if (!credits.containsKey(transaction.farmerId)) {
        credits[transaction.farmerId] = 0;
      }
      
      // Use the running balance from the latest transaction
      credits[transaction.farmerId] = transaction.runningBalance;
    }

    return credits;
  }

  // Apply filters
  void _applyFilters() {
    _filteredTransactions = _transactions.where((transaction) {
      final matchesFarmer = _selectedFarmerId == null ||
          transaction.farmerId == _selectedFarmerId;

      final matchesType = _selectedType == null ||
          transaction.type == _selectedType;

      final matchesStartDate = _startDate == null ||
          transaction.date.isAfter(_startDate!) ||
          transaction.date.isAtSameMomentAs(_startDate!);

      final matchesEndDate = _endDate == null ||
          transaction.date.isBefore(_endDate!) ||
          transaction.date.isAtSameMomentAs(_endDate!);

      return matchesFarmer && matchesType && matchesStartDate && matchesEndDate;
    }).toList();
  }

  // Set filters
  void setFarmerFilter(String? farmerId) {
    _selectedFarmerId = farmerId;
    _applyFilters();
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedFarmerId = null;
    _selectedType = null;
    _startDate = null;
    _endDate = null;
    _applyFilters();
    notifyListeners();
  }

  // Queue for sync
  Future<void> _queueForSync(String transactionId, String action) async {
    try {
      final syncBox = await HiveService.getSyncQueueBox();
      final syncId = const Uuid().v4();
      await syncBox.put(syncId, {
        'id': syncId,
        'type': 'transaction',
        'action': action,
        'referenceId': transactionId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error queuing for sync: $e');
    }
  }
}
