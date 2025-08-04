/// Constants used across all tests to avoid magic values and improve maintainability
class TestConstants {
  // Test Data - Task Related
  static const String defaultTaskTitle = 'Test Task';
  static const String defaultTaskDescription = 'Test Description';
  static const String defaultTaskId = 'test-task-1';
  static const String defaultTaskId2 = 'test-task-2';
  static const String defaultTaskId3 = 'test-task-3';

  // Test Data - Error Messages
  static const String defaultErrorMessage = 'Test error';
  static const String databaseErrorMessage = 'Database error';

  // Test Data - Form Validation
  static const String requiredFieldErrorMessage = 'This field is required';
  static const String titleRequiredMessage = 'Title is required';
  static const String descriptionRequiredMessage = 'Description is required';

  // Test Data - Dates
  static final DateTime defaultDueDate =
      DateTime.now().add(const Duration(days: 1));
  static final DateTime pastDueDate =
      DateTime.now().subtract(const Duration(days: 1));

  // Test Data - Analytics
  static const int defaultTotalTasksCreated = 10;
  static const int defaultTotalTasksCompleted = 3;
  static const int defaultTasksCompletedOnTime = 2;
  static const int defaultTasksCompletedLate = 1;

  // Test Data - Lists
  static const int defaultTaskListSize = 3;
}
