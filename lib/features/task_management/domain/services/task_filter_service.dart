import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';

/// Service responsible for filtering tasks
class TaskFilterService {
  /// Filter tasks by multiple criteria
  List<TaskModel> filterTasks({
    required List<TaskModel> tasks,
    String? searchQuery,
    CategoryEnum? category,
    Priority? priority,
    bool? isCompleted,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  }) {
    return tasks.where((task) {
      // Search query filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final titleMatch = task.title.toLowerCase().contains(query);
        final descriptionMatch =
            task.description?.toLowerCase().contains(query) ?? false;
        if (!titleMatch && !descriptionMatch) {
          return false;
        }
      }

      // Category filter
      if (category != null && task.category != category) {
        return false;
      }

      // Priority filter
      if (priority != null && task.priority != priority) {
        return false;
      }

      // Completion status filter
      if (isCompleted != null && task.isCompleted != isCompleted) {
        return false;
      }

      // Due date range filter
      if (dueDateFrom != null && task.dueDate.isBefore(dueDateFrom)) {
        return false;
      }
      if (dueDateTo != null && task.dueDate.isAfter(dueDateTo)) {
        return false;
      }

      // If all filters pass, include the task
      return true;
    }).toList();
  }

  /// Get overdue tasks
  List<TaskModel> getOverdueTasks(List<TaskModel> tasks) {
    return tasks
        .where((task) =>
            !task.isCompleted && task.dueDate.isBefore(DateTime.now()))
        .toList();
  }

  /// Get tasks due today
  List<TaskModel> getTasksDueToday(List<TaskModel> tasks) {
    final today = DateTime.now();
    return tasks
        .where((task) =>
            task.dueDate.year == today.year &&
            task.dueDate.month == today.month &&
            task.dueDate.day == today.day)
        .toList();
  }

  /// Get tasks due on a specific date
  List<TaskModel> getTasksDueOn(DateTime date, List<TaskModel> tasks) {
    return tasks
        .where((task) =>
            task.dueDate.year == date.year &&
            task.dueDate.month == date.month &&
            task.dueDate.day == date.day)
        .toList();
  }

  /// Get task counts by status
  Map<String, int> getTaskCounts(List<TaskModel> tasks) {
    return {
      'total': tasks.length,
      'completed': tasks.where((task) => task.isCompleted).length,
      'pending': tasks.where((task) => !task.isCompleted).length,
      'overdue': tasks
          .where((task) =>
              !task.isCompleted && task.dueDate.isBefore(DateTime.now()))
          .length,
      'dueToday': tasks
          .where((task) =>
              !task.isCompleted &&
              task.dueDate
                  .isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
              task.dueDate
                  .isBefore(DateTime.now().add(const Duration(days: 1))))
          .length,
    };
  }
}
