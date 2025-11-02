import 'package:flutter/material.dart';
import '../models/processing_batch_model.dart';
import '../services/hive_service.dart';

class ProcessingController extends ChangeNotifier {
  List<ProcessingBatchModel> _batches = [];
  List<ProcessingBatchModel> _filteredBatches = [];
  bool _isLoading = false;
  String _searchQuery = '';
  ProcessingType? _selectedType;
  BatchStatus? _selectedStatus;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  List<ProcessingBatchModel> get batches => _filteredBatches;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  ProcessingType? get selectedType => _selectedType;
  BatchStatus? get selectedStatus => _selectedStatus;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;

  Future<void> loadBatches() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await HiveService.getProcessingBatchesBox();
      _batches = box.values.cast<ProcessingBatchModel>().toList();
      _batches.sort((a, b) => b.startTime.compareTo(a.startTime));
      _applyFilters();
    } catch (e) {
      print('Error loading processing batches: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBatch(ProcessingBatchModel batch) async {
    try {
      final box = await HiveService.getProcessingBatchesBox();
      await box.put(batch.id, batch);
      _batches.add(batch);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Error adding batch: $e');
      rethrow;
    }
  }

  Future<void> updateBatch(ProcessingBatchModel batch) async {
    try {
      batch.updatedAt = DateTime.now();
      final box = await HiveService.getProcessingBatchesBox();
      await box.put(batch.id, batch);
      
      final index = _batches.indexWhere((b) => b.id == batch.id);
      if (index != -1) {
        _batches[index] = batch;
      }
      
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Error updating batch: $e');
      rethrow;
    }
  }

  Future<void> deleteBatch(String batchId) async {
    try {
      final box = await HiveService.getProcessingBatchesBox();
      await box.delete(batchId);
      _batches.removeWhere((batch) => batch.id == batchId);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Error deleting batch: $e');
      rethrow;
    }
  }

  ProcessingBatchModel? getBatchById(String batchId) {
    try {
      return _batches.firstWhere((batch) => batch.id == batchId);
    } catch (e) {
      return null;
    }
  }

  void searchBatches(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByType(ProcessingType? type) {
    _selectedType = type;
    _applyFilters();
  }

  void filterByStatus(BatchStatus? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void filterByDateRange(DateTime? startDate, DateTime? endDate) {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _selectedStatus = null;
    _filterStartDate = null;
    _filterEndDate = null;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredBatches = _batches.where((batch) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!batch.batchNumber.toLowerCase().contains(query) &&
            !batch.processingType.displayName.toLowerCase().contains(query) &&
            !(batch.operatorName?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Type filter
      if (_selectedType != null && batch.processingType != _selectedType) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && batch.status != _selectedStatus) {
        return false;
      }

      // Date range filter
      if (_filterStartDate != null && batch.startTime.isBefore(_filterStartDate!)) {
        return false;
      }
      if (_filterEndDate != null && batch.startTime.isAfter(_filterEndDate!)) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Statistics methods
  Map<String, dynamic> getStatistics() {
    final totalBatches = _batches.length;
    final completedBatches = _batches.where((b) => b.status == BatchStatus.completed).length;
    final inProgressBatches = _batches.where((b) => b.status == BatchStatus.inProgress).length;
    final rejectedBatches = _batches.where((b) => b.status == BatchStatus.rejected).length;

    final totalMilkProcessed = _batches
        .where((b) => b.status == BatchStatus.completed)
        .fold(0.0, (sum, batch) => sum + batch.rawMilkQuantity);

    final totalProductionCost = _batches
        .where((b) => b.status == BatchStatus.completed)
        .fold(0.0, (sum, batch) => sum + (batch.productionCost ?? 0));

    final avgYieldPercentage = _batches
        .where((b) => b.status == BatchStatus.completed && b.yieldPercentage != null)
        .fold(0.0, (sum, batch) => sum + batch.yieldPercentage!) /
        (_batches.where((b) => b.status == BatchStatus.completed && b.yieldPercentage != null).length > 0
            ? _batches.where((b) => b.status == BatchStatus.completed && b.yieldPercentage != null).length
            : 1);

    // Type breakdown
    final typeBreakdown = <ProcessingType, int>{};
    for (var batch in _batches) {
      typeBreakdown[batch.processingType] = (typeBreakdown[batch.processingType] ?? 0) + 1;
    }

    // Status breakdown
    final statusBreakdown = <BatchStatus, int>{};
    for (var batch in _batches) {
      statusBreakdown[batch.status] = (statusBreakdown[batch.status] ?? 0) + 1;
    }

    return {
      'totalBatches': totalBatches,
      'completedBatches': completedBatches,
      'inProgressBatches': inProgressBatches,
      'rejectedBatches': rejectedBatches,
      'totalMilkProcessed': totalMilkProcessed,
      'totalProductionCost': totalProductionCost,
      'avgYieldPercentage': avgYieldPercentage,
      'typeBreakdown': typeBreakdown,
      'statusBreakdown': statusBreakdown,
    };
  }

  List<ProcessingBatchModel> getTodaysBatches() {
    final today = DateTime.now();
    return _batches.where((batch) {
      return batch.startTime.year == today.year &&
          batch.startTime.month == today.month &&
          batch.startTime.day == today.day;
    }).toList();
  }

  List<ProcessingBatchModel> getThisMonthBatches() {
    final today = DateTime.now();
    return _batches.where((batch) {
      return batch.startTime.year == today.year &&
          batch.startTime.month == today.month;
    }).toList();
  }

  List<ProcessingBatchModel> getBatchesByType(ProcessingType type) {
    return _batches.where((batch) => batch.processingType == type).toList();
  }

  List<ProcessingBatchModel> getBatchesByStatus(BatchStatus status) {
    return _batches.where((batch) => batch.status == status).toList();
  }

  List<ProcessingBatchModel> getBatchesByDateRange(DateTime startDate, DateTime endDate) {
    return _batches.where((batch) {
      return batch.startTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
          batch.startTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Quality statistics
  Map<String, dynamic> getQualityStatistics() {
    final batchesWithQuality = _batches
        .where((b) => b.status == BatchStatus.completed && b.qualityChecks.isNotEmpty)
        .toList();

    if (batchesWithQuality.isEmpty) {
      return {
        'totalChecks': 0,
        'passedChecks': 0,
        'failedChecks': 0,
        'passRate': 0.0,
      };
    }

    int totalChecks = 0;
    int passedChecks = 0;

    for (var batch in batchesWithQuality) {
      for (var check in batch.qualityChecks) {
        totalChecks++;
        if (check.isPassed) passedChecks++;
      }
    }

    final passRate = totalChecks > 0 ? (passedChecks / totalChecks) * 100 : 0.0;

    return {
      'totalChecks': totalChecks,
      'passedChecks': passedChecks,
      'failedChecks': totalChecks - passedChecks,
      'passRate': passRate,
    };
  }

  // Production efficiency
  Map<String, dynamic> getProductionEfficiency() {
    final completedBatches = _batches.where((b) => b.status == BatchStatus.completed).toList();

    if (completedBatches.isEmpty) {
      return {
        'avgProcessingTime': 0,
        'avgYield': 0.0,
        'avgCostPerLiter': 0.0,
      };
    }

    final totalDuration = completedBatches
        .where((b) => b.duration != null)
        .fold(0, (sum, batch) => sum + batch.duration!);
    final avgProcessingTime = totalDuration / completedBatches.where((b) => b.duration != null).length;

    final totalYield = completedBatches
        .where((b) => b.yieldPercentage != null)
        .fold(0.0, (sum, batch) => sum + batch.yieldPercentage!);
    final avgYield = totalYield / completedBatches.where((b) => b.yieldPercentage != null).length;

    final totalMilk = completedBatches.fold(0.0, (sum, batch) => sum + batch.rawMilkQuantity);
    final totalCost = completedBatches.fold(0.0, (sum, batch) => sum + (batch.productionCost ?? 0));
    final avgCostPerLiter = totalMilk > 0 ? totalCost / totalMilk : 0.0;

    return {
      'avgProcessingTime': avgProcessingTime.toInt(),
      'avgYield': avgYield,
      'avgCostPerLiter': avgCostPerLiter,
    };
  }

  // Resource consumption
  Map<String, dynamic> getResourceConsumption() {
    final completedBatches = _batches.where((b) => b.status == BatchStatus.completed).toList();

    final totalEnergy = completedBatches
        .where((b) => b.energyConsumed != null)
        .fold(0.0, (sum, batch) => sum + batch.energyConsumed!);

    final totalWater = completedBatches
        .where((b) => b.waterUsed != null)
        .fold(0.0, (sum, batch) => sum + batch.waterUsed!);

    // Additional materials cost
    double totalMaterialsCost = 0.0;
    for (var batch in completedBatches) {
      for (var material in batch.additionalMaterials) {
        totalMaterialsCost += material.cost ?? 0;
      }
    }

    return {
      'totalEnergy': totalEnergy,
      'totalWater': totalWater,
      'totalMaterialsCost': totalMaterialsCost,
    };
  }

  // Batch status update helpers
  Future<void> startBatch(String batchId) async {
    final batch = getBatchById(batchId);
    if (batch != null) {
      batch.status = BatchStatus.inProgress;
      batch.startTime = DateTime.now();
      await updateBatch(batch);
    }
  }

  Future<void> completeBatch(String batchId) async {
    final batch = getBatchById(batchId);
    if (batch != null) {
      batch.status = BatchStatus.completed;
      batch.endTime = DateTime.now();
      
      // Calculate duration if not set
      if (batch.duration == null) {
        batch.duration = batch.endTime!.difference(batch.startTime).inMinutes;
      }
      
      await updateBatch(batch);
    }
  }

  Future<void> sendToQualityCheck(String batchId) async {
    final batch = getBatchById(batchId);
    if (batch != null) {
      batch.status = BatchStatus.qualityCheck;
      await updateBatch(batch);
    }
  }

  Future<void> rejectBatch(String batchId, String reason) async {
    final batch = getBatchById(batchId);
    if (batch != null) {
      batch.status = BatchStatus.rejected;
      batch.endTime = DateTime.now();
      batch.notes = '${batch.notes ?? ''}\nRejection Reason: $reason';
      await updateBatch(batch);
    }
  }

  Future<void> cancelBatch(String batchId, String reason) async {
    final batch = getBatchById(batchId);
    if (batch != null) {
      batch.status = BatchStatus.cancelled;
      batch.notes = '${batch.notes ?? ''}\nCancellation Reason: $reason';
      await updateBatch(batch);
    }
  }
}
