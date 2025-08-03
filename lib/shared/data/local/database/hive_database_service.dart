import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/shared/data/local/database/database_service.dart';
import 'package:task_buddy/shared/domain/exceptions/database_exception.dart';

/// Hive implementation of DatabaseService
class HiveDatabaseService implements DatabaseService {
  static const String _tasksBoxName = 'tasks';
  Box<TaskModel>? _tasksBox;

  @override
  bool get isInitialized => _tasksBox != null;

  @override
  Future<void> initialize() async {
    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();

      // Register adapters
      Hive.registerAdapter(TaskModelAdapter());
      Hive.registerAdapter(PriorityAdapter());
      Hive.registerAdapter(CategoryEnumAdapter());

      // Open tasks box
      _tasksBox = await Hive.openBox<TaskModel>(_tasksBoxName);
    } catch (e) {
      throw DatabaseException('Failed to initialize database');
    }
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    _validateInitialization();

    try {
      await _tasksBox!.put(task.id, task);
    } catch (e) {
      throw DatabaseException('Failed to save task', e.toString());
    }
  }

  @override
  Future<TaskModel?> getTask(String id) async {
    _validateInitialization();

    try {
      return _tasksBox!.get(id);
    } catch (e) {
      throw DatabaseException('Failed to retrieve task', e.toString());
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    _validateInitialization();

    try {
      return _tasksBox!.values.toList();
    } catch (e) {
      throw DatabaseException('Failed to retrieve tasks', e.toString());
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    _validateInitialization();

    try {
      await _tasksBox!.put(task.id, task);
    } catch (e) {
      throw DatabaseException('Failed to update task', e.toString());
    }
  }

  @override
  Future<void> deleteTask(TaskModel task) async {
    _validateInitialization();

    try {
      await _tasksBox!.delete(task.id);
    } catch (e) {
      throw DatabaseException('Failed to delete task', e.toString());
    }
  }

  @override
  Future<void> close() async {
    try {
      await _tasksBox?.close();
      _tasksBox = null;
    } catch (e) {
      throw DatabaseException('Failed to close database', e.toString());
    }
  }

  @override
  Future<void> clearAll() async {
    _validateInitialization();

    try {
      await _tasksBox!.clear();
    } catch (e) {
      throw DatabaseException('Failed to clear database', e.toString());
    }
  }

  /// Helper method to validate database initialization
  void _validateInitialization() {
    if (!isInitialized) {
      throw DatabaseException('Database not initialized');
    }
  }
}
