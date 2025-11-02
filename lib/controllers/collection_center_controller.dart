import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/collection_center_model.dart';

class CollectionCenterController extends ChangeNotifier {
  List<CollectionCenterModel> _centers = [];
  List<MilkReceptionModel> _receptions = [];
  bool _isLoading = false;
  String? _error;

  List<CollectionCenterModel> get centers => _centers;
  List<MilkReceptionModel> get receptions => _receptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CollectionCenterController() {
    loadCenters();
  }

  Future<void> loadCenters() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await Hive.openBox<CollectionCenterModel>('collection_centers');
      _centers = box.values.toList();
      _centers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      final receptionBox = await Hive.openBox<MilkReceptionModel>('milk_receptions');
      _receptions = receptionBox.values.toList();
      _receptions.sort((a, b) => b.receptionTime.compareTo(a.receptionTime));
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading centers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCenter(CollectionCenterModel center) async {
    try {
      final box = await Hive.openBox<CollectionCenterModel>('collection_centers');
      await box.put(center.id, center);
      await loadCenters();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCenter(CollectionCenterModel center) async {
    try {
      center.updatedAt = DateTime.now();
      final box = await Hive.openBox<CollectionCenterModel>('collection_centers');
      await box.put(center.id, center);
      await loadCenters();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCenter(String id) async {
    try {
      final box = await Hive.openBox<CollectionCenterModel>('collection_centers');
      await box.delete(id);
      await loadCenters();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addReception(MilkReceptionModel reception) async {
    try {
      final receptionBox = await Hive.openBox<MilkReceptionModel>('milk_receptions');
      await receptionBox.put(reception.id, reception);
      
      // Update center stock
      final centerBox = await Hive.openBox<CollectionCenterModel>('collection_centers');
      final center = centerBox.get(reception.centerId);
      if (center != null && reception.qualityPassed) {
        center.currentStock += reception.quantity;
        await centerBox.put(center.id, center);
      }
      
      await loadCenters();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<MilkReceptionModel> getReceptionsByCenter(String centerId) {
    return _receptions.where((r) => r.centerId == centerId).toList();
  }

  List<MilkReceptionModel> getReceptionsByFarmer(String farmerId) {
    return _receptions.where((r) => r.farmerId == farmerId).toList();
  }

  double getTotalMilkReceived() {
    return _receptions
        .where((r) => r.qualityPassed)
        .fold(0, (sum, r) => sum + r.quantity);
  }

  double getTotalMilkRejected() {
    return _receptions
        .where((r) => !r.qualityPassed)
        .fold(0, (sum, r) => sum + r.quantity);
  }

  double getTotalCapacity() {
    return _centers.fold(0, (sum, c) => sum + c.capacity);
  }

  double getTotalStock() {
    return _centers.fold(0, (sum, c) => sum + c.currentStock);
  }

  List<CollectionCenterModel> getActiveCenters() {
    return _centers.where((c) => c.status == CenterStatus.active).toList();
  }

  List<CollectionCenterModel> searchCenters(String query) {
    final lowerQuery = query.toLowerCase();
    return _centers.where((center) {
      return center.name.toLowerCase().contains(lowerQuery) ||
             center.code.toLowerCase().contains(lowerQuery) ||
             center.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
