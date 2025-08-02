import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
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
  Future<void> deleteTask(String id);
  Future<List<TaskModel>> searchTasks(String query);
  Future<List<TaskModel>> filterTasks({
    CategoryEnum? category,
    Priority? priority,
    bool? isCompleted,
  });
  
  // Database state
  bool get isInitialized;
}