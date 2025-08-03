import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/models/user_analytics_model.dart';

/// Service to manage user analytics for smart priority calculation
class UserAnalyticsService {
  final Map<String, UserAnalyticsModel> _analytics = {};

  /// Get analytics for a specific category
  UserAnalyticsModel? getAnalyticsForCategory(CategoryEnum category) {
    return _analytics[category.name];
  }

  /// Update analytics when a task is created
  void onTaskCreated(TaskModel task) {
    final categoryKey = task.category.name;
    final existing = _analytics[categoryKey];

    if (existing != null) {
      _analytics[categoryKey] = existing.copyWith(
        totalTasksCreated: existing.totalTasksCreated + 1,
        lastUpdated: DateTime.now(),
      );
    } else {
      _analytics[categoryKey] = UserAnalyticsModel(
        id: categoryKey,
        category: task.category,
        totalTasksCreated: 1,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Update analytics when a task is completed
  void onTaskCompleted(TaskModel task) {
    final categoryKey = task.category.name;
    final existing = _analytics[categoryKey];

    if (existing != null) {
      final wasCompletedOnTime = task.dueDate.isAfter(DateTime.now());

      _analytics[categoryKey] = existing.copyWith(
        totalTasksCompleted: existing.totalTasksCompleted + 1,
        tasksCompletedOnTime:
            existing.tasksCompletedOnTime + (wasCompletedOnTime ? 1 : 0),
        tasksCompletedLate:
            existing.tasksCompletedLate + (wasCompletedOnTime ? 0 : 1),
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Update analytics when a task is uncompleted
  void onTaskUncompleted(TaskModel task) {
    final categoryKey = task.category.name;
    final existing = _analytics[categoryKey];

    if (existing != null) {
      final wasCompletedOnTime = task.dueDate.isAfter(DateTime.now());

      _analytics[categoryKey] = existing.copyWith(
        totalTasksCompleted: existing.totalTasksCompleted - 1,
        tasksCompletedOnTime:
            existing.tasksCompletedOnTime - (wasCompletedOnTime ? 1 : 0),
        tasksCompletedLate:
            existing.tasksCompletedLate - (wasCompletedOnTime ? 0 : 1),
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Get all analytics
  Map<String, UserAnalyticsModel> getAllAnalytics() {
    return Map.unmodifiable(_analytics);
  }

  /// Clear all analytics (for testing or reset)
  void clearAnalytics() {
    _analytics.clear();
  }
}
