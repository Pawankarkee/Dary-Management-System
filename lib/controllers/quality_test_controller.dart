import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/quality_test_model.dart';

class QualityTestController extends ChangeNotifier {
  List<QualityTestModel> _tests = [];
  List<QualityStandardModel> _standards = [];
  bool _isLoading = false;
  String? _error;

  List<QualityTestModel> get tests => _tests;
  List<QualityStandardModel> get standards => _standards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  QualityTestController() {
    loadTests();
  }

  Future<void> loadTests() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await Hive.openBox<QualityTestModel>('quality_tests');
      _tests = box.values.toList();
      _tests.sort((a, b) => b.testDate.compareTo(a.testDate));
      
      final standardsBox = await Hive.openBox<QualityStandardModel>('quality_standards');
      _standards = standardsBox.values.toList();
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading tests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTest(QualityTestModel test) async {
    try {
      final box = await Hive.openBox<QualityTestModel>('quality_tests');
      await box.put(test.id, test);
      await loadTests();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTest(QualityTestModel test) async {
    try {
      final box = await Hive.openBox<QualityTestModel>('quality_tests');
      await box.put(test.id, test);
      await loadTests();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTest(String id) async {
    try {
      final box = await Hive.openBox<QualityTestModel>('quality_tests');
      await box.delete(id);
      await loadTests();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<QualityTestModel> getTestsByFarmer(String farmerId) {
    return _tests.where((t) => t.farmerId == farmerId).toList();
  }

  List<QualityTestModel> getTestsByResult(TestResult result) {
    return _tests.where((t) => t.result == result).toList();
  }

  List<QualityTestModel> getTestsWithAdulteration() {
    return _tests.where((t) => t.hasAdulteration).toList();
  }

  double getAverageFat() {
    if (_tests.isEmpty) return 0;
    return _tests.fold(0.0, (sum, t) => sum + t.fatPercentage) / _tests.length;
  }

  double getAverageSnf() {
    if (_tests.isEmpty) return 0;
    return _tests.fold(0.0, (sum, t) => sum + t.snfPercentage) / _tests.length;
  }

  int getPassedCount() {
    return _tests.where((t) => t.result == TestResult.passed).length;
  }

  int getFailedCount() {
    return _tests.where((t) => t.result == TestResult.failed).length;
  }

  int getRejectedCount() {
    return _tests.where((t) => t.result == TestResult.rejected).length;
  }

  double getPassPercentage() {
    if (_tests.isEmpty) return 0;
    return (getPassedCount() / _tests.length * 100);
  }

  List<QualityTestModel> searchTests(String query) {
    final lowerQuery = query.toLowerCase();
    return _tests.where((test) {
      return test.farmerName.toLowerCase().contains(lowerQuery) ||
             test.sampleId.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
