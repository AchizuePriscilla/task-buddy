import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_datasource.dart';
import 'package:task_buddy/features/task_management/domain/services/task_sync_service.dart';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import 'package:task_buddy/shared/domain/exceptions/database_exception.dart';
import 'package:task_buddy/shared/domain/exceptions/task_repository_exception.dart';

/// Repository implementation for local database
class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource _localDataSource;
  final TaskSyncService _syncService;

  const TaskRepositoryImpl(
    this._localDataSource,
    this._syncService,
  );

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await _localDataSource.createTask(task);
      await _syncService.queueSyncOperation(SyncOperationType.create, task);
    } on DatabaseException catch (e) {
      throw TaskRepositoryException('Failed to create task: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error creating task: ${e.toString()}');
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      return await _localDataSource.getTaskById(id);
    } on DatabaseException catch (e) {
      throw TaskRepositoryException('Failed to retrieve task: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error retrieving task: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      return await _localDataSource.getAllTasks();
    } on DatabaseException catch (e) {
      throw TaskRepositoryException('Failed to retrieve tasks: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error retrieving tasks: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _localDataSource.updateTask(task);
      await _syncService.queueSyncOperation(SyncOperationType.update, task);
    } on DatabaseException catch (e) {
      throw TaskRepositoryException('Failed to update task: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error updating task: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTask(TaskModel task) async {
    try {
      await _localDataSource.deleteTask(task);
      await _syncService.queueSyncOperation(SyncOperationType.delete, task);
    } on DatabaseException catch (e) {
      throw TaskRepositoryException('Failed to delete task: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error deleting task: ${e.toString()}');
    }
  }
}
