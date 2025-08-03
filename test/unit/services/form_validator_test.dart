import 'package:flutter_test/flutter_test.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/services/form_validator.dart';
import 'package:task_buddy/shared/localization/strings.dart';

void main() {
  group('FormValidator', () {
    group('validateRequiredString', () {
      test('should return null for valid non-empty string', () {
        // Arrange
        const value = 'Valid task title';
        const errorMessage = 'Title is required';

        // Act
        final result =
            FormValidator.validateRequiredString(value, errorMessage);

        // Assert
        expect(result, isNull);
      });

      test('should return error message for empty string', () {
        // Arrange
        const value = '';
        const errorMessage = 'Title is required';

        // Act
        final result =
            FormValidator.validateRequiredString(value, errorMessage);

        // Assert
        expect(result, equals(errorMessage));
      });

      test('should return error message for whitespace-only string', () {
        // Arrange
        const value = '   ';
        const errorMessage = 'Title is required';

        // Act
        final result =
            FormValidator.validateRequiredString(value, errorMessage);

        // Assert
        expect(result, equals(errorMessage));
      });

      test('should return error message for string with only tabs and newlines',
          () {
        // Arrange
        const value = '\t\n\r';
        const errorMessage = 'Title is required';

        // Act
        final result =
            FormValidator.validateRequiredString(value, errorMessage);

        // Assert
        expect(result, equals(errorMessage));
      });

      test('should return null for string with leading/trailing whitespace',
          () {
        // Arrange
        const value = '  Valid task title  ';
        const errorMessage = 'Title is required';

        // Act
        final result =
            FormValidator.validateRequiredString(value, errorMessage);

        // Assert
        expect(result, isNull);
      });

      test('should return custom error message when provided', () {
        // Arrange
        const value = '';
        const customErrorMessage = 'Custom error message';

        // Act
        final result =
            FormValidator.validateRequiredString(value, customErrorMessage);

        // Assert
        expect(result, equals(customErrorMessage));
      });
    });

    group('validateCategory', () {
      test('should return null for valid category', () {
        // Arrange
        const category = CategoryEnum.work;

        // Act
        final result = FormValidator.validateCategory(category);

        // Assert
        expect(result, isNull);
      });

      test('should return error message for null category', () {
        // Arrange
        const category = null;

        // Act
        final result = FormValidator.validateCategory(category);

        // Assert
        expect(result, equals(AppStrings.categoryRequired));
      });

      test('should return null for all valid category enum values', () {
        // Arrange
        final categories = CategoryEnum.values;

        // Act & Assert
        for (final category in categories) {
          final result = FormValidator.validateCategory(category);
          expect(result, isNull, reason: 'Category $category should be valid');
        }
      });
    });

    group('validateDueDate', () {
      test('should return null for valid future due date', () {
        // Arrange
        final dueDate = DateTime.now().add(const Duration(days: 1));

        // Act
        final result = FormValidator.validateDueDate(dueDate);

        // Assert
        expect(result, isNull);
      });

      test('should return error message for null due date', () {
        // Arrange
        const dueDate = null;

        // Act
        final result = FormValidator.validateDueDate(dueDate);

        // Assert
        expect(result, equals(AppStrings.dueDateRequired));
      });
    });
  });
}
