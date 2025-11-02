enum Shift {
  morning,
  evening,
}

class MilkCollectionModel {
  final String id;
  final String farmerId;
  final DateTime date;
  final Shift shift;
  final double quantity; // in liters
  final double fat; // percentage
  final double snf; // percentage
  final double ratePerLiter;
  final double totalAmount;
  final String collectorId;
  final bool isSynced;
  final DateTime createdAt;
  final bool isRejected;
  final String? rejectionReason;

  MilkCollectionModel({
    required this.id,
    required this.farmerId,
    required this.date,
    required this.shift,
    required this.quantity,
    required this.fat,
    required this.snf,
    required this.ratePerLiter,
    required this.totalAmount,
    required this.collectorId,
    this.isSynced = false,
    required this.createdAt,
    this.isRejected = false,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'date': date.toIso8601String(),
      'shift': shift.toString(),
      'quantity': quantity,
      'fat': fat,
      'snf': snf,
      'ratePerLiter': ratePerLiter,
      'totalAmount': totalAmount,
      'collectorId': collectorId,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'isRejected': isRejected,
      'rejectionReason': rejectionReason,
    };
  }

  factory MilkCollectionModel.fromJson(Map<String, dynamic> json) {
    return MilkCollectionModel(
      id: json['id'],
      farmerId: json['farmerId'],
      date: DateTime.parse(json['date']),
      shift: json['shift'].toString().contains('morning') ? Shift.morning : Shift.evening,
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      snf: (json['snf'] ?? 0.0).toDouble(),
      ratePerLiter: (json['ratePerLiter'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      collectorId: json['collectorId'],
      isSynced: json['isSynced'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      isRejected: json['isRejected'] ?? false,
      rejectionReason: json['rejectionReason'],
    );
  }

  String get shiftDisplay => shift == Shift.morning ? 'Morning' : 'Evening';

  MilkCollectionModel copyWith({
    String? id,
    String? farmerId,
    DateTime? date,
    Shift? shift,
    double? quantity,
    double? fat,
    double? snf,
    double? ratePerLiter,
    double? totalAmount,
    String? collectorId,
    bool? isSynced,
    DateTime? createdAt,
    bool? isRejected,
    String? rejectionReason,
  }) {
    return MilkCollectionModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      date: date ?? this.date,
      shift: shift ?? this.shift,
      quantity: quantity ?? this.quantity,
      fat: fat ?? this.fat,
      snf: snf ?? this.snf,
      ratePerLiter: ratePerLiter ?? this.ratePerLiter,
      totalAmount: totalAmount ?? this.totalAmount,
      collectorId: collectorId ?? this.collectorId,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      isRejected: isRejected ?? this.isRejected,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
