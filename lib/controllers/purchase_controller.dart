import 'package:flutter/foundation.dart';
import '../models/purchase_model.dart';
import '../services/hive_service.dart';
import 'supplier_controller.dart';

class PurchaseController extends ChangeNotifier {
  List<PurchaseModel> _purchases = [];
  bool _isLoading = false;
  String _searchQuery = '';
  PurchaseStatus? _filterStatus;
  PaymentStatus? _filterPaymentStatus;

  List<PurchaseModel> get purchases {
    var filtered = _purchases;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((purchase) =>
              purchase.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              purchase.supplierName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply status filter
    if (_filterStatus != null) {
      filtered = filtered.where((p) => p.status == _filterStatus).toList();
    }

    // Apply payment status filter
    if (_filterPaymentStatus != null) {
      filtered = filtered.where((p) => p.paymentStatus == _filterPaymentStatus).toList();
    }

    return filtered;
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  PurchaseStatus? get filterStatus => _filterStatus;
  PaymentStatus? get filterPaymentStatus => _filterPaymentStatus;

  // Load purchases from Hive
  Future<void> loadPurchases() async {
    try {
      _isLoading = true;
      notifyListeners();

      final box = await HiveService.getPurchasesBox();
      _purchases = box.values.map((e) {
        if (e is Map) {
          return PurchaseModel.fromJson(Map<String, dynamic>.from(e));
        }
        return e as PurchaseModel;
      }).toList();

      // Sort by date (newest first)
      _purchases.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading purchases: $e');
      rethrow;
    }
  }

  // Add new purchase
  Future<void> addPurchase(PurchaseModel purchase, SupplierController supplierController) async {
    try {
      final box = await HiveService.getPurchasesBox();
      await box.put(purchase.id, purchase.toJson());
      _purchases.insert(0, purchase);

      // Update supplier balance if not fully paid
      if (purchase.balanceAmount > 0) {
        await supplierController.updateSupplierBalance(
          purchase.supplierId,
          purchase.balanceAmount,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error adding purchase: $e');
      rethrow;
    }
  }

  // Update purchase
  Future<void> updatePurchase(PurchaseModel purchase) async {
    try {
      final box = await HiveService.getPurchasesBox();
      await box.put(purchase.id, purchase.toJson());

      final index = _purchases.indexWhere((p) => p.id == purchase.id);
      if (index != -1) {
        _purchases[index] = purchase;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating purchase: $e');
      rethrow;
    }
  }

  // Delete purchase
  Future<void> deletePurchase(String purchaseId) async {
    try {
      final box = await HiveService.getPurchasesBox();
      await box.delete(purchaseId);
      _purchases.removeWhere((p) => p.id == purchaseId);
      notifyListeners();
    } catch (e) {
      print('Error deleting purchase: $e');
      rethrow;
    }
  }

  // Get purchase by ID
  PurchaseModel? getPurchaseById(String purchaseId) {
    try {
      return _purchases.firstWhere((p) => p.id == purchaseId);
    } catch (e) {
      return null;
    }
  }

  // Record payment
  Future<void> recordPayment(
    String purchaseId,
    double amount,
    SupplierController supplierController,
  ) async {
    try {
      final purchase = getPurchaseById(purchaseId);
      if (purchase == null) return;

      final newPaidAmount = purchase.paidAmount + amount;
      final newBalanceAmount = purchase.totalAmount - newPaidAmount;

      PaymentStatus newPaymentStatus;
      if (newBalanceAmount <= 0) {
        newPaymentStatus = PaymentStatus.paid;
      } else if (newPaidAmount > 0) {
        newPaymentStatus = PaymentStatus.partial;
      } else {
        newPaymentStatus = PaymentStatus.unpaid;
      }

      final updatedPurchase = PurchaseModel(
        id: purchase.id,
        supplierId: purchase.supplierId,
        supplierName: purchase.supplierName,
        invoiceNumber: purchase.invoiceNumber,
        purchaseDate: purchase.purchaseDate,
        dueDate: purchase.dueDate,
        items: purchase.items,
        subtotal: purchase.subtotal,
        taxAmount: purchase.taxAmount,
        otherCharges: purchase.otherCharges,
        discount: purchase.discount,
        totalAmount: purchase.totalAmount,
        paidAmount: newPaidAmount,
        balanceAmount: newBalanceAmount,
        status: purchase.status,
        paymentStatus: newPaymentStatus,
        notes: purchase.notes,
        createdAt: purchase.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await updatePurchase(updatedPurchase);

      // Update supplier balance (reduce the balance)
      await supplierController.updateSupplierBalance(
        purchase.supplierId,
        -amount,
      );
    } catch (e) {
      print('Error recording payment: $e');
      rethrow;
    }
  }

  // Mark purchase as received
  Future<void> markAsReceived(String purchaseId) async {
    try {
      final purchase = getPurchaseById(purchaseId);
      if (purchase == null) return;

      final updatedPurchase = PurchaseModel(
        id: purchase.id,
        supplierId: purchase.supplierId,
        supplierName: purchase.supplierName,
        invoiceNumber: purchase.invoiceNumber,
        purchaseDate: purchase.purchaseDate,
        dueDate: purchase.dueDate,
        items: purchase.items,
        subtotal: purchase.subtotal,
        taxAmount: purchase.taxAmount,
        otherCharges: purchase.otherCharges,
        discount: purchase.discount,
        totalAmount: purchase.totalAmount,
        paidAmount: purchase.paidAmount,
        balanceAmount: purchase.balanceAmount,
        status: PurchaseStatus.received,
        paymentStatus: purchase.paymentStatus,
        notes: purchase.notes,
        createdAt: purchase.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await updatePurchase(updatedPurchase);
    } catch (e) {
      print('Error marking purchase as received: $e');
      rethrow;
    }
  }

  // Cancel purchase
  Future<void> cancelPurchase(String purchaseId, SupplierController supplierController) async {
    try {
      final purchase = getPurchaseById(purchaseId);
      if (purchase == null) return;

      final updatedPurchase = PurchaseModel(
        id: purchase.id,
        supplierId: purchase.supplierId,
        supplierName: purchase.supplierName,
        invoiceNumber: purchase.invoiceNumber,
        purchaseDate: purchase.purchaseDate,
        dueDate: purchase.dueDate,
        items: purchase.items,
        subtotal: purchase.subtotal,
        taxAmount: purchase.taxAmount,
        otherCharges: purchase.otherCharges,
        discount: purchase.discount,
        totalAmount: purchase.totalAmount,
        paidAmount: purchase.paidAmount,
        balanceAmount: purchase.balanceAmount,
        status: PurchaseStatus.cancelled,
        paymentStatus: purchase.paymentStatus,
        notes: purchase.notes,
        createdAt: purchase.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await updatePurchase(updatedPurchase);

      // Adjust supplier balance if there was an outstanding amount
      if (purchase.balanceAmount > 0) {
        await supplierController.updateSupplierBalance(
          purchase.supplierId,
          -purchase.balanceAmount,
        );
      }
    } catch (e) {
      print('Error cancelling purchase: $e');
      rethrow;
    }
  }

  // Search purchases
  void searchPurchases(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter by status
  void filterByStatus(PurchaseStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Filter by payment status
  void filterByPaymentStatus(PaymentStatus? status) {
    _filterPaymentStatus = status;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterPaymentStatus = null;
    notifyListeners();
  }

  // Get purchases by supplier
  List<PurchaseModel> getPurchasesBySupplier(String supplierId) {
    return _purchases.where((p) => p.supplierId == supplierId).toList();
  }

  // Get purchases by date range
  List<PurchaseModel> getPurchasesByDateRange(DateTime start, DateTime end) {
    return _purchases
        .where((p) =>
            p.purchaseDate.isAfter(start.subtract(const Duration(days: 1))) &&
            p.purchaseDate.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  // Get pending purchases
  List<PurchaseModel> getPendingPurchases() {
    return _purchases.where((p) => p.status == PurchaseStatus.pending).toList();
  }

  // Get unpaid/partial paid purchases
  List<PurchaseModel> getUnpaidPurchases() {
    return _purchases
        .where((p) =>
            p.paymentStatus == PaymentStatus.unpaid ||
            p.paymentStatus == PaymentStatus.partial)
        .toList();
  }

  // Get overdue purchases
  List<PurchaseModel> getOverduePurchases() {
    final now = DateTime.now();
    return _purchases
        .where((p) =>
            p.dueDate.isBefore(now) &&
            (p.paymentStatus == PaymentStatus.unpaid ||
                p.paymentStatus == PaymentStatus.partial))
        .toList();
  }

  // Get purchase statistics
  Map<String, dynamic> getPurchaseStatistics() {
    final totalPurchases = _purchases.length;
    final totalAmount = _purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.totalAmount,
    );
    final totalPaid = _purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.paidAmount,
    );
    final totalOutstanding = _purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.balanceAmount,
    );
    final pendingCount = _purchases.where((p) => p.status == PurchaseStatus.pending).length;
    final receivedCount = _purchases.where((p) => p.status == PurchaseStatus.received).length;
    final overdueCount = getOverduePurchases().length;

    return {
      'totalPurchases': totalPurchases,
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'totalOutstanding': totalOutstanding,
      'pendingCount': pendingCount,
      'receivedCount': receivedCount,
      'overdueCount': overdueCount,
    };
  }

  // Get today's purchases
  Map<String, dynamic> getTodaysPurchases() {
    final today = DateTime.now();
    final todaysPurchases = _purchases.where((p) =>
        p.purchaseDate.year == today.year &&
        p.purchaseDate.month == today.month &&
        p.purchaseDate.day == today.day).toList();

    final totalAmount = todaysPurchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.totalAmount,
    );

    return {
      'count': todaysPurchases.length,
      'totalAmount': totalAmount,
    };
  }
}
