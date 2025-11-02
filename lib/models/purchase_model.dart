import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'purchase_model.g.dart';

@HiveType(typeId: 9)
class PurchaseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String supplierId;

  @HiveField(2)
  String supplierName;

  @HiveField(3)
  String invoiceNumber;

  @HiveField(4)
  DateTime purchaseDate;

  @HiveField(5)
  DateTime dueDate;

  @HiveField(6)
  List<PurchaseItemModel> items;

  @HiveField(7)
  double subtotal;

  @HiveField(8)
  double taxAmount;

  @HiveField(9)
  double otherCharges;

  @HiveField(10)
  double discount;

  @HiveField(11)
  double totalAmount;

  @HiveField(12)
  double paidAmount;

  @HiveField(13)
  double balanceAmount;

  @HiveField(14)
  PurchaseStatus status;

  @HiveField(15)
  PaymentStatus paymentStatus;

  @HiveField(16)
  String? notes;

  @HiveField(17)
  DateTime createdAt;

  @HiveField(18)
  DateTime updatedAt;

  @HiveField(19)
  bool isSynced;

  PurchaseModel({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.invoiceNumber,
    required this.purchaseDate,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    this.taxAmount = 0.0,
    this.otherCharges = 0.0,
    this.discount = 0.0,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.balanceAmount,
    this.status = PurchaseStatus.pending,
    this.paymentStatus = PaymentStatus.unpaid,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  // Generate unique purchase ID
  static String generateId() {
    const uuid = Uuid();
    return 'PUR-${DateTime.now().millisecondsSinceEpoch}-${uuid.v4().substring(0, 8)}';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'invoiceNumber': invoiceNumber,
      'purchaseDate': purchaseDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'otherCharges': otherCharges,
      'discount': discount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'balanceAmount': balanceAmount,
      'status': status.toString(),
      'paymentStatus': paymentStatus.toString(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  // Create from JSON
  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      invoiceNumber: json['invoiceNumber'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      dueDate: DateTime.parse(json['dueDate']),
      items: (json['items'] as List)
          .map((item) => PurchaseItemModel.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0.0).toDouble(),
      otherCharges: (json['otherCharges'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0.0).toDouble(),
      balanceAmount: (json['balanceAmount'] ?? 0.0).toDouble(),
      status: PurchaseStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PurchaseStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['paymentStatus'],
        orElse: () => PaymentStatus.unpaid,
      ),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? false,
    );
  }
}

@HiveType(typeId: 10)
class PurchaseItemModel {
  @HiveField(0)
  String itemName;

  @HiveField(1)
  String description;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  String unit;

  @HiveField(4)
  double rate;

  @HiveField(5)
  double amount;

  @HiveField(6)
  double? taxRate;

  @HiveField(7)
  double? taxAmount;

  PurchaseItemModel({
    required this.itemName,
    this.description = '',
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.amount,
    this.taxRate,
    this.taxAmount,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'amount': amount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
    };
  }

  // Create from JSON
  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      itemName: json['itemName'],
      description: json['description'] ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? 'Unit',
      rate: (json['rate'] ?? 0.0).toDouble(),
      amount: (json['amount'] ?? 0.0).toDouble(),
      taxRate: json['taxRate']?.toDouble(),
      taxAmount: json['taxAmount']?.toDouble(),
    );
  }
}

@HiveType(typeId: 11)
enum PurchaseStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  received,

  @HiveField(2)
  cancelled,
}

@HiveType(typeId: 12)
enum PaymentStatus {
  @HiveField(0)
  unpaid,

  @HiveField(1)
  partial,

  @HiveField(2)
  paid,
}
