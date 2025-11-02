enum ProductCategory {
  feed,
  medicine,
  salt,
  mineral,
  other,
}

enum ProductUnit {
  kg,
  packet,
  piece,
  liter,
}

class ProductModel {
  final String id;
  final String name;
  final ProductCategory category;
  final ProductUnit unit;
  final double purchasePrice;
  final double sellingPrice;
  final double currentStock;
  final double minStockLevel;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.currentStock,
    this.minStockLevel = 0,
    this.expiryDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.toString(),
      'unit': unit.toString(),
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'currentStock': currentStock,
      'minStockLevel': minStockLevel,
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      category: _parseCategory(json['category']),
      unit: _parseUnit(json['unit']),
      purchasePrice: (json['purchasePrice'] ?? 0.0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0.0).toDouble(),
      currentStock: (json['currentStock'] ?? 0.0).toDouble(),
      minStockLevel: (json['minStockLevel'] ?? 0.0).toDouble(),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static ProductCategory _parseCategory(String category) {
    if (category.contains('feed')) return ProductCategory.feed;
    if (category.contains('medicine')) return ProductCategory.medicine;
    if (category.contains('salt')) return ProductCategory.salt;
    if (category.contains('mineral')) return ProductCategory.mineral;
    return ProductCategory.other;
  }

  static ProductUnit _parseUnit(String unit) {
    if (unit.contains('kg')) return ProductUnit.kg;
    if (unit.contains('packet')) return ProductUnit.packet;
    if (unit.contains('piece')) return ProductUnit.piece;
    return ProductUnit.liter;
  }

  String get categoryDisplay {
    switch (category) {
      case ProductCategory.feed:
        return 'Feed';
      case ProductCategory.medicine:
        return 'Medicine';
      case ProductCategory.salt:
        return 'Salt';
      case ProductCategory.mineral:
        return 'Mineral';
      case ProductCategory.other:
        return 'Other';
    }
  }

  String get unitDisplay {
    switch (unit) {
      case ProductUnit.kg:
        return 'kg';
      case ProductUnit.packet:
        return 'packet';
      case ProductUnit.piece:
        return 'piece';
      case ProductUnit.liter:
        return 'liter';
    }
  }

  bool get isLowStock => currentStock <= minStockLevel;
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  ProductModel copyWith({
    String? id,
    String? name,
    ProductCategory? category,
    ProductUnit? unit,
    double? purchasePrice,
    double? sellingPrice,
    double? currentStock,
    double? minStockLevel,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
