import 'package:task_buddy/features/task_management/domain/models/task_model.dart';

/// Abstract database service interface
/// Provides database-agnostic operations for tasks
abstract class DatabaseService {
  /// Initialize the database
  Future<void> initialize();

  /// Close the database
  Future<void> close();

  /// Clear all data
  Future<void> clearAll();

  // Task operations
  Future<void> saveTask(TaskModel task);
  Future<TaskModel?> getTask(String id);
  Future<List<TaskModel>> getAllTasks();
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(TaskModel task);

  // Database state
  bool get isInitialized;
}
