// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 13;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      amount: fields[3] as double,
      category: fields[4] as ExpenseCategory,
      expenseDate: fields[5] as DateTime,
      paymentMethod: fields[6] as PaymentMethod,
      referenceNumber: fields[7] as String?,
      paidTo: fields[8] as String?,
      attachmentPath: fields[9] as String?,
      isRecurring: fields[10] as bool,
      recurringType: fields[11] as RecurringType?,
      notes: fields[12] as String?,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      isSynced: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.expenseDate)
      ..writeByte(6)
      ..write(obj.paymentMethod)
      ..writeByte(7)
      ..write(obj.referenceNumber)
      ..writeByte(8)
      ..write(obj.paidTo)
      ..writeByte(9)
      ..write(obj.attachmentPath)
      ..writeByte(10)
      ..write(obj.isRecurring)
      ..writeByte(11)
      ..write(obj.recurringType)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 14;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.salary;
      case 1:
        return ExpenseCategory.animalFeed;
      case 2:
        return ExpenseCategory.veterinary;
      case 3:
        return ExpenseCategory.electricity;
      case 4:
        return ExpenseCategory.water;
      case 5:
        return ExpenseCategory.transport;
      case 6:
        return ExpenseCategory.maintenance;
      case 7:
        return ExpenseCategory.packaging;
      case 8:
        return ExpenseCategory.marketing;
      case 9:
        return ExpenseCategory.rent;
      case 10:
        return ExpenseCategory.insurance;
      case 11:
        return ExpenseCategory.equipment;
      case 12:
        return ExpenseCategory.fuel;
      case 13:
        return ExpenseCategory.office;
      case 14:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.salary;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.salary:
        writer.writeByte(0);
        break;
      case ExpenseCategory.animalFeed:
        writer.writeByte(1);
        break;
      case ExpenseCategory.veterinary:
        writer.writeByte(2);
        break;
      case ExpenseCategory.electricity:
        writer.writeByte(3);
        break;
      case ExpenseCategory.water:
        writer.writeByte(4);
        break;
      case ExpenseCategory.transport:
        writer.writeByte(5);
        break;
      case ExpenseCategory.maintenance:
        writer.writeByte(6);
        break;
      case ExpenseCategory.packaging:
        writer.writeByte(7);
        break;
      case ExpenseCategory.marketing:
        writer.writeByte(8);
        break;
      case ExpenseCategory.rent:
        writer.writeByte(9);
        break;
      case ExpenseCategory.insurance:
        writer.writeByte(10);
        break;
      case ExpenseCategory.equipment:
        writer.writeByte(11);
        break;
      case ExpenseCategory.fuel:
        writer.writeByte(12);
        break;
      case ExpenseCategory.office:
        writer.writeByte(13);
        break;
      case ExpenseCategory.other:
        writer.writeByte(14);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 15;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.cash;
      case 1:
        return PaymentMethod.upi;
      case 2:
        return PaymentMethod.card;
      case 3:
        return PaymentMethod.cheque;
      case 4:
        return PaymentMethod.bankTransfer;
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.cash:
        writer.writeByte(0);
        break;
      case PaymentMethod.upi:
        writer.writeByte(1);
        break;
      case PaymentMethod.card:
        writer.writeByte(2);
        break;
      case PaymentMethod.cheque:
        writer.writeByte(3);
        break;
      case PaymentMethod.bankTransfer:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringTypeAdapter extends TypeAdapter<RecurringType> {
  @override
  final int typeId = 16;

  @override
  RecurringType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurringType.daily;
      case 1:
        return RecurringType.weekly;
      case 2:
        return RecurringType.monthly;
      case 3:
        return RecurringType.yearly;
      default:
        return RecurringType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurringType obj) {
    switch (obj) {
      case RecurringType.daily:
        writer.writeByte(0);
        break;
      case RecurringType.weekly:
        writer.writeByte(1);
        break;
      case RecurringType.monthly:
        writer.writeByte(2);
        break;
      case RecurringType.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
