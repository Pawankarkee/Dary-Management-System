import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/milk_collection_model.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';
import 'farmer_controller.dart';
import 'transaction_controller.dart';

class MilkController extends ChangeNotifier {
  List<MilkCollectionModel> _collections = [];
  List<MilkCollectionModel> _filteredCollections = [];
  bool _isLoading = false;
  DateTime? _selectedDate;
  Shift? _selectedShift;
  String? _selectedFarmerId;

  List<MilkCollectionModel> get collections => _filteredCollections;
  bool get isLoading => _isLoading;

  MilkController() {
    loadCollections();
  }

  // Load all collections
  Future<void> loadCollections() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await HiveService.getMilkCollectionsBox();
      _collections = box.values
          .map((json) => MilkCollectionModel.fromJson(Map<String, dynamic>.from(json)))
          .where((collection) => !collection.isRejected)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      
      _applyFilters();
    } catch (e) {
      print('Error loading milk collections: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate rate based on FAT and SNF
  double calculateRate(double fat, double snf) {
    // Base rate calculation formula
    // Rate = Base Rate + (FAT × FAT Multiplier) + (SNF × SNF Multiplier)
    const double baseRate = 20.0;
    const double fatMultiplier = 2.5;
    const double snfMultiplier = 1.5;

    return baseRate + (fat * fatMultiplier) + (snf * snfMultiplier);
  }

  // Check for duplicate entry
  Future<bool> isDuplicateEntry({
    required String farmerId,
    required DateTime date,
    required Shift shift,
  }) async {
    return _collections.any((collection) =>
        collection.farmerId == farmerId &&
        collection.date.year == date.year &&
        collection.date.month == date.month &&
        collection.date.day == date.day &&
        collection.shift == shift);
  }

  // Add milk collection
  Future<bool> addMilkCollection({
    required String farmerId,
    required DateTime date,
    required Shift shift,
    required double quantity,
    required double fat,
    required double snf,
    required String collectorId,
    required FarmerController farmerController,
    required TransactionController transactionController,
  }) async {
    try {
      // Note: Duplicate check is now handled in the UI with confirmation dialog
      
      // Calculate rate and total
      final rate = calculateRate(fat, snf);
      final total = quantity * rate;

      final collection = MilkCollectionModel(
        id: const Uuid().v4(),
        farmerId: farmerId,
        date: date,
        shift: shift,
        quantity: quantity,
        fat: fat,
        snf: snf,
        ratePerLiter: rate,
        totalAmount: total,
        collectorId: collectorId,
        isSynced: false,
        createdAt: DateTime.now(),
      );

      // Save to Hive
      final box = await HiveService.getMilkCollectionsBox();
      await box.put(collection.id, collection.toJson());

      _collections.add(collection);
      _applyFilters();

      // Create transaction (Milk Payment)
      await transactionController.addMilkPaymentTransaction(
        farmerId: farmerId,
        amount: total,
        milkCollectionId: collection.id,
        farmerController: farmerController,
      );

      notifyListeners();

      // Queue for sync
      await _queueForSync(collection.id, 'create');

      return true;
    } catch (e) {
      print('Error adding milk collection: $e');
      return false;
    }
  }

  // Get collections by date
  List<MilkCollectionModel> getCollectionsByDate(DateTime date) {
    return _collections.where((collection) =>
        collection.date.year == date.year &&
        collection.date.month == date.month &&
        collection.date.day == date.day).toList();
  }

  // Get collections by farmer
  List<MilkCollectionModel> getCollectionsByFarmer(String farmerId) {
    return _collections
        .where((collection) => collection.farmerId == farmerId)
        .toList();
  }

  // Get today's summary
  Map<String, dynamic> getTodaySummary() {
    final today = DateTime.now();
    final todayCollections = getCollectionsByDate(today);

    double totalQuantity = 0;
    double totalAmount = 0;
    int morningCount = 0;
    int eveningCount = 0;

    for (var collection in todayCollections) {
      totalQuantity += collection.quantity;
      totalAmount += collection.totalAmount;
      if (collection.shift == Shift.morning) {
        morningCount++;
      } else {
        eveningCount++;
      }
    }

    return {
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'morningCount': morningCount,
      'eveningCount': eveningCount,
      'totalFarmers': todayCollections.length,
    };
  }

  // Apply filters
  void _applyFilters() {
    _filteredCollections = _collections.where((collection) {
      final matchesDate = _selectedDate == null ||
          (collection.date.year == _selectedDate!.year &&
              collection.date.month == _selectedDate!.month &&
              collection.date.day == _selectedDate!.day);

      final matchesShift = _selectedShift == null ||
          collection.shift == _selectedShift;

      final matchesFarmer = _selectedFarmerId == null ||
          collection.farmerId == _selectedFarmerId;

      return matchesDate && matchesShift && matchesFarmer;
    }).toList();
  }

  // Set filters
  void setDateFilter(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
    notifyListeners();
  }

  void setShiftFilter(Shift? shift) {
    _selectedShift = shift;
    _applyFilters();
    notifyListeners();
  }

  void setFarmerFilter(String? farmerId) {
    _selectedFarmerId = farmerId;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedDate = null;
    _selectedShift = null;
    _selectedFarmerId = null;
    _applyFilters();
    notifyListeners();
  }

  // Queue for sync
  Future<void> _queueForSync(String collectionId, String action) async {
    try {
      final syncBox = await HiveService.getSyncQueueBox();
      final syncId = const Uuid().v4();
      await syncBox.put(syncId, {
        'id': syncId,
        'type': 'milk_collection',
        'action': action,
        'referenceId': collectionId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error queuing for sync: $e');
    }
  }
}
