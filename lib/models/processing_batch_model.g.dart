// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processing_batch_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProcessingBatchModelAdapter extends TypeAdapter<ProcessingBatchModel> {
  @override
  final int typeId = 19;

  @override
  ProcessingBatchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProcessingBatchModel(
      id: fields[0] as String,
      batchNumber: fields[1] as String,
      processingType: fields[2] as ProcessingType,
      status: fields[3] as BatchStatus,
      startTime: fields[4] as DateTime,
      endTime: fields[5] as DateTime?,
      rawMilkQuantity: fields[6] as double,
      rawMilkSource: fields[7] as String?,
      outputs: (fields[8] as List).cast<ProcessingOutput>(),
      qualityChecks: (fields[9] as List).cast<QualityCheck>(),
      temperature: fields[10] as double?,
      duration: fields[11] as int?,
      operatorId: fields[12] as String?,
      operatorName: fields[13] as String?,
      energyConsumed: fields[14] as double?,
      waterUsed: fields[15] as double?,
      additionalMaterials: (fields[16] as List).cast<AdditionalMaterial>(),
      equipmentUsed: fields[17] as String?,
      notes: fields[18] as String?,
      productionCost: fields[19] as double?,
      yieldPercentage: fields[20] as double?,
      createdAt: fields[21] as DateTime,
      updatedAt: fields[22] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProcessingBatchModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchNumber)
      ..writeByte(2)
      ..write(obj.processingType)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.rawMilkQuantity)
      ..writeByte(7)
      ..write(obj.rawMilkSource)
      ..writeByte(8)
      ..write(obj.outputs)
      ..writeByte(9)
      ..write(obj.qualityChecks)
      ..writeByte(10)
      ..write(obj.temperature)
      ..writeByte(11)
      ..write(obj.duration)
      ..writeByte(12)
      ..write(obj.operatorId)
      ..writeByte(13)
      ..write(obj.operatorName)
      ..writeByte(14)
      ..write(obj.energyConsumed)
      ..writeByte(15)
      ..write(obj.waterUsed)
      ..writeByte(16)
      ..write(obj.additionalMaterials)
      ..writeByte(17)
      ..write(obj.equipmentUsed)
      ..writeByte(18)
      ..write(obj.notes)
      ..writeByte(19)
      ..write(obj.productionCost)
      ..writeByte(20)
      ..write(obj.yieldPercentage)
      ..writeByte(21)
      ..write(obj.createdAt)
      ..writeByte(22)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessingBatchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProcessingOutputAdapter extends TypeAdapter<ProcessingOutput> {
  @override
  final int typeId = 22;

  @override
  ProcessingOutput read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProcessingOutput(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as double,
      unit: fields[3] as String,
      qualityScore: fields[4] as double?,
      remarks: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProcessingOutput obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.qualityScore)
      ..writeByte(5)
      ..write(obj.remarks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessingOutputAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QualityCheckAdapter extends TypeAdapter<QualityCheck> {
  @override
  final int typeId = 23;

  @override
  QualityCheck read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QualityCheck(
      parameter: fields[0] as String,
      value: fields[1] as String,
      expectedRange: fields[2] as String?,
      isPassed: fields[3] as bool,
      checkedAt: fields[4] as DateTime,
      checkedBy: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QualityCheck obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.parameter)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.expectedRange)
      ..writeByte(3)
      ..write(obj.isPassed)
      ..writeByte(4)
      ..write(obj.checkedAt)
      ..writeByte(5)
      ..write(obj.checkedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityCheckAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdditionalMaterialAdapter extends TypeAdapter<AdditionalMaterial> {
  @override
  final int typeId = 24;

  @override
  AdditionalMaterial read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdditionalMaterial(
      materialName: fields[0] as String,
      quantity: fields[1] as double,
      unit: fields[2] as String,
      cost: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, AdditionalMaterial obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.materialName)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.cost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalMaterialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProcessingTypeAdapter extends TypeAdapter<ProcessingType> {
  @override
  final int typeId = 20;

  @override
  ProcessingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProcessingType.pasteurization;
      case 1:
        return ProcessingType.homogenization;
      case 2:
        return ProcessingType.creamSeparation;
      case 3:
        return ProcessingType.butterMaking;
      case 4:
        return ProcessingType.cheeseProduction;
      case 5:
        return ProcessingType.yogurtProduction;
      case 6:
        return ProcessingType.paneerMaking;
      case 7:
        return ProcessingType.gheeProduction;
      case 8:
        return ProcessingType.milkPowder;
      case 9:
        return ProcessingType.iceCream;
      case 10:
        return ProcessingType.flavoredMilk;
      case 11:
        return ProcessingType.condensedMilk;
      default:
        return ProcessingType.pasteurization;
    }
  }

  @override
  void write(BinaryWriter writer, ProcessingType obj) {
    switch (obj) {
      case ProcessingType.pasteurization:
        writer.writeByte(0);
        break;
      case ProcessingType.homogenization:
        writer.writeByte(1);
        break;
      case ProcessingType.creamSeparation:
        writer.writeByte(2);
        break;
      case ProcessingType.butterMaking:
        writer.writeByte(3);
        break;
      case ProcessingType.cheeseProduction:
        writer.writeByte(4);
        break;
      case ProcessingType.yogurtProduction:
        writer.writeByte(5);
        break;
      case ProcessingType.paneerMaking:
        writer.writeByte(6);
        break;
      case ProcessingType.gheeProduction:
        writer.writeByte(7);
        break;
      case ProcessingType.milkPowder:
        writer.writeByte(8);
        break;
      case ProcessingType.iceCream:
        writer.writeByte(9);
        break;
      case ProcessingType.flavoredMilk:
        writer.writeByte(10);
        break;
      case ProcessingType.condensedMilk:
        writer.writeByte(11);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BatchStatusAdapter extends TypeAdapter<BatchStatus> {
  @override
  final int typeId = 21;

  @override
  BatchStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BatchStatus.planned;
      case 1:
        return BatchStatus.inProgress;
      case 2:
        return BatchStatus.qualityCheck;
      case 3:
        return BatchStatus.completed;
      case 4:
        return BatchStatus.rejected;
      case 5:
        return BatchStatus.cancelled;
      default:
        return BatchStatus.planned;
    }
  }

  @override
  void write(BinaryWriter writer, BatchStatus obj) {
    switch (obj) {
      case BatchStatus.planned:
        writer.writeByte(0);
        break;
      case BatchStatus.inProgress:
        writer.writeByte(1);
        break;
      case BatchStatus.qualityCheck:
        writer.writeByte(2);
        break;
      case BatchStatus.completed:
        writer.writeByte(3);
        break;
      case BatchStatus.rejected:
        writer.writeByte(4);
        break;
      case BatchStatus.cancelled:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
