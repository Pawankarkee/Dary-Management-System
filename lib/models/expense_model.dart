import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 13)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  double amount;

  @HiveField(4)
  ExpenseCategory category;

  @HiveField(5)
  DateTime expenseDate;

  @HiveField(6)
  PaymentMethod paymentMethod;

  @HiveField(7)
  String? referenceNumber;

  @HiveField(8)
  String? paidTo;

  @HiveField(9)
  String? attachmentPath;

  @HiveField(10)
  bool isRecurring;

  @HiveField(11)
  RecurringType? recurringType;

  @HiveField(12)
  String? notes;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  @HiveField(15)
  bool isSynced;

  ExpenseModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.amount,
    required this.category,
    required this.expenseDate,
    required this.paymentMethod,
    this.referenceNumber,
    this.paidTo,
    this.attachmentPath,
    this.isRecurring = false,
    this.recurringType,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  // Generate unique expense ID
  static String generateId() {
    const uuid = Uuid();
    return 'EXP-${DateTime.now().millisecondsSinceEpoch}-${uuid.v4().substring(0, 8)}';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category.toString(),
      'expenseDate': expenseDate.toIso8601String(),
      'paymentMethod': paymentMethod.toString(),
      'referenceNumber': referenceNumber,
      'paidTo': paidTo,
      'attachmentPath': attachmentPath,
      'isRecurring': isRecurring,
      'recurringType': recurringType?.toString(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  // Create from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      expenseDate: DateTime.parse(json['expenseDate']),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      referenceNumber: json['referenceNumber'],
      paidTo: json['paidTo'],
      attachmentPath: json['attachmentPath'],
      isRecurring: json['isRecurring'] ?? false,
      recurringType: json['recurringType'] != null
          ? RecurringType.values.firstWhere(
              (e) => e.toString() == json['recurringType'],
              orElse: () => RecurringType.monthly,
            )
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? false,
    );
  }
}

@HiveType(typeId: 14)
enum ExpenseCategory {
  @HiveField(0)
  salary,

  @HiveField(1)
  animalFeed,

  @HiveField(2)
  veterinary,

  @HiveField(3)
  electricity,

  @HiveField(4)
  water,

  @HiveField(5)
  transport,

  @HiveField(6)
  maintenance,

  @HiveField(7)
  packaging,

  @HiveField(8)
  marketing,

  @HiveField(9)
  rent,

  @HiveField(10)
  insurance,

  @HiveField(11)
  equipment,

  @HiveField(12)
  fuel,

  @HiveField(13)
  office,

  @HiveField(14)
  other,
}

@HiveType(typeId: 15)
enum PaymentMethod {
  @HiveField(0)
  cash,

  @HiveField(1)
  upi,

  @HiveField(2)
  card,

  @HiveField(3)
  cheque,

  @HiveField(4)
  bankTransfer,
}

@HiveType(typeId: 16)
enum RecurringType {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,

  @HiveField(3)
  yearly,
}
