import 'package:flutter/foundation.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/extensions/datetime_extension.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/models/user_analytics_model.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/domain/services/user_analytics_service.dart';

/// Service responsible for smart priority calculations and updates
class SmartPriorityService {
  final TaskRepository _taskRepository;
  final UserAnalyticsService _analyticsService;

  SmartPriorityService(this._taskRepository, this._analyticsService);

  /// Recalculates priorities for all tasks in a specific category
  Future<void> recalculatePriorities(CategoryEnum category) async {
    try {
      // Get all tasks in the category
      final allTasks = await _taskRepository.getAllTasks();
      final categoryTasks =
          allTasks.where((task) => task.category == category).toList();

      // Get user analytics for the category
      final analytics = _analyticsService.getAnalyticsForCategory(category);

      // Recalculate priorities for incomplete tasks only
      for (final task in categoryTasks) {
        if (!task.isCompleted) {
          final newPriority = SmartPriorityCalculator.calculatePriority(
            dueDate: task.dueDate,
            category: category,
            analytics: analytics,
            categoryTasks: categoryTasks,
          );
          // Only update if priority has changed
          if (newPriority != task.priority) {
            final updatedTask = task.copyWith(
              priority: newPriority,
              updatedAt: DateTime.now(),
            );
            await _taskRepository.updateTask(updatedTask);
          }
        }
      }
    } catch (e) {
      // Log error but don't throw - smart priority should not break main functionality
      debugPrint('Smart priority recalculation failed: $e');
    }
  }

  /// Recalculates priorities for all categories
  Future<void> recalculateAllPriorities() async {
    for (final category in CategoryEnum.values) {
      await recalculatePriorities(category);
    }
  }

  /// Recalculates priorities when a task is completed
  Future<void> onTaskCompleted(TaskModel completedTask) async {
    // Recalculate priorities for the category of the completed task
    await recalculatePriorities(completedTask.category);
  }

  /// Recalculates priorities when a task is created
  Future<void> onTaskCreated(TaskModel newTask) async {
    // Recalculate priorities for the category of the new task
    await recalculatePriorities(newTask.category);
  }

  /// Recalculates priorities when a task is updated
  Future<void> onTaskUpdated(TaskModel updatedTask) async {
    // Recalculate priorities for the category of the updated task
    await recalculatePriorities(updatedTask.category);
  }
}

/// Calculator for smart priority logic
class SmartPriorityCalculator {
  /// Calculates priority based on multiple factors
  static Priority calculatePriority({
    required DateTime dueDate,
    required CategoryEnum category,
    UserAnalyticsModel? analytics,
    required List<TaskModel> categoryTasks,
  }) {
    // 1. Base priority from due date
    Priority basePriority = _calculateBasePriority(dueDate);

    // 2. Adjust based on user completion patterns
    Priority userAdjustedPriority =
        _adjustForUserPatterns(basePriority, analytics);

    // 3. Adjust based on category workload
    Priority workloadAdjustedPriority =
        _adjustForWorkload(userAdjustedPriority, categoryTasks);

    return workloadAdjustedPriority;
  }

  /// Calculates base priority from due date proximity
  static Priority _calculateBasePriority(DateTime dueDate) {
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;

    if (daysUntilDue < 0) {
      return Priority.urgent; // Overdue
    } else if (daysUntilDue == 0 && dueDate.isSameDay(DateTime.now())) {
      return Priority.urgent; // Due today
    } else if (daysUntilDue <= 1) {
      return Priority.high; // Due tomorrow
    } else if (daysUntilDue <= 3) {
      return Priority.high; // Due within 3 days
    } else if (daysUntilDue <= 7) {
      return Priority.medium; // Due within a week
    } else {
      return Priority.low; // Due later
    }
  }

  /// Adjusts priority based on user completion patterns
  static Priority _adjustForUserPatterns(
      Priority basePriority, UserAnalyticsModel? analytics) {
    if (analytics == null) {
      return basePriority;
    }

    final completionRate = analytics.completionRate;
    final onTimeRate = analytics.onTimeCompletionRate;

    // If user has low completion rate, increase priority
    if (completionRate < 0.5) {
      return _increasePriority(basePriority);
    }

    // If user has low on-time completion rate, increase priority
    if (onTimeRate < 0.7) {
      return _increasePriority(basePriority);
    }

    // If user has high completion rate and on-time rate, maintain or decrease priority
    if (completionRate > 0.8 && onTimeRate > 0.9) {
      return _decreasePriority(basePriority);
    }

    return basePriority;
  }

  /// Adjusts priority based on category workload
  static Priority _adjustForWorkload(
      Priority basePriority, List<TaskModel> categoryTasks) {
    final incompleteTasks =
        categoryTasks.where((task) => !task.isCompleted).length;

    // If there are many incomplete tasks, increase priority
    if (incompleteTasks > 5) {
      return _increasePriority(basePriority);
    }

    // If there are very few tasks, maintain or decrease priority
    if (incompleteTasks <= 2) {
      return _decreasePriority(basePriority);
    }

    return basePriority;
  }

  /// Increases priority level
  static Priority _increasePriority(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Priority.medium;
      case Priority.medium:
        return Priority.high;
      case Priority.high:
        return Priority.urgent;
      case Priority.urgent:
        return Priority.urgent; // Already at max
    }
  }

  /// Decreases priority level
  static Priority _decreasePriority(Priority priority) {
    switch (priority) {
      case Priority.urgent:
        return Priority.high;
      case Priority.high:
        return Priority.medium;
      case Priority.medium:
        return Priority.low;
      case Priority.low:
        return Priority.low; // Already at min
    }
  }
}
