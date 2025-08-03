import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';

/// Abstract repository interface for task operations
/// Defines the contract for task data access operations
abstract class TaskRepository {
  /// Create a new task
  Future<void> createTask(TaskModel task);

  /// Get a task by its ID
  Future<TaskModel?> getTaskById(String id);

  /// Get all tasks
  Future<List<TaskModel>> getAllTasks();

  /// Update an existing task
  Future<void> updateTask(TaskModel task);

  /// Delete a task by its ID
  Future<void> deleteTask(TaskModel task);

  /// Search tasks by query string
  /// Searches in title and description
 List<TaskModel> searchTasks(String query, List<TaskModel> tasks);

  /// Filter tasks by various criteria
 List<TaskModel> filterTasks({
    required List<TaskModel> tasks,
    CategoryEnum? category,
    Priority? priority,
    bool? isCompleted,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  });

  /// Get overdue tasks
  List<TaskModel> getOverdueTasks(List<TaskModel> tasks);

  /// Get tasks due today
  List<TaskModel> getTasksDueToday(List<TaskModel> tasks);

  /// Get tasks due on a specific date
  List<TaskModel> getTasksDueOn(DateTime date, List<TaskModel> tasks);

  /// Get task count by status
  Future<Map<String, int>> getTaskCounts();
}
