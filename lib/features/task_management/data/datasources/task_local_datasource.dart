import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_datasource.dart';
import 'package:task_buddy/shared/data/local/database/database_service.dart';
import 'package:task_buddy/shared/domain/exceptions/database_exception.dart';

/// Local data source implementation using DatabaseService
/// Handles all local storage operations for tasks
class TaskLocalDataSource implements TaskDataSource {
  final DatabaseService _databaseService;

  const TaskLocalDataSource(this._databaseService);

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await _databaseService.saveTask(task);
    } catch (e) {
      throw DatabaseException('Failed to create task locally', e.toString());
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      return await _databaseService.getTask(id);
    } catch (e) {
      throw DatabaseException('Failed to retrieve task locally', e.toString());
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      return await _databaseService.getAllTasks();
    } catch (e) {
      throw DatabaseException('Failed to retrieve tasks locally', e.toString());
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _databaseService.updateTask(task);
    } catch (e) {
      throw DatabaseException('Failed to update task locally', e.toString());
    }
  }

  @override
  Future<void> deleteTask(TaskModel task) async {
    try {
      await _databaseService.deleteTask(task);
    } catch (e) {
      throw DatabaseException('Failed to delete task locally', e.toString());
    }
  }
}
