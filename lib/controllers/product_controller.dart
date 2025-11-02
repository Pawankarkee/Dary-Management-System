import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import '../services/hive_service.dart';

class ProductController extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  ProductCategory? _selectedCategory;
  String _searchQuery = '';

  List<ProductModel> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  List<ProductModel> get lowStockProducts => 
      _products.where((p) => p.isLowStock && p.isActive).toList();
  List<ProductModel> get expiringProducts => 
      _products.where((p) => (p.isExpiringSoon || p.isExpired) && p.isActive).toList();

  ProductController() {
    loadProducts();
  }

  // Load all products
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await HiveService.getProductsBox();
      _products = box.values
          .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
          .where((product) => product.isActive)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      
      _applyFilters();
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate product ID
  String _generateProductId() {
    if (_products.isEmpty) {
      return 'P001';
    }
    
    final lastId = _products.last.id;
    final number = int.parse(lastId.substring(1));
    return 'P${(number + 1).toString().padLeft(3, '0')}';
  }

  // Add product
  Future<bool> addProduct(ProductModel product) async {
    try {
      final newProduct = product.copyWith(
        id: _generateProductId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final box = await HiveService.getProductsBox();
      await box.put(newProduct.id, newProduct.toJson());

      _products.add(newProduct);
      _applyFilters();
      notifyListeners();

      await _queueForSync(newProduct.id, 'create');
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  // Add product (legacy method for backward compatibility)
  Future<bool> addProductLegacy({
    required String name,
    required ProductCategory category,
    required ProductUnit unit,
    required double purchasePrice,
    required double sellingPrice,
    required double initialStock,
    double minStockLevel = 0,
    DateTime? expiryDate,
  }) async {
    try {
      final product = ProductModel(
        id: _generateProductId(),
        name: name,
        category: category,
        unit: unit,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        currentStock: initialStock,
        minStockLevel: minStockLevel,
        expiryDate: expiryDate,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final box = await HiveService.getProductsBox();
      await box.put(product.id, product.toJson());

      _products.add(product);
      _applyFilters();
      notifyListeners();

      await _queueForSync(product.id, 'create');
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      
      final box = await HiveService.getProductsBox();
      await box.put(updatedProduct.id, updatedProduct.toJson());

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      _applyFilters();
      notifyListeners();

      await _queueForSync(updatedProduct.id, 'update');
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete product (soft delete)
  Future<bool> deleteProduct(String productId) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final deactivatedProduct = product.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );

      final box = await HiveService.getProductsBox();
      await box.put(productId, deactivatedProduct.toJson());

      _products.removeWhere((p) => p.id == productId);
      _applyFilters();
      notifyListeners();

      await _queueForSync(productId, 'delete');
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Update stock (add or reduce)
  Future<bool> updateStock(String productId, double quantity, bool isAddition) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final newStock = isAddition 
          ? product.currentStock + quantity 
          : product.currentStock - quantity;

      if (newStock < 0) return false;

      final updatedProduct = product.copyWith(
        currentStock: newStock,
        updatedAt: DateTime.now(),
      );

      final box = await HiveService.getProductsBox();
      await box.put(productId, updatedProduct.toJson());

      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      _applyFilters();
      notifyListeners();

      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }

  // Get product by ID
  ProductModel? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(ProductCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Set filter (alias for filterByCategory)
  void setFilter(ProductCategory? category) {
    filterByCategory(category);
  }

  // Apply filters
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.id.toLowerCase().contains(_searchQuery) ||
          product.name.toLowerCase().contains(_searchQuery);

      final matchesCategory = _selectedCategory == null ||
          product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFilters();
    notifyListeners();
  }

  // Queue for sync
  Future<void> _queueForSync(String productId, String action) async {
    try {
      final syncBox = await HiveService.getSyncQueueBox();
      final syncId = const Uuid().v4();
      await syncBox.put(syncId, {
        'id': syncId,
        'type': 'product',
        'action': action,
        'referenceId': productId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error queuing for sync: $e');
    }
  }
}
