import 'package:flutter/foundation.dart';
import '../models/supplier_model.dart';
import '../services/hive_service.dart';

class SupplierController extends ChangeNotifier {
  List<SupplierModel> _suppliers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<SupplierModel> get suppliers => _searchQuery.isEmpty
      ? _suppliers
      : _suppliers
          .where((supplier) =>
              supplier.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              supplier.phone.contains(_searchQuery) ||
              supplier.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  List<SupplierModel> get activeSuppliers =>
      suppliers.where((s) => s.isActive).toList();

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Load suppliers from Hive
  Future<void> loadSuppliers() async {
    try {
      _isLoading = true;
      notifyListeners();

      final box = await HiveService.getSuppliersBox();
      _suppliers = box.values.map((e) {
        if (e is Map) {
          return SupplierModel.fromJson(Map<String, dynamic>.from(e));
        }
        return e as SupplierModel;
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading suppliers: $e');
      rethrow;
    }
  }

  // Add new supplier
  Future<void> addSupplier(SupplierModel supplier) async {
    try {
      final box = await HiveService.getSuppliersBox();
      await box.put(supplier.id, supplier.toJson());
      _suppliers.add(supplier);
      notifyListeners();
    } catch (e) {
      print('Error adding supplier: $e');
      rethrow;
    }
  }

  // Update supplier
  Future<void> updateSupplier(SupplierModel supplier) async {
    try {
      final box = await HiveService.getSuppliersBox();
      await box.put(supplier.id, supplier.toJson());
      
      final index = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = supplier;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating supplier: $e');
      rethrow;
    }
  }

  // Delete supplier
  Future<void> deleteSupplier(String supplierId) async {
    try {
      final box = await HiveService.getSuppliersBox();
      await box.delete(supplierId);
      _suppliers.removeWhere((s) => s.id == supplierId);
      notifyListeners();
    } catch (e) {
      print('Error deleting supplier: $e');
      rethrow;
    }
  }

  // Get supplier by ID
  SupplierModel? getSupplierById(String supplierId) {
    try {
      return _suppliers.firstWhere((s) => s.id == supplierId);
    } catch (e) {
      return null;
    }
  }

  // Update supplier balance
  Future<void> updateSupplierBalance(String supplierId, double amount) async {
    try {
      final supplier = getSupplierById(supplierId);
      if (supplier != null) {
        final updatedSupplier = supplier.copyWith(
          currentBalance: supplier.currentBalance + amount,
          updatedAt: DateTime.now(),
        );
        await updateSupplier(updatedSupplier);
      }
    } catch (e) {
      print('Error updating supplier balance: $e');
      rethrow;
    }
  }

  // Search suppliers
  void searchSuppliers(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Get suppliers by type
  List<SupplierModel> getSuppliersByType(SupplierType type) {
    return suppliers.where((s) => s.supplierType == type && s.isActive).toList();
  }

  // Get supplier statistics
  Map<String, dynamic> getSupplierStatistics() {
    final totalSuppliers = suppliers.length;
    final activeSuppliers = suppliers.where((s) => s.isActive).length;
    final totalBalance = suppliers.fold<double>(
      0,
      (sum, supplier) => sum + supplier.currentBalance,
    );

    return {
      'totalSuppliers': totalSuppliers,
      'activeSuppliers': activeSuppliers,
      'inactiveSuppliers': totalSuppliers - activeSuppliers,
      'totalOutstanding': totalBalance,
    };
  }

  // Get suppliers with outstanding balance
  List<SupplierModel> getSuppliersWithBalance() {
    return suppliers.where((s) => s.currentBalance > 0).toList()
      ..sort((a, b) => b.currentBalance.compareTo(a.currentBalance));
  }
}
