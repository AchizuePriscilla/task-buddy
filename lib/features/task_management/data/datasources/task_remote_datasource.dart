import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_datasource.dart';

/// Remote data source interface for task operations
/// Will be implemented for cloud sync or API operations if they are made available
class TaskRemoteDataSource implements TaskDataSource {
  @override
  Future<void> createTask(TaskModel task) {
    return Future.value();
  }

  @override
  Future<void> deleteTask(TaskModel task) {
    return Future.value();
  }

  @override
  Future<List<TaskModel>> getAllTasks() {
    return Future.value([]);
  }

  @override
  Future<TaskModel?> getTaskById(String id) {
    return Future.value(null);
  }

  @override
  Future<void> updateTask(TaskModel task) {
    return Future.value();
  }

  Future<bool> isRemoteAvailable() {
    return Future.value(false);
  }
}
