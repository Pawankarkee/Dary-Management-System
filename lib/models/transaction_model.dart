enum TransactionType {
  milkPayment,
  advance,
  credit,
  productPurchase,
  settlement,
}

class TransactionModel {
  final String id;
  final String farmerId;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;
  final double runningBalance;
  final bool isSynced;
  final DateTime createdAt;
  final String? referenceId; // For linking to milk collection, sale, etc.

  TransactionModel({
    required this.id,
    required this.farmerId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.runningBalance,
    this.isSynced = false,
    required this.createdAt,
    this.referenceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'type': type.toString(),
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'runningBalance': runningBalance,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'referenceId': referenceId,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      farmerId: json['farmerId'],
      type: _parseTransactionType(json['type']),
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      runningBalance: (json['runningBalance'] ?? 0.0).toDouble(),
      isSynced: json['isSynced'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      referenceId: json['referenceId'],
    );
  }

  static TransactionType _parseTransactionType(String type) {
    if (type.contains('milkPayment')) return TransactionType.milkPayment;
    if (type.contains('advance')) return TransactionType.advance;
    if (type.contains('credit')) return TransactionType.credit;
    if (type.contains('productPurchase')) return TransactionType.productPurchase;
    return TransactionType.settlement;
  }

  String get typeDisplay {
    switch (type) {
      case TransactionType.milkPayment:
        return 'Milk Payment';
      case TransactionType.advance:
        return 'Advance';
      case TransactionType.credit:
        return 'Credit';
      case TransactionType.productPurchase:
        return 'Product Purchase';
      case TransactionType.settlement:
        return 'Settlement';
    }
  }

  bool get isCredit => type == TransactionType.milkPayment || type == TransactionType.advance;
  bool get isDebit => type == TransactionType.credit || 
                      type == TransactionType.productPurchase || 
                      type == TransactionType.settlement;
}
