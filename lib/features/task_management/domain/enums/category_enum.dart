import 'package:hive/hive.dart';
import '../../../../shared/localization/strings.dart';

part 'category_enum.g.dart';

@HiveType(typeId: 2)
enum CategoryEnum {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  study,
  @HiveField(3)
  home,
  @HiveField(4)
  health,
  @HiveField(5)
  finance,
  @HiveField(6)
  other,
}

extension CategoryExtension on CategoryEnum {
  String get displayName {
    switch (this) {
      case CategoryEnum.work:
        return AppStrings.work;
      case CategoryEnum.personal:
        return AppStrings.personal;
      case CategoryEnum.study:
        return AppStrings.study;
      case CategoryEnum.home:
        return AppStrings.home;
      case CategoryEnum.health:
        return AppStrings.health;
      case CategoryEnum.finance:
        return AppStrings.finance;
      case CategoryEnum.other:
        return AppStrings.other;
    }
  }
}
