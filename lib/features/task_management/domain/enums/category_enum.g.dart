// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryEnumAdapter extends TypeAdapter<CategoryEnum> {
  @override
  final int typeId = 2;

  @override
  CategoryEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CategoryEnum.work;
      case 1:
        return CategoryEnum.personal;
      case 2:
        return CategoryEnum.study;
      case 3:
        return CategoryEnum.home;
      case 4:
        return CategoryEnum.health;
      case 5:
        return CategoryEnum.finance;
      case 6:
        return CategoryEnum.other;
      default:
        return CategoryEnum.work;
    }
  }

  @override
  void write(BinaryWriter writer, CategoryEnum obj) {
    switch (obj) {
      case CategoryEnum.work:
        writer.writeByte(0);
        break;
      case CategoryEnum.personal:
        writer.writeByte(1);
        break;
      case CategoryEnum.study:
        writer.writeByte(2);
        break;
      case CategoryEnum.home:
        writer.writeByte(3);
        break;
      case CategoryEnum.health:
        writer.writeByte(4);
        break;
      case CategoryEnum.finance:
        writer.writeByte(5);
        break;
      case CategoryEnum.other:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
