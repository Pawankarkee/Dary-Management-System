// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_test_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QualityTestModelAdapter extends TypeAdapter<QualityTestModel> {
  @override
  final int typeId = 21;

  @override
  QualityTestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QualityTestModel(
      id: fields[0] as String,
      sampleId: fields[1] as String,
      farmerId: fields[2] as String,
      farmerName: fields[3] as String,
      centerId: fields[4] as String?,
      centerName: fields[5] as String?,
      fatPercentage: fields[6] as double,
      snfPercentage: fields[7] as double,
      clr: fields[8] as double,
      lactometerReading: fields[9] as double,
      temperature: fields[10] as double,
      waterPercentage: fields[11] as double?,
      result: fields[12] as TestResult,
      adulterations: (fields[13] as List).cast<String>(),
      milkQuantity: fields[14] as double,
      testDate: fields[15] as DateTime,
      testedBy: fields[16] as String,
      remarks: fields[17] as String?,
      certificateGenerated: fields[18] as bool,
      createdAt: fields[19] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QualityTestModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sampleId)
      ..writeByte(2)
      ..write(obj.farmerId)
      ..writeByte(3)
      ..write(obj.farmerName)
      ..writeByte(4)
      ..write(obj.centerId)
      ..writeByte(5)
      ..write(obj.centerName)
      ..writeByte(6)
      ..write(obj.fatPercentage)
      ..writeByte(7)
      ..write(obj.snfPercentage)
      ..writeByte(8)
      ..write(obj.clr)
      ..writeByte(9)
      ..write(obj.lactometerReading)
      ..writeByte(10)
      ..write(obj.temperature)
      ..writeByte(11)
      ..write(obj.waterPercentage)
      ..writeByte(12)
      ..write(obj.result)
      ..writeByte(13)
      ..write(obj.adulterations)
      ..writeByte(14)
      ..write(obj.milkQuantity)
      ..writeByte(15)
      ..write(obj.testDate)
      ..writeByte(16)
      ..write(obj.testedBy)
      ..writeByte(17)
      ..write(obj.remarks)
      ..writeByte(18)
      ..write(obj.certificateGenerated)
      ..writeByte(19)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityTestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QualityStandardModelAdapter extends TypeAdapter<QualityStandardModel> {
  @override
  final int typeId = 23;

  @override
  QualityStandardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QualityStandardModel(
      id: fields[0] as String,
      name: fields[1] as String,
      minFat: fields[2] as double,
      maxFat: fields[3] as double,
      minSnf: fields[4] as double,
      maxSnf: fields[5] as double,
      minClr: fields[6] as double,
      maxClr: fields[7] as double,
      minTemperature: fields[8] as double,
      maxTemperature: fields[9] as double,
      maxWaterContent: fields[10] as double,
      isActive: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QualityStandardModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.minFat)
      ..writeByte(3)
      ..write(obj.maxFat)
      ..writeByte(4)
      ..write(obj.minSnf)
      ..writeByte(5)
      ..write(obj.maxSnf)
      ..writeByte(6)
      ..write(obj.minClr)
      ..writeByte(7)
      ..write(obj.maxClr)
      ..writeByte(8)
      ..write(obj.minTemperature)
      ..writeByte(9)
      ..write(obj.maxTemperature)
      ..writeByte(10)
      ..write(obj.maxWaterContent)
      ..writeByte(11)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityStandardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TestResultAdapter extends TypeAdapter<TestResult> {
  @override
  final int typeId = 22;

  @override
  TestResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TestResult.passed;
      case 1:
        return TestResult.failed;
      case 2:
        return TestResult.rejected;
      case 3:
        return TestResult.pending;
      default:
        return TestResult.passed;
    }
  }

  @override
  void write(BinaryWriter writer, TestResult obj) {
    switch (obj) {
      case TestResult.passed:
        writer.writeByte(0);
        break;
      case TestResult.failed:
        writer.writeByte(1);
        break;
      case TestResult.rejected:
        writer.writeByte(2);
        break;
      case TestResult.pending:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
