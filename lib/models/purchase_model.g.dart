// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseModelAdapter extends TypeAdapter<PurchaseModel> {
  @override
  final int typeId = 9;

  @override
  PurchaseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseModel(
      id: fields[0] as String,
      supplierId: fields[1] as String,
      supplierName: fields[2] as String,
      invoiceNumber: fields[3] as String,
      purchaseDate: fields[4] as DateTime,
      dueDate: fields[5] as DateTime,
      items: (fields[6] as List).cast<PurchaseItemModel>(),
      subtotal: fields[7] as double,
      taxAmount: fields[8] as double,
      otherCharges: fields[9] as double,
      discount: fields[10] as double,
      totalAmount: fields[11] as double,
      paidAmount: fields[12] as double,
      balanceAmount: fields[13] as double,
      status: fields[14] as PurchaseStatus,
      paymentStatus: fields[15] as PaymentStatus,
      notes: fields[16] as String?,
      createdAt: fields[17] as DateTime,
      updatedAt: fields[18] as DateTime,
      isSynced: fields[19] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.supplierId)
      ..writeByte(2)
      ..write(obj.supplierName)
      ..writeByte(3)
      ..write(obj.invoiceNumber)
      ..writeByte(4)
      ..write(obj.purchaseDate)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.items)
      ..writeByte(7)
      ..write(obj.subtotal)
      ..writeByte(8)
      ..write(obj.taxAmount)
      ..writeByte(9)
      ..write(obj.otherCharges)
      ..writeByte(10)
      ..write(obj.discount)
      ..writeByte(11)
      ..write(obj.totalAmount)
      ..writeByte(12)
      ..write(obj.paidAmount)
      ..writeByte(13)
      ..write(obj.balanceAmount)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.paymentStatus)
      ..writeByte(16)
      ..write(obj.notes)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt)
      ..writeByte(19)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PurchaseItemModelAdapter extends TypeAdapter<PurchaseItemModel> {
  @override
  final int typeId = 10;

  @override
  PurchaseItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseItemModel(
      itemName: fields[0] as String,
      description: fields[1] as String,
      quantity: fields[2] as double,
      unit: fields[3] as String,
      rate: fields[4] as double,
      amount: fields[5] as double,
      taxRate: fields[6] as double?,
      taxAmount: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseItemModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.itemName)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.rate)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.taxRate)
      ..writeByte(7)
      ..write(obj.taxAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PurchaseStatusAdapter extends TypeAdapter<PurchaseStatus> {
  @override
  final int typeId = 11;

  @override
  PurchaseStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PurchaseStatus.pending;
      case 1:
        return PurchaseStatus.received;
      case 2:
        return PurchaseStatus.cancelled;
      default:
        return PurchaseStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, PurchaseStatus obj) {
    switch (obj) {
      case PurchaseStatus.pending:
        writer.writeByte(0);
        break;
      case PurchaseStatus.received:
        writer.writeByte(1);
        break;
      case PurchaseStatus.cancelled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentStatusAdapter extends TypeAdapter<PaymentStatus> {
  @override
  final int typeId = 12;

  @override
  PaymentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentStatus.unpaid;
      case 1:
        return PaymentStatus.partial;
      case 2:
        return PaymentStatus.paid;
      default:
        return PaymentStatus.unpaid;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentStatus obj) {
    switch (obj) {
      case PaymentStatus.unpaid:
        writer.writeByte(0);
        break;
      case PaymentStatus.partial:
        writer.writeByte(1);
        break;
      case PaymentStatus.paid:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
