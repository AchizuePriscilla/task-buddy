import 'package:flutter_test/flutter_test.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/shared/localization/strings.dart';

void main() {
  group('CategoryEnum', () {
    test('should have correct enum values', () {
      // Assert
      expect(CategoryEnum.values.length, equals(7));
      expect(CategoryEnum.values, contains(CategoryEnum.work));
      expect(CategoryEnum.values, contains(CategoryEnum.personal));
      expect(CategoryEnum.values, contains(CategoryEnum.study));
      expect(CategoryEnum.values, contains(CategoryEnum.home));
      expect(CategoryEnum.values, contains(CategoryEnum.health));
      expect(CategoryEnum.values, contains(CategoryEnum.finance));
      expect(CategoryEnum.values, contains(CategoryEnum.other));
    });

    test('should have correct display names', () {
      // Assert
      expect(CategoryEnum.work.displayName, equals(AppStrings.work));
      expect(CategoryEnum.personal.displayName, equals(AppStrings.personal));
      expect(CategoryEnum.study.displayName, equals(AppStrings.study));
      expect(CategoryEnum.home.displayName, equals(AppStrings.home));
      expect(CategoryEnum.health.displayName, equals(AppStrings.health));
      expect(CategoryEnum.finance.displayName, equals(AppStrings.finance));
      expect(CategoryEnum.other.displayName, equals(AppStrings.other));
    });

    test('should have unique display names', () {
      // Arrange
      final displayNames =
          CategoryEnum.values.map((e) => e.displayName).toSet();

      // Assert
      expect(displayNames.length, equals(CategoryEnum.values.length));
    });
  });
}
