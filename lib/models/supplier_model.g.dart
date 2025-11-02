// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplierModelAdapter extends TypeAdapter<SupplierModel> {
  @override
  final int typeId = 7;

  @override
  SupplierModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplierModel(
      id: fields[0] as String,
      name: fields[1] as String,
      contactPerson: fields[2] as String,
      phone: fields[3] as String,
      email: fields[4] as String?,
      address: fields[5] as String,
      gstin: fields[6] as String?,
      supplierType: fields[7] as SupplierType,
      openingBalance: fields[8] as double,
      currentBalance: fields[9] as double,
      isActive: fields[10] as bool,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      notes: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SupplierModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contactPerson)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.gstin)
      ..writeByte(7)
      ..write(obj.supplierType)
      ..writeByte(8)
      ..write(obj.openingBalance)
      ..writeByte(9)
      ..write(obj.currentBalance)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SupplierTypeAdapter extends TypeAdapter<SupplierType> {
  @override
  final int typeId = 8;

  @override
  SupplierType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SupplierType.general;
      case 1:
        return SupplierType.feed;
      case 2:
        return SupplierType.packaging;
      case 3:
        return SupplierType.equipment;
      case 4:
        return SupplierType.other;
      default:
        return SupplierType.general;
    }
  }

  @override
  void write(BinaryWriter writer, SupplierType obj) {
    switch (obj) {
      case SupplierType.general:
        writer.writeByte(0);
        break;
      case SupplierType.feed:
        writer.writeByte(1);
        break;
      case SupplierType.packaging:
        writer.writeByte(2);
        break;
      case SupplierType.equipment:
        writer.writeByte(3);
        break;
      case SupplierType.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
