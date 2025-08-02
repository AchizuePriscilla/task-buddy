import '../../../../shared/localization/strings.dart';

enum CategoryEnum {
  work,
  personal,
  study,
  home,
  health,
  finance,
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
