import 'package:hive/hive.dart';

part 'processing_batch_model.g.dart';

@HiveType(typeId: 19)
class ProcessingBatchModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String batchNumber;

  @HiveField(2)
  ProcessingType processingType;

  @HiveField(3)
  BatchStatus status;

  @HiveField(4)
  DateTime startTime;

  @HiveField(5)
  DateTime? endTime;

  @HiveField(6)
  double rawMilkQuantity; // in liters

  @HiveField(7)
  String? rawMilkSource; // supplier or collection reference

  @HiveField(8)
  List<ProcessingOutput> outputs;

  @HiveField(9)
  List<QualityCheck> qualityChecks;

  @HiveField(10)
  double? temperature; // processing temperature in Celsius

  @HiveField(11)
  int? duration; // processing duration in minutes

  @HiveField(12)
  String? operatorId; // staff member who processed

  @HiveField(13)
  String? operatorName;

  @HiveField(14)
  double? energyConsumed; // electricity units consumed

  @HiveField(15)
  double? waterUsed; // water in liters

  @HiveField(16)
  List<AdditionalMaterial> additionalMaterials;

  @HiveField(17)
  String? equipmentUsed;

  @HiveField(18)
  String? notes;

  @HiveField(19)
  double? productionCost;

  @HiveField(20)
  double? yieldPercentage; // output quantity / input quantity * 100

  @HiveField(21)
  DateTime createdAt;

  @HiveField(22)
  DateTime updatedAt;

  ProcessingBatchModel({
    required this.id,
    required this.batchNumber,
    required this.processingType,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.rawMilkQuantity,
    this.rawMilkSource,
    required this.outputs,
    required this.qualityChecks,
    this.temperature,
    this.duration,
    this.operatorId,
    this.operatorName,
    this.energyConsumed,
    this.waterUsed,
    required this.additionalMaterials,
    this.equipmentUsed,
    this.notes,
    this.productionCost,
    this.yieldPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProcessingBatchModel.fromJson(Map<String, dynamic> json) {
    return ProcessingBatchModel(
      id: json['id'],
      batchNumber: json['batchNumber'],
      processingType: ProcessingType.values[json['processingType']],
      status: BatchStatus.values[json['status']],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      rawMilkQuantity: json['rawMilkQuantity'].toDouble(),
      rawMilkSource: json['rawMilkSource'],
      outputs: (json['outputs'] as List).map((e) => ProcessingOutput.fromJson(e)).toList(),
      qualityChecks: (json['qualityChecks'] as List).map((e) => QualityCheck.fromJson(e)).toList(),
      temperature: json['temperature']?.toDouble(),
      duration: json['duration'],
      operatorId: json['operatorId'],
      operatorName: json['operatorName'],
      energyConsumed: json['energyConsumed']?.toDouble(),
      waterUsed: json['waterUsed']?.toDouble(),
      additionalMaterials: (json['additionalMaterials'] as List).map((e) => AdditionalMaterial.fromJson(e)).toList(),
      equipmentUsed: json['equipmentUsed'],
      notes: json['notes'],
      productionCost: json['productionCost']?.toDouble(),
      yieldPercentage: json['yieldPercentage']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchNumber': batchNumber,
      'processingType': processingType.index,
      'status': status.index,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'rawMilkQuantity': rawMilkQuantity,
      'rawMilkSource': rawMilkSource,
      'outputs': outputs.map((e) => e.toJson()).toList(),
      'qualityChecks': qualityChecks.map((e) => e.toJson()).toList(),
      'temperature': temperature,
      'duration': duration,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'energyConsumed': energyConsumed,
      'waterUsed': waterUsed,
      'additionalMaterials': additionalMaterials.map((e) => e.toJson()).toList(),
      'equipmentUsed': equipmentUsed,
      'notes': notes,
      'productionCost': productionCost,
      'yieldPercentage': yieldPercentage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static String generateId() {
    return 'BATCH-${DateTime.now().millisecondsSinceEpoch}';
  }

  static String generateBatchNumber() {
    final now = DateTime.now();
    return 'BTH${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 10000}';
  }
}

@HiveType(typeId: 20)
enum ProcessingType {
  @HiveField(0)
  pasteurization,

  @HiveField(1)
  homogenization,

  @HiveField(2)
  creamSeparation,

  @HiveField(3)
  butterMaking,

  @HiveField(4)
  cheeseProduction,

  @HiveField(5)
  yogurtProduction,

  @HiveField(6)
  paneerMaking,

  @HiveField(7)
  gheeProduction,

  @HiveField(8)
  milkPowder,

  @HiveField(9)
  iceCream,

  @HiveField(10)
  flavoredMilk,

  @HiveField(11)
  condensedMilk,
}

@HiveType(typeId: 21)
enum BatchStatus {
  @HiveField(0)
  planned,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  qualityCheck,

  @HiveField(3)
  completed,

  @HiveField(4)
  rejected,

  @HiveField(5)
  cancelled,
}

@HiveType(typeId: 22)
class ProcessingOutput extends HiveObject {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  String unit; // liters, kg, pieces

  @HiveField(4)
  double? qualityScore; // 0-100

  @HiveField(5)
  String? remarks;

  ProcessingOutput({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    this.qualityScore,
    this.remarks,
  });

  factory ProcessingOutput.fromJson(Map<String, dynamic> json) {
    return ProcessingOutput(
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      qualityScore: json['qualityScore']?.toDouble(),
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'qualityScore': qualityScore,
      'remarks': remarks,
    };
  }
}

@HiveType(typeId: 23)
class QualityCheck extends HiveObject {
  @HiveField(0)
  String parameter;

  @HiveField(1)
  String value;

  @HiveField(2)
  String? expectedRange;

  @HiveField(3)
  bool isPassed;

  @HiveField(4)
  DateTime checkedAt;

  @HiveField(5)
  String? checkedBy;

  QualityCheck({
    required this.parameter,
    required this.value,
    this.expectedRange,
    required this.isPassed,
    required this.checkedAt,
    this.checkedBy,
  });

  factory QualityCheck.fromJson(Map<String, dynamic> json) {
    return QualityCheck(
      parameter: json['parameter'],
      value: json['value'],
      expectedRange: json['expectedRange'],
      isPassed: json['isPassed'],
      checkedAt: DateTime.parse(json['checkedAt']),
      checkedBy: json['checkedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameter': parameter,
      'value': value,
      'expectedRange': expectedRange,
      'isPassed': isPassed,
      'checkedAt': checkedAt.toIso8601String(),
      'checkedBy': checkedBy,
    };
  }
}

@HiveType(typeId: 24)
class AdditionalMaterial extends HiveObject {
  @HiveField(0)
  String materialName;

  @HiveField(1)
  double quantity;

  @HiveField(2)
  String unit;

  @HiveField(3)
  double? cost;

  AdditionalMaterial({
    required this.materialName,
    required this.quantity,
    required this.unit,
    this.cost,
  });

  factory AdditionalMaterial.fromJson(Map<String, dynamic> json) {
    return AdditionalMaterial(
      materialName: json['materialName'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      cost: json['cost']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialName': materialName,
      'quantity': quantity,
      'unit': unit,
      'cost': cost,
    };
  }
}

// Helper extensions
extension ProcessingTypeExtension on ProcessingType {
  String get displayName {
    switch (this) {
      case ProcessingType.pasteurization:
        return 'Pasteurization';
      case ProcessingType.homogenization:
        return 'Homogenization';
      case ProcessingType.creamSeparation:
        return 'Cream Separation';
      case ProcessingType.butterMaking:
        return 'Butter Making';
      case ProcessingType.cheeseProduction:
        return 'Cheese Production';
      case ProcessingType.yogurtProduction:
        return 'Yogurt Production';
      case ProcessingType.paneerMaking:
        return 'Paneer Making';
      case ProcessingType.gheeProduction:
        return 'Ghee Production';
      case ProcessingType.milkPowder:
        return 'Milk Powder';
      case ProcessingType.iceCream:
        return 'Ice Cream';
      case ProcessingType.flavoredMilk:
        return 'Flavored Milk';
      case ProcessingType.condensedMilk:
        return 'Condensed Milk';
    }
  }
}

extension BatchStatusExtension on BatchStatus {
  String get displayName {
    switch (this) {
      case BatchStatus.planned:
        return 'Planned';
      case BatchStatus.inProgress:
        return 'In Progress';
      case BatchStatus.qualityCheck:
        return 'Quality Check';
      case BatchStatus.completed:
        return 'Completed';
      case BatchStatus.rejected:
        return 'Rejected';
      case BatchStatus.cancelled:
        return 'Cancelled';
    }
  }
}
