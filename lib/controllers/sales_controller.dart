import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../models/product_model.dart';
import '../services/hive_service.dart';
import 'product_controller.dart';

class SalesController extends ChangeNotifier {
  List<SaleModel> _sales = [];
  List<SaleModel> _filteredSales = [];
  bool _isLoading = false;
  DateTime? _selectedDate;
  String _searchQuery = '';

  List<SaleModel> get sales => _filteredSales;
  bool get isLoading => _isLoading;

  SalesController() {
    loadSales();
  }

  // Load all sales
  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await HiveService.getSalesBox();
      _sales = box.values
          .map((json) => SaleModel.fromJson(Map<String, dynamic>.from(json)))
          .toList()
        ..sort((a, b) => b.saleDate.compareTo(a.saleDate));
      
      _applyFilters();
    } catch (e) {
      print('Error loading sales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new sale
  Future<bool> addSale({
    required List<SaleItemModel> items,
    required PaymentMethod paymentMethod,
    String? farmerId,
    String? farmerName,
    double discount = 0.0,
    required ProductController productController,
  }) async {
    try {
      // Calculate totals
      final subtotal = items.fold(0.0, (sum, item) => sum + item.amount);
      final totalAmount = subtotal - discount;

      final sale = SaleModel(
        id: SaleModel.generateId(),
        farmerId: farmerId,
        farmerName: farmerName,
        items: items,
        subtotal: subtotal,
        discount: discount,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        saleDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Hive
      final box = await HiveService.getSalesBox();
      await box.put(sale.id, sale.toJson());

      // Update product stock
      for (var item in items) {
        await productController.updateStock(item.productId, item.quantity, false);
      }

      _sales.insert(0, sale);
      _applyFilters();
      notifyListeners();

      // Queue for sync
      await _queueForSync(sale.id, 'create');

      return true;
    } catch (e) {
      print('Error adding sale: $e');
      return false;
    }
  }

  // Get today's sales summary
  Map<String, dynamic> getTodaySummary() {
    final today = DateTime.now();
    final todaySales = _sales.where((sale) =>
        sale.saleDate.year == today.year &&
        sale.saleDate.month == today.month &&
        sale.saleDate.day == today.day).toList();

    double totalAmount = 0;
    double totalDiscount = 0;
    int totalItems = 0;

    for (var sale in todaySales) {
      totalAmount += sale.totalAmount;
      totalDiscount += sale.discount;
      totalItems += sale.items.length;
    }

    return {
      'totalSales': todaySales.length,
      'totalAmount': totalAmount,
      'totalDiscount': totalDiscount,
      'totalItems': totalItems,
    };
  }

  // Get sales by date range
  List<SaleModel> getSalesByDateRange(DateTime start, DateTime end) {
    return _sales.where((sale) =>
        sale.saleDate.isAfter(start.subtract(const Duration(days: 1))) &&
        sale.saleDate.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  // Get sales by customer/farmer
  List<SaleModel> getSalesByFarmer(String farmerId) {
    return _sales.where((sale) => sale.farmerId == farmerId).toList();
  }

  // Search sales
  void searchSales(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Filter by date
  void filterByDate(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredSales = _sales.where((sale) {
      final matchesSearch = _searchQuery.isEmpty ||
          sale.id.toLowerCase().contains(_searchQuery) ||
          (sale.farmerName?.toLowerCase().contains(_searchQuery) ?? false);

      final matchesDate = _selectedDate == null ||
          (sale.saleDate.year == _selectedDate!.year &&
           sale.saleDate.month == _selectedDate!.month &&
           sale.saleDate.day == _selectedDate!.day);

      return matchesSearch && matchesDate;
    }).toList();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedDate = null;
    _applyFilters();
    notifyListeners();
  }

  // Queue for sync
  Future<void> _queueForSync(String saleId, String action) async {
    try {
      final syncBox = await HiveService.getSyncQueueBox();
      final syncId = DateTime.now().millisecondsSinceEpoch.toString();
      await syncBox.put(syncId, {
        'id': syncId,
        'type': 'sale',
        'action': action,
        'referenceId': saleId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error queuing for sync: $e');
    }
  }

  // Get top selling products
  List<Map<String, dynamic>> getTopSellingProducts({int limit = 5}) {
    final Map<String, Map<String, dynamic>> productSales = {};

    for (var sale in _sales) {
      for (var item in sale.items) {
        if (productSales.containsKey(item.productId)) {
          productSales[item.productId]!['quantity'] += item.quantity;
          productSales[item.productId]!['amount'] += item.amount;
        } else {
          productSales[item.productId] = {
            'productId': item.productId,
            'productName': item.productName,
            'quantity': item.quantity,
            'amount': item.amount,
          };
        }
      }
    }

    final sortedProducts = productSales.values.toList()
      ..sort((a, b) => b['quantity'].compareTo(a['quantity']));

    return sortedProducts.take(limit).toList();
  }

  // Get sales statistics
  Map<String, dynamic> getSalesStatistics() {
    double totalRevenue = 0;
    double totalDiscount = 0;
    int totalTransactions = _sales.length;
    int totalItemsSold = 0;

    for (var sale in _sales) {
      totalRevenue += sale.totalAmount;
      totalDiscount += sale.discount;
      totalItemsSold += sale.items.length;
    }

    return {
      'totalRevenue': totalRevenue,
      'totalDiscount': totalDiscount,
      'totalTransactions': totalTransactions,
      'totalItemsSold': totalItemsSold,
      'averageOrderValue': totalTransactions > 0 ? totalRevenue / totalTransactions : 0,
    };
  }
}
