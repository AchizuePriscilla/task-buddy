import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_datasource.dart';
import 'package:task_buddy/shared/domain/exceptions/database_exception.dart';

/// Remote data source interface for task operations
/// Will be implemented for cloud sync or API operations if they are made available
class TaskRemoteDataSource implements TaskDataSource {
  @override
  Future<void> createTask(TaskModel task) {
    try {
      return Future.value();
    } catch (e) {
      throw DatabaseException('Failed to create task remotely', e.toString());
    }
  }

  @override
  Future<void> deleteTask(TaskModel task) {
    try {
      return Future.value();
    } catch (e) {
      throw DatabaseException('Failed to delete task remotely', e.toString());
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks() {
    try {
      return Future.value([]);
    } catch (e) {
      throw DatabaseException('Failed to get all tasks remotely', e.toString());
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) {
    try {
      return Future.value(null);
    } catch (e) {
      throw DatabaseException(
          'Failed to get task by id remotely', e.toString());
    }
  }

  @override
  Future<void> updateTask(TaskModel task) {
    try {
      return Future.value();
    } catch (e) {
      throw DatabaseException('Failed to update task remotely', e.toString());
    }
  }

  Future<bool> isRemoteAvailable() {
    try {
      return Future.value(false);
    } catch (e) {
      throw DatabaseException(
          'Failed to check if remote is available', e.toString());
    }
  }
}
