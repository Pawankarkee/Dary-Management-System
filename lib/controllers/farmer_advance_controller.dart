import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/farmer_advance_model.dart';
import '../services/hive_service.dart';

class FarmerAdvanceController extends ChangeNotifier {
  List<FarmerAdvanceModel> _advances = [];
  List<AdvancePaymentModel> _payments = [];
  bool _isLoading = false;
  String? _error;

  List<FarmerAdvanceModel> get advances => _advances;
  List<AdvancePaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FarmerAdvanceController() {
    loadAdvances();
  }

  Future<void> loadAdvances() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await Hive.openBox<FarmerAdvanceModel>('farmer_advances');
      _advances = box.values.toList();
      _advances.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      final paymentBox = await Hive.openBox<AdvancePaymentModel>('advance_payments');
      _payments = paymentBox.values.toList();
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading advances: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAdvance(FarmerAdvanceModel advance) async {
    try {
      final box = await Hive.openBox<FarmerAdvanceModel>('farmer_advances');
      await box.put(advance.id, advance);
      await loadAdvances();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAdvance(FarmerAdvanceModel advance) async {
    try {
      advance.updatedAt = DateTime.now();
      final box = await Hive.openBox<FarmerAdvanceModel>('farmer_advances');
      await box.put(advance.id, advance);
      await loadAdvances();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAdvance(String id) async {
    try {
      final box = await Hive.openBox<FarmerAdvanceModel>('farmer_advances');
      await box.delete(id);
      await loadAdvances();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addPayment(AdvancePaymentModel payment, FarmerAdvanceModel advance) async {
    try {
      final paymentBox = await Hive.openBox<AdvancePaymentModel>('advance_payments');
      await paymentBox.put(payment.id, payment);
      
      // Update advance
      advance.paidAmount += payment.amount;
      advance.remainingAmount -= payment.amount;
      
      if (advance.remainingAmount <= 0) {
        advance.status = AdvanceStatus.completed;
        advance.remainingAmount = 0;
      }
      
      await updateAdvance(advance);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<FarmerAdvanceModel> getAdvancesByFarmer(String farmerId) {
    return _advances.where((a) => a.farmerId == farmerId).toList();
  }

  List<AdvancePaymentModel> getPaymentsByAdvance(String advanceId) {
    return _payments.where((p) => p.advanceId == advanceId).toList();
  }

  double getTotalAdvanceAmount() {
    return _advances.fold(0, (sum, advance) => sum + advance.amount);
  }

  double getTotalOutstanding() {
    return _advances
        .where((a) => a.status == AdvanceStatus.active)
        .fold(0, (sum, advance) => sum + advance.remainingAmount);
  }

  double getTotalPaidAmount() {
    return _advances.fold(0, (sum, advance) => sum + advance.paidAmount);
  }

  List<FarmerAdvanceModel> getOverdueAdvances() {
    final now = DateTime.now();
    return _advances.where((a) => 
      a.status == AdvanceStatus.active && 
      a.dueDate != null && 
      a.dueDate!.isBefore(now)
    ).toList();
  }

  List<FarmerAdvanceModel> searchAdvances(String query) {
    final lowerQuery = query.toLowerCase();
    return _advances.where((advance) {
      return advance.farmerName.toLowerCase().contains(lowerQuery) ||
             advance.purpose.toLowerCase().contains(lowerQuery) ||
             advance.id.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<FarmerAdvanceModel> filterByStatus(AdvanceStatus status) {
    return _advances.where((a) => a.status == status).toList();
  }
}
