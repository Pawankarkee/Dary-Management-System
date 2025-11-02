import 'package:uuid/uuid.dart';

enum PaymentMethod {
  cash,
  upi,
  card,
  cheque,
  credit,
}

class SaleItemModel {
  final String productId;
  final String productName;
  final double quantity;
  final double rate;
  final double amount;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
    };
  }

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: json['productId'],
      productName: json['productName'],
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      rate: (json['rate'] ?? 0.0).toDouble(),
      amount: (json['amount'] ?? 0.0).toDouble(),
    );
  }
}

class SaleModel {
  final String id;
  final String? farmerId;
  final String? farmerName;
  final List<SaleItemModel> items;
  final double subtotal;
  final double discount;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final DateTime saleDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  SaleModel({
    required this.id,
    this.farmerId,
    this.farmerName,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    required this.totalAmount,
    required this.paymentMethod,
    required this.saleDate,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.toString(),
      'saleDate': saleDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      items: (json['items'] as List)
          .map((item) => SaleItemModel.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      saleDate: DateTime.parse(json['saleDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? false,
    );
  }

  static PaymentMethod _parsePaymentMethod(String method) {
    if (method.contains('cash')) return PaymentMethod.cash;
    if (method.contains('upi')) return PaymentMethod.upi;
    if (method.contains('card')) return PaymentMethod.card;
    if (method.contains('cheque')) return PaymentMethod.cheque;
    return PaymentMethod.credit;
  }

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.credit:
        return 'Credit';
    }
  }

  SaleModel copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    List<SaleItemModel>? items,
    double? subtotal,
    double? discount,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    DateTime? saleDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return SaleModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      saleDate: saleDate ?? this.saleDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  static String generateId() {
    return 'SAL-${DateTime.now().millisecondsSinceEpoch}-${const Uuid().v4().substring(0, 8)}';
  }
}
