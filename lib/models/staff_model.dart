import 'package:hive/hive.dart';

part 'staff_model.g.dart';

@HiveType(typeId: 17)
class StaffModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? address;

  @HiveField(5)
  StaffRole role;

  @HiveField(6)
  String? department;

  @HiveField(7)
  double salary;

  @HiveField(8)
  DateTime joiningDate;

  @HiveField(9)
  DateTime? relievingDate;

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  String? aadharNumber;

  @HiveField(12)
  String? panNumber;

  @HiveField(13)
  String? bankAccountNumber;

  @HiveField(14)
  String? ifscCode;

  @HiveField(15)
  String? emergencyContact;

  @HiveField(16)
  String? profileImagePath;

  @HiveField(17)
  List<String> permissions;

  @HiveField(18)
  String? notes;

  @HiveField(19)
  DateTime createdAt;

  @HiveField(20)
  DateTime updatedAt;

  @HiveField(21)
  bool isSynced;

  @HiveField(22)
  String? username;

  @HiveField(23)
  String? passwordHash;

  StaffModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.role,
    this.department,
    required this.salary,
    required this.joiningDate,
    this.relievingDate,
    this.isActive = true,
    this.aadharNumber,
    this.panNumber,
    this.bankAccountNumber,
    this.ifscCode,
    this.emergencyContact,
    this.profileImagePath,
    List<String>? permissions,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.username,
    this.passwordHash,
  }) : permissions = permissions ?? [];

  // Generate unique staff ID
  static String generateId() {
    return 'STF-${DateTime.now().millisecondsSinceEpoch}';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'role': role.toString(),
      'department': department,
      'salary': salary,
      'joiningDate': joiningDate.toIso8601String(),
      'relievingDate': relievingDate?.toIso8601String(),
      'isActive': isActive,
      'aadharNumber': aadharNumber,
      'panNumber': panNumber,
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'emergencyContact': emergencyContact,
      'profileImagePath': profileImagePath,
      'permissions': permissions,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  // Create from JSON
  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      role: StaffRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => StaffRole.staff,
      ),
      department: json['department'],
      salary: (json['salary'] ?? 0.0).toDouble(),
      joiningDate: DateTime.parse(json['joiningDate']),
      relievingDate: json['relievingDate'] != null
          ? DateTime.parse(json['relievingDate'])
          : null,
      isActive: json['isActive'] ?? true,
      aadharNumber: json['aadharNumber'],
      panNumber: json['panNumber'],
      bankAccountNumber: json['bankAccountNumber'],
      ifscCode: json['ifscCode'],
      emergencyContact: json['emergencyContact'],
      profileImagePath: json['profileImagePath'],
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'])
          : [],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? false,
    );
  }

  // Copy with method
  StaffModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    StaffRole? role,
    String? department,
    double? salary,
    DateTime? joiningDate,
    DateTime? relievingDate,
    bool? isActive,
    String? aadharNumber,
    String? panNumber,
    String? bankAccountNumber,
    String? ifscCode,
    String? emergencyContact,
    String? profileImagePath,
    List<String>? permissions,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
      department: department ?? this.department,
      salary: salary ?? this.salary,
      joiningDate: joiningDate ?? this.joiningDate,
      relievingDate: relievingDate ?? this.relievingDate,
      isActive: isActive ?? this.isActive,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panNumber: panNumber ?? this.panNumber,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      permissions: permissions ?? this.permissions,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // Check if staff has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
}

@HiveType(typeId: 18)
enum StaffRole {
  @HiveField(0)
  admin,

  @HiveField(1)
  manager,

  @HiveField(2)
  supervisor,

  @HiveField(3)
  collectionAgent,

  @HiveField(4)
  salesPerson,

  @HiveField(5)
  accountant,

  @HiveField(6)
  driver,

  @HiveField(7)
  staff,
}

// Permission constants
class StaffPermissions {
  static const String viewFarmers = 'view_farmers';
  static const String addFarmers = 'add_farmers';
  static const String editFarmers = 'edit_farmers';
  static const String deleteFarmers = 'delete_farmers';
  
  static const String viewMilkCollection = 'view_milk_collection';
  static const String addMilkCollection = 'add_milk_collection';
  static const String editMilkCollection = 'edit_milk_collection';
  static const String deleteMilkCollection = 'delete_milk_collection';
  
  static const String viewProducts = 'view_products';
  static const String addProducts = 'add_products';
  static const String editProducts = 'edit_products';
  static const String deleteProducts = 'delete_products';
  
  static const String viewSales = 'view_sales';
  static const String addSales = 'add_sales';
  static const String editSales = 'edit_sales';
  static const String deleteSales = 'delete_sales';
  
  static const String viewPurchases = 'view_purchases';
  static const String addPurchases = 'add_purchases';
  static const String editPurchases = 'edit_purchases';
  static const String deletePurchases = 'delete_purchases';
  
  static const String viewExpenses = 'view_expenses';
  static const String addExpenses = 'add_expenses';
  static const String editExpenses = 'edit_expenses';
  static const String deleteExpenses = 'delete_expenses';
  
  static const String viewReports = 'view_reports';
  static const String viewStaff = 'view_staff';
  static const String manageStaff = 'manage_staff';
  static const String viewSettings = 'view_settings';
  static const String manageSettings = 'manage_settings';
  
  // Get default permissions by role
  static List<String> getDefaultPermissions(StaffRole role) {
    switch (role) {
      case StaffRole.admin:
        return [
          viewFarmers, addFarmers, editFarmers, deleteFarmers,
          viewMilkCollection, addMilkCollection, editMilkCollection, deleteMilkCollection,
          viewProducts, addProducts, editProducts, deleteProducts,
          viewSales, addSales, editSales, deleteSales,
          viewPurchases, addPurchases, editPurchases, deletePurchases,
          viewExpenses, addExpenses, editExpenses, deleteExpenses,
          viewReports, viewStaff, manageStaff, viewSettings, manageSettings,
        ];
      
      case StaffRole.manager:
        return [
          viewFarmers, addFarmers, editFarmers,
          viewMilkCollection, addMilkCollection, editMilkCollection,
          viewProducts, addProducts, editProducts,
          viewSales, addSales, editSales,
          viewPurchases, addPurchases, editPurchases,
          viewExpenses, addExpenses, editExpenses,
          viewReports, viewStaff, viewSettings,
        ];
      
      case StaffRole.supervisor:
        return [
          viewFarmers, addFarmers, editFarmers,
          viewMilkCollection, addMilkCollection, editMilkCollection,
          viewProducts, viewSales, addSales,
          viewReports,
        ];
      
      case StaffRole.collectionAgent:
        return [
          viewFarmers, addFarmers,
          viewMilkCollection, addMilkCollection,
        ];
      
      case StaffRole.salesPerson:
        return [
          viewProducts,
          viewSales, addSales,
        ];
      
      case StaffRole.accountant:
        return [
          viewFarmers,
          viewMilkCollection,
          viewProducts,
          viewSales,
          viewPurchases,
          viewExpenses,
          viewReports,
        ];
      
      case StaffRole.driver:
        return [
          viewMilkCollection,
          viewProducts,
          viewSales,
        ];
      
      case StaffRole.staff:
        return [
          viewFarmers,
          viewMilkCollection,
          viewProducts,
        ];
    }
  }
}
