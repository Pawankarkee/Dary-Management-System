import 'package:hive/hive.dart';

part 'supplier_model.g.dart';

@HiveType(typeId: 7)
class SupplierModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String contactPerson;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String? email;

  @HiveField(5)
  String address;

  @HiveField(6)
  String? gstin;

  @HiveField(7)
  SupplierType supplierType;

  @HiveField(8)
  double openingBalance;

  @HiveField(9)
  double currentBalance;

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  @HiveField(13)
  String? notes;

  SupplierModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    this.email,
    required this.address,
    this.gstin,
    required this.supplierType,
    this.openingBalance = 0.0,
    this.currentBalance = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  // Generate unique supplier ID
  static String generateId() {
    return 'SUP-${DateTime.now().millisecondsSinceEpoch}';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'gstin': gstin,
      'supplierType': supplierType.toString(),
      'openingBalance': openingBalance,
      'currentBalance': currentBalance,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
    };
  }

  // Create from JSON
  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      name: json['name'],
      contactPerson: json['contactPerson'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      gstin: json['gstin'],
      supplierType: SupplierType.values.firstWhere(
        (e) => e.toString() == json['supplierType'],
        orElse: () => SupplierType.general,
      ),
      openingBalance: (json['openingBalance'] ?? 0.0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0.0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      notes: json['notes'],
    );
  }

  // Copy with method
  SupplierModel copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? gstin,
    SupplierType? supplierType,
    double? openingBalance,
    double? currentBalance,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      supplierType: supplierType ?? this.supplierType,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}

@HiveType(typeId: 8)
enum SupplierType {
  @HiveField(0)
  general,

  @HiveField(1)
  feed,

  @HiveField(2)
  packaging,

  @HiveField(3)
  equipment,

  @HiveField(4)
  other,
}
