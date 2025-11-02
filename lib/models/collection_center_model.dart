import 'package:hive/hive.dart';

part 'collection_center_model.g.dart';

@HiveType(typeId: 18)
class CollectionCenterModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String code;

  @HiveField(3)
  String address;

  @HiveField(4)
  String contactPerson;

  @HiveField(5)
  String phone;

  @HiveField(6)
  double capacity; // in liters

  @HiveField(7)
  CenterStatus status;

  @HiveField(8)
  double currentStock;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  CollectionCenterModel({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.contactPerson,
    required this.phone,
    required this.capacity,
    this.status = CenterStatus.active,
    this.currentStock = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  double get capacityUtilization => (currentStock / capacity * 100).clamp(0, 100);
  double get availableSpace => (capacity - currentStock).clamp(0, capacity);
}

@HiveType(typeId: 19)
enum CenterStatus {
  @HiveField(0)
  active,
  
  @HiveField(1)
  inactive,
  
  @HiveField(2)
  maintenance,
}

@HiveType(typeId: 20)
class MilkReceptionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String centerId;

  @HiveField(2)
  String centerName;

  @HiveField(3)
  String farmerId;

  @HiveField(4)
  String farmerName;

  @HiveField(5)
  double quantity;

  @HiveField(6)
  double fat;

  @HiveField(7)
  double snf;

  @HiveField(8)
  double temperature;

  @HiveField(9)
  bool qualityPassed;

  @HiveField(10)
  DateTime receptionTime;

  @HiveField(11)
  String receivedBy;

  @HiveField(12)
  String? remarks;

  MilkReceptionModel({
    required this.id,
    required this.centerId,
    required this.centerName,
    required this.farmerId,
    required this.farmerName,
    required this.quantity,
    required this.fat,
    required this.snf,
    required this.temperature,
    required this.qualityPassed,
    required this.receptionTime,
    required this.receivedBy,
    this.remarks,
  });
}
