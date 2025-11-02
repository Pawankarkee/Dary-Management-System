enum MilkType {
  cow,
  buffalo,
  both,
}

class FarmerModel {
  final String id;
  final String name;
  final String? village;
  final String? address;
  final String? phone;
  final MilkType milkType;
  final String? photoPath;
  final double runningBalance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  FarmerModel({
  required this.id,
  required this.name,
  this.village,
    this.address,
    this.phone,
    required this.milkType,
    this.photoPath,
    this.runningBalance = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
  'village': village,
      'address': address,
      'phone': phone,
      'milkType': milkType.toString(),
      'photoPath': photoPath,
      'runningBalance': runningBalance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id'],
      name: json['name'],
  village: (json['village'] as String?)?.trim().isEmpty == true ? null : json['village'],
      address: json['address'],
      phone: json['phone'],
      milkType: _parseMilkType(json['milkType']),
      photoPath: json['photoPath'],
      runningBalance: (json['runningBalance'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  static MilkType _parseMilkType(String type) {
    if (type.contains('cow')) return MilkType.cow;
    if (type.contains('buffalo')) return MilkType.buffalo;
    return MilkType.both;
  }

  FarmerModel copyWith({
    String? id,
    String? name,
  String? village,
    String? address,
    String? phone,
    MilkType? milkType,
    String? photoPath,
    double? runningBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return FarmerModel(
      id: id ?? this.id,
      name: name ?? this.name,
  village: village ?? this.village,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      milkType: milkType ?? this.milkType,
      photoPath: photoPath ?? this.photoPath,
      runningBalance: runningBalance ?? this.runningBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String get milkTypeDisplay {
    switch (milkType) {
      case MilkType.cow:
        return 'Cow';
      case MilkType.buffalo:
        return 'Buffalo';
      case MilkType.both:
        return 'Both';
    }
  }
}
