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
}
