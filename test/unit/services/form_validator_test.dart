import 'package:flutter_test/flutter_test.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/services/form_validator.dart';
import '../../helpers/test_constants.dart';

void main() {
  group('FormValidator', () {
    group('validateRequiredString', () {
      test('should return null for valid non-empty string', () {
        // Arrange
        const value = TestConstants.defaultTaskTitle;
        const errorMessage = TestConstants.titleRequiredMessage;

        // Act
        final result =
            FormValidator.validateRequiredString(value, errorMessage);

        // Assert
        expect(result, isNull);
      });

      test('should return error message for empty string', () {
        // Arrange
        const value = '';
        const errorMessage = TestConstants.titleRequiredMessage;

        // Act
        final result =
            FormValidator.validateRequiredString(value, errorMessage);

        // Assert
        expect(result, equals(errorMessage));
      });

      test('should return error message for whitespace-only string', () {
        // Arrange
        const value = '   ';
        const errorMessage = TestConstants.titleRequiredMessage;

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
        const errorMessage = TestConstants.titleRequiredMessage;

        // Act
        final result =
            FormValidator.validateRequiredString(value, errorMessage);

        // Assert
        expect(result, equals(errorMessage));
      });

      test('should return null for string with leading/trailing whitespace',
          () {
        // Arrange
        const value = '  ${TestConstants.defaultTaskTitle}  ';
        const errorMessage = TestConstants.titleRequiredMessage;

        // Act
        final result =
            FormValidator.validateRequiredString(value, errorMessage);

        // Assert
        expect(result, isNull);
      });

      test('should return custom error message when provided', () {
        // Arrange
        const value = '';
        const customErrorMessage = TestConstants.requiredFieldErrorMessage;

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

      test('should return null for non-null category (even if invalid type)',
          () {
        // Arrange
        const category = CategoryEnum.personal;

        // Act
        final result = FormValidator.validateCategory(category);

        // Assert
        expect(result, isNull);
      });
    });

    group('validateDueDate', () {
      test('should return null for valid date', () {
        // Arrange
        final dueDate = TestConstants.defaultDueDate;

        // Act
        final result = FormValidator.validateDueDate(dueDate);

        // Assert
        expect(result, isNull);
      });
    });

    group('Integration Tests', () {
      test('should validate complete task form successfully', () {
        // Arrange
        const title = TestConstants.defaultTaskTitle;
        const description = TestConstants.defaultTaskDescription;
        const category = CategoryEnum.work;
        final dueDate = TestConstants.defaultDueDate;

        // Act
        final titleError = FormValidator.validateRequiredString(
            title, TestConstants.titleRequiredMessage);
        final descriptionError = FormValidator.validateRequiredString(
            description, TestConstants.descriptionRequiredMessage);
        final categoryError = FormValidator.validateCategory(category);
        final dueDateError = FormValidator.validateDueDate(dueDate);

        // Assert
        expect(titleError, isNull);
        expect(descriptionError, isNull);
        expect(categoryError, isNull);
        expect(dueDateError, isNull);
      });

      test('should return multiple validation errors for invalid form', () {
        // Arrange
        const title = '';
        const description = '';
        const category = CategoryEnum.work;
        final dueDate = TestConstants.pastDueDate;

        // Act
        final titleError = FormValidator.validateRequiredString(
            title, TestConstants.titleRequiredMessage);
        final descriptionError = FormValidator.validateRequiredString(
            description, TestConstants.descriptionRequiredMessage);
        final categoryError = FormValidator.validateCategory(category);
        final dueDateError = FormValidator.validateDueDate(dueDate);

        // Assert
        expect(titleError, equals(TestConstants.titleRequiredMessage));
        expect(
            descriptionError, equals(TestConstants.descriptionRequiredMessage));
        expect(categoryError, isNull); // Category is valid
        expect(dueDateError, isNull);
      });
    });
  });
}
