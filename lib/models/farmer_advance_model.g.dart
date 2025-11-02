// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_advance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FarmerAdvanceModelAdapter extends TypeAdapter<FarmerAdvanceModel> {
  @override
  final int typeId = 14;

  @override
  FarmerAdvanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FarmerAdvanceModel(
      id: fields[0] as String,
      farmerId: fields[1] as String,
      farmerName: fields[2] as String,
      amount: fields[3] as double,
      interestRate: fields[4] as double,
      purpose: fields[5] as String,
      issueDate: fields[6] as DateTime,
      dueDate: fields[7] as DateTime?,
      status: fields[8] as AdvanceStatus,
      paidAmount: fields[9] as double,
      remainingAmount: fields[10] as double,
      installments: fields[11] as int,
      installmentAmount: fields[12] as double,
      paymentMode: fields[13] as PaymentMode,
      notes: fields[14] as String?,
      guarantorName: fields[15] as String?,
      guarantorPhone: fields[16] as String?,
      createdAt: fields[17] as DateTime,
      updatedAt: fields[18] as DateTime,
      createdBy: fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FarmerAdvanceModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.farmerId)
      ..writeByte(2)
      ..write(obj.farmerName)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.interestRate)
      ..writeByte(5)
      ..write(obj.purpose)
      ..writeByte(6)
      ..write(obj.issueDate)
      ..writeByte(7)
      ..write(obj.dueDate)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.paidAmount)
      ..writeByte(10)
      ..write(obj.remainingAmount)
      ..writeByte(11)
      ..write(obj.installments)
      ..writeByte(12)
      ..write(obj.installmentAmount)
      ..writeByte(13)
      ..write(obj.paymentMode)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.guarantorName)
      ..writeByte(16)
      ..write(obj.guarantorPhone)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt)
      ..writeByte(19)
      ..write(obj.createdBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmerAdvanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdvancePaymentModelAdapter extends TypeAdapter<AdvancePaymentModel> {
  @override
  final int typeId = 17;

  @override
  AdvancePaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdvancePaymentModel(
      id: fields[0] as String,
      advanceId: fields[1] as String,
      farmerId: fields[2] as String,
      amount: fields[3] as double,
      paymentDate: fields[4] as DateTime,
      paymentMode: fields[5] as PaymentMode,
      referenceNumber: fields[6] as String?,
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      createdBy: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AdvancePaymentModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.advanceId)
      ..writeByte(2)
      ..write(obj.farmerId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.paymentDate)
      ..writeByte(5)
      ..write(obj.paymentMode)
      ..writeByte(6)
      ..write(obj.referenceNumber)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.createdBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvancePaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdvanceStatusAdapter extends TypeAdapter<AdvanceStatus> {
  @override
  final int typeId = 15;

  @override
  AdvanceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdvanceStatus.active;
      case 1:
        return AdvanceStatus.completed;
      case 2:
        return AdvanceStatus.overdue;
      case 3:
        return AdvanceStatus.cancelled;
      default:
        return AdvanceStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, AdvanceStatus obj) {
    switch (obj) {
      case AdvanceStatus.active:
        writer.writeByte(0);
        break;
      case AdvanceStatus.completed:
        writer.writeByte(1);
        break;
      case AdvanceStatus.overdue:
        writer.writeByte(2);
        break;
      case AdvanceStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvanceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentModeAdapter extends TypeAdapter<PaymentMode> {
  @override
  final int typeId = 16;

  @override
  PaymentMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMode.cash;
      case 1:
        return PaymentMode.cheque;
      case 2:
        return PaymentMode.bankTransfer;
      case 3:
        return PaymentMode.upi;
      case 4:
        return PaymentMode.deductFromMilk;
      default:
        return PaymentMode.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMode obj) {
    switch (obj) {
      case PaymentMode.cash:
        writer.writeByte(0);
        break;
      case PaymentMode.cheque:
        writer.writeByte(1);
        break;
      case PaymentMode.bankTransfer:
        writer.writeByte(2);
        break;
      case PaymentMode.upi:
        writer.writeByte(3);
        break;
      case PaymentMode.deductFromMilk:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
