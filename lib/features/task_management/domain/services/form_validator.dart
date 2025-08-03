import 'package:task_buddy/shared/localization/strings.dart';

/// Simple form validation functions
class FormValidator {
  /// Validates that a string is not null or empty
  static String? validateRequiredString(String value, String errorMessage) {
    if (value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  /// Validates that a category is selected
  static String? validateCategory(dynamic category) {
    if (category == null) {
      return AppStrings.categoryRequired;
    }
    return null;
  }

  /// Validates that a due date is selected and not in the past
  static String? validateDueDate(DateTime? dueDate) {
    if (dueDate == null) {
      return AppStrings.dueDateRequired;
    }
    return null;
  }
}
