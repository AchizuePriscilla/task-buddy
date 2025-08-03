// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_analytics_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAnalyticsModelAdapter extends TypeAdapter<UserAnalyticsModel> {
  @override
  final int typeId = 3;

  @override
  UserAnalyticsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAnalyticsModel(
      id: fields[0] as String,
      category: fields[1] as CategoryEnum,
      totalTasksCreated: fields[2] as int,
      totalTasksCompleted: fields[3] as int,
      tasksCompletedOnTime: fields[4] as int,
      tasksCompletedLate: fields[5] as int,
      lastUpdated: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserAnalyticsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.totalTasksCreated)
      ..writeByte(3)
      ..write(obj.totalTasksCompleted)
      ..writeByte(4)
      ..write(obj.tasksCompletedOnTime)
      ..writeByte(5)
      ..write(obj.tasksCompletedLate)
      ..writeByte(6)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAnalyticsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
