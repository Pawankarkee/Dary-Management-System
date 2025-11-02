import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/farmer_model.dart';
import '../services/hive_service.dart';

class FarmerController extends ChangeNotifier {
  List<FarmerModel> _farmers = [];
  List<FarmerModel> _filteredFarmers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedVillage;

  List<FarmerModel> get farmers => _filteredFarmers;
  bool get isLoading => _isLoading;
  List<String> get villages => _farmers
    .map((f) => f.village?.trim())
      .whereType<String>()
      .where((name) => name.trim().isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  FarmerController() {
    loadFarmers();
  }

  // Load all farmers
  Future<void> loadFarmers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await HiveService.getFarmersBox();
      _farmers = box.values
          .map((json) => FarmerModel.fromJson(Map<String, dynamic>.from(json)))
          .where((farmer) => farmer.isActive)
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      
      _applyFilters();
    } catch (e) {
      print('Error loading farmers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate next farmer ID
  String _generateFarmerId() {
    if (_farmers.isEmpty) {
      return 'F001';
    }
    
    final lastId = _farmers.last.id;
    final number = int.parse(lastId.substring(1));
    return 'F${(number + 1).toString().padLeft(3, '0')}';
  }

  // Add new farmer
  Future<bool> addFarmer({
    required String name,
    String? village,
    String? address,
    String? phone,
    required MilkType milkType,
    String? photoPath,
  }) async {
    try {
      final farmer = FarmerModel(
        id: _generateFarmerId(),
        name: name,
  village: village?.trim().isEmpty == true ? null : village?.trim(),
        address: address,
        phone: phone,
        milkType: milkType,
        photoPath: photoPath,
        runningBalance: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      final box = await HiveService.getFarmersBox();
      await box.put(farmer.id, farmer.toJson());

      _farmers.add(farmer);
      _applyFilters();
      notifyListeners();

      // Queue for sync
      await _queueForSync(farmer.id, 'create');

      return true;
    } catch (e) {
      print('Error adding farmer: $e');
      return false;
    }
  }

  // Update farmer
  Future<bool> updateFarmer(FarmerModel farmer) async {
    try {
      final updatedFarmer = farmer.copyWith(updatedAt: DateTime.now());
      
      final box = await HiveService.getFarmersBox();
      await box.put(updatedFarmer.id, updatedFarmer.toJson());

      final index = _farmers.indexWhere((f) => f.id == farmer.id);
      if (index != -1) {
        _farmers[index] = updatedFarmer;
      }

      _applyFilters();
      notifyListeners();

      // Queue for sync
      await _queueForSync(updatedFarmer.id, 'update');

      return true;
    } catch (e) {
      print('Error updating farmer: $e');
      return false;
    }
  }

  // Delete farmer (soft delete)
  Future<bool> deleteFarmer(String farmerId) async {
    try {
      final farmer = _farmers.firstWhere((f) => f.id == farmerId);
      final deactivatedFarmer = farmer.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );

      final box = await HiveService.getFarmersBox();
      await box.put(farmerId, deactivatedFarmer.toJson());

      _farmers.removeWhere((f) => f.id == farmerId);
      _applyFilters();
      notifyListeners();

      // Queue for sync
      await _queueForSync(farmerId, 'delete');

      return true;
    } catch (e) {
      print('Error deleting farmer: $e');
      return false;
    }
  }

  // Get farmer by ID
  FarmerModel? getFarmerById(String farmerId) {
    try {
      return _farmers.firstWhere((f) => f.id == farmerId);
    } catch (e) {
      return null;
    }
  }

  // Search farmers
  void searchFarmers(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Filter by village
  void filterByVillage(String? village) {
    _selectedVillage = village?.trim();
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters
  void _applyFilters() {
  _filteredFarmers = _farmers.where((farmer) {
    final villageName = (farmer.village ?? '').toLowerCase();

    final matchesSearch = _searchQuery.isEmpty ||
      farmer.id.toLowerCase().contains(_searchQuery) ||
      farmer.name.toLowerCase().contains(_searchQuery) ||
      villageName.contains(_searchQuery) ||
      (farmer.phone?.toLowerCase().contains(_searchQuery) ?? false);

    final matchesVillage = _selectedVillage == null ||
      villageName == _selectedVillage?.toLowerCase();

      return matchesSearch && matchesVillage;
    }).toList();
  }

  // Update farmer balance
  Future<void> updateFarmerBalance(String farmerId, double newBalance) async {
    try {
      final farmer = _farmers.firstWhere((f) => f.id == farmerId);
      final updatedFarmer = farmer.copyWith(
        runningBalance: newBalance,
        updatedAt: DateTime.now(),
      );

      final box = await HiveService.getFarmersBox();
      await box.put(farmerId, updatedFarmer.toJson());

      final index = _farmers.indexWhere((f) => f.id == farmerId);
      if (index != -1) {
        _farmers[index] = updatedFarmer;
      }

      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Error updating farmer balance: $e');
    }
  }

  // Get all farmers (including inactive)
  List<FarmerModel> getAllFarmers() {
    return _farmers;
  }

  // Queue for sync
  Future<void> _queueForSync(String farmerId, String action) async {
    try {
      final syncBox = await HiveService.getSyncQueueBox();
      final syncId = const Uuid().v4();
      await syncBox.put(syncId, {
        'id': syncId,
        'type': 'farmer',
        'action': action,
        'referenceId': farmerId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error queuing for sync: $e');
    }
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedVillage = null;
    _applyFilters();
    notifyListeners();
  }
}
