import 'package:hive/hive.dart';

part 'farmer_advance_model.g.dart';

@HiveType(typeId: 14)
class FarmerAdvanceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String farmerId;

  @HiveField(2)
  String farmerName;

  @HiveField(3)
  double amount;

  @HiveField(4)
  double interestRate;

  @HiveField(5)
  String purpose;

  @HiveField(6)
  DateTime issueDate;

  @HiveField(7)
  DateTime? dueDate;

  @HiveField(8)
  AdvanceStatus status;

  @HiveField(9)
  double paidAmount;

  @HiveField(10)
  double remainingAmount;

  @HiveField(11)
  int installments;

  @HiveField(12)
  double installmentAmount;

  @HiveField(13)
  PaymentMode paymentMode;

  @HiveField(14)
  String? notes;

  @HiveField(15)
  String? guarantorName;

  @HiveField(16)
  String? guarantorPhone;

  @HiveField(17)
  DateTime createdAt;

  @HiveField(18)
  DateTime updatedAt;

  @HiveField(19)
  String createdBy;

  FarmerAdvanceModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.amount,
    this.interestRate = 0.0,
    required this.purpose,
    required this.issueDate,
    this.dueDate,
    this.status = AdvanceStatus.active,
    this.paidAmount = 0.0,
    required this.remainingAmount,
    this.installments = 1,
    required this.installmentAmount,
    required this.paymentMode,
    this.notes,
    this.guarantorName,
    this.guarantorPhone,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  double get totalAmount => amount + (amount * interestRate / 100);
  
  double get interestAmount => amount * interestRate / 100;
  
  bool get isFullyPaid => remainingAmount <= 0;
  
  double get paidPercentage => (paidAmount / totalAmount * 100).clamp(0, 100);
}

@HiveType(typeId: 15)
enum AdvanceStatus {
  @HiveField(0)
  active,
  
  @HiveField(1)
  completed,
  
  @HiveField(2)
  overdue,
  
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 16)
enum PaymentMode {
  @HiveField(0)
  cash,
  
  @HiveField(1)
  cheque,
  
  @HiveField(2)
  bankTransfer,
  
  @HiveField(3)
  upi,
  
  @HiveField(4)
  deductFromMilk,
}

@HiveType(typeId: 17)
class AdvancePaymentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String advanceId;

  @HiveField(2)
  String farmerId;

  @HiveField(3)
  double amount;

  @HiveField(4)
  DateTime paymentDate;

  @HiveField(5)
  PaymentMode paymentMode;

  @HiveField(6)
  String? referenceNumber;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  String createdBy;

  AdvancePaymentModel({
    required this.id,
    required this.advanceId,
    required this.farmerId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    this.referenceNumber,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });
}
