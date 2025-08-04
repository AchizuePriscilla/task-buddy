import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/models/user_analytics_model.dart';
import 'test_constants.dart';

/// Factory class for creating test data objects
///
/// Provides consistent, reusable test data creation methods
/// to avoid duplication and improve test maintainability
class TestDataFactory {
  /// Creates a TaskModel with default or custom values
  static TaskModel createTask({
    String? id,
    String? title,
    String? description,
    CategoryEnum? category,
    Priority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
  }) {
    final now = DateTime.now();

    return TaskModel(
      id: id ?? TestConstants.defaultTaskId,
      title: title ?? TestConstants.defaultTaskTitle,
      description: description ?? TestConstants.defaultTaskDescription,
      category: category ?? CategoryEnum.work,
      priority: priority ?? Priority.medium,
      dueDate: dueDate ?? TestConstants.defaultDueDate,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      isCompleted: isCompleted ?? false,
    );
  }

  /// Creates a list of TaskModel objects
  static List<TaskModel> createTaskList({
    int count = TestConstants.defaultTaskListSize,
    CategoryEnum? category,
    Priority? priority,
    bool? isCompleted,
  }) {
    return List.generate(count, (index) {
      return createTask(
        id: 'task-$index',
        title: 'Task $index',
        description: 'Description for task $index',
        category: category,
        priority: priority,
        isCompleted: isCompleted,
      );
    });
  }

  /// Creates a completed task
  static TaskModel createCompletedTask({
    String? id,
    String? title,
    CategoryEnum? category,
    Priority? priority,
  }) {
    return createTask(
      id: id,
      title: title,
      category: category,
      priority: priority,
      isCompleted: true,
    );
  }

  /// Creates a UserAnalyticsModel with default or custom values
  static UserAnalyticsModel createUserAnalytics({
    String? id,
    CategoryEnum? category,
    int? totalTasksCreated,
    int? totalTasksCompleted,
    int? tasksCompletedOnTime,
    int? tasksCompletedLate,
    DateTime? lastUpdated,
  }) {
    return UserAnalyticsModel(
      id: id ?? 'test-analytics-1',
      category: category ?? CategoryEnum.work,
      totalTasksCreated:
          totalTasksCreated ?? TestConstants.defaultTotalTasksCreated,
      totalTasksCompleted:
          totalTasksCompleted ?? TestConstants.defaultTotalTasksCompleted,
      tasksCompletedOnTime:
          tasksCompletedOnTime ?? TestConstants.defaultTasksCompletedOnTime,
      tasksCompletedLate:
          tasksCompletedLate ?? TestConstants.defaultTasksCompletedLate,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}
