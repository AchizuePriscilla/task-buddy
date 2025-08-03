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
    List<TaskModel> filteredTasks = tasks;
    return filteredTasks = filteredTasks.where((task) {
      if (searchQuery != null &&
          (task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              (task.description
                      ?.toLowerCase()
                      .contains(searchQuery.toLowerCase()) ??
                  false))) {
        return true;
      }
      if (category != null && task.category == category) {
        return true;
      }
      if (priority != null && task.priority == priority) {
        return true;
      }
      if (isCompleted != null && task.isCompleted == isCompleted) {
        return true;
      }
      if (dueDateFrom != null && task.dueDate.isBefore(dueDateFrom)) {
        return false;
      }
      if (dueDateTo != null && task.dueDate.isAfter(dueDateTo)) {
        return false;
      }
      return false;
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
