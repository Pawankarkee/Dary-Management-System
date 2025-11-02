// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_center_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectionCenterModelAdapter extends TypeAdapter<CollectionCenterModel> {
  @override
  final int typeId = 18;

  @override
  CollectionCenterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectionCenterModel(
      id: fields[0] as String,
      name: fields[1] as String,
      code: fields[2] as String,
      address: fields[3] as String,
      contactPerson: fields[4] as String,
      phone: fields[5] as String,
      capacity: fields[6] as double,
      status: fields[7] as CenterStatus,
      currentStock: fields[8] as double,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CollectionCenterModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.contactPerson)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.capacity)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.currentStock)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionCenterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MilkReceptionModelAdapter extends TypeAdapter<MilkReceptionModel> {
  @override
  final int typeId = 20;

  @override
  MilkReceptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MilkReceptionModel(
      id: fields[0] as String,
      centerId: fields[1] as String,
      centerName: fields[2] as String,
      farmerId: fields[3] as String,
      farmerName: fields[4] as String,
      quantity: fields[5] as double,
      fat: fields[6] as double,
      snf: fields[7] as double,
      temperature: fields[8] as double,
      qualityPassed: fields[9] as bool,
      receptionTime: fields[10] as DateTime,
      receivedBy: fields[11] as String,
      remarks: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MilkReceptionModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.centerId)
      ..writeByte(2)
      ..write(obj.centerName)
      ..writeByte(3)
      ..write(obj.farmerId)
      ..writeByte(4)
      ..write(obj.farmerName)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.fat)
      ..writeByte(7)
      ..write(obj.snf)
      ..writeByte(8)
      ..write(obj.temperature)
      ..writeByte(9)
      ..write(obj.qualityPassed)
      ..writeByte(10)
      ..write(obj.receptionTime)
      ..writeByte(11)
      ..write(obj.receivedBy)
      ..writeByte(12)
      ..write(obj.remarks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilkReceptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CenterStatusAdapter extends TypeAdapter<CenterStatus> {
  @override
  final int typeId = 19;

  @override
  CenterStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CenterStatus.active;
      case 1:
        return CenterStatus.inactive;
      case 2:
        return CenterStatus.maintenance;
      default:
        return CenterStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, CenterStatus obj) {
    switch (obj) {
      case CenterStatus.active:
        writer.writeByte(0);
        break;
      case CenterStatus.inactive:
        writer.writeByte(1);
        break;
      case CenterStatus.maintenance:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CenterStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
