// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StaffModelAdapter extends TypeAdapter<StaffModel> {
  @override
  final int typeId = 17;

  @override
  StaffModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StaffModel(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      email: fields[3] as String?,
      address: fields[4] as String?,
      role: fields[5] as StaffRole,
      department: fields[6] as String?,
      salary: fields[7] as double,
      joiningDate: fields[8] as DateTime,
      relievingDate: fields[9] as DateTime?,
      isActive: fields[10] as bool,
      aadharNumber: fields[11] as String?,
      panNumber: fields[12] as String?,
      bankAccountNumber: fields[13] as String?,
      ifscCode: fields[14] as String?,
      emergencyContact: fields[15] as String?,
      profileImagePath: fields[16] as String?,
      permissions: (fields[17] as List?)?.cast<String>(),
      notes: fields[18] as String?,
      createdAt: fields[19] as DateTime,
      updatedAt: fields[20] as DateTime,
      isSynced: fields[21] as bool,
      username: fields[22] as String?,
      passwordHash: fields[23] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StaffModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.department)
      ..writeByte(7)
      ..write(obj.salary)
      ..writeByte(8)
      ..write(obj.joiningDate)
      ..writeByte(9)
      ..write(obj.relievingDate)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.aadharNumber)
      ..writeByte(12)
      ..write(obj.panNumber)
      ..writeByte(13)
      ..write(obj.bankAccountNumber)
      ..writeByte(14)
      ..write(obj.ifscCode)
      ..writeByte(15)
      ..write(obj.emergencyContact)
      ..writeByte(16)
      ..write(obj.profileImagePath)
      ..writeByte(17)
      ..write(obj.permissions)
      ..writeByte(18)
      ..write(obj.notes)
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt)
      ..writeByte(21)
      ..write(obj.isSynced)
      ..writeByte(22)
      ..write(obj.username)
      ..writeByte(23)
      ..write(obj.passwordHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StaffRoleAdapter extends TypeAdapter<StaffRole> {
  @override
  final int typeId = 18;

  @override
  StaffRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StaffRole.admin;
      case 1:
        return StaffRole.manager;
      case 2:
        return StaffRole.supervisor;
      case 3:
        return StaffRole.collectionAgent;
      case 4:
        return StaffRole.salesPerson;
      case 5:
        return StaffRole.accountant;
      case 6:
        return StaffRole.driver;
      case 7:
        return StaffRole.staff;
      default:
        return StaffRole.admin;
    }
  }

  @override
  void write(BinaryWriter writer, StaffRole obj) {
    switch (obj) {
      case StaffRole.admin:
        writer.writeByte(0);
        break;
      case StaffRole.manager:
        writer.writeByte(1);
        break;
      case StaffRole.supervisor:
        writer.writeByte(2);
        break;
      case StaffRole.collectionAgent:
        writer.writeByte(3);
        break;
      case StaffRole.salesPerson:
        writer.writeByte(4);
        break;
      case StaffRole.accountant:
        writer.writeByte(5);
        break;
      case StaffRole.driver:
        writer.writeByte(6);
        break;
      case StaffRole.staff:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
