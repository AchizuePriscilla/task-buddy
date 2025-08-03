import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_datasource.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_remote_datasource.dart';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import 'package:task_buddy/shared/data/sync/conflict_resolver.dart';
import 'package:task_buddy/shared/domain/exceptions/database_exception.dart';
import 'package:task_buddy/shared/domain/exceptions/task_repository_exception.dart';

/// Enhanced repository implementation with offline-first architecture
/// Supports local storage with sync queue and conflict resolution
class TaskRepositoryImplWithSync implements TaskRepository {
  final TaskDataSource _localDataSource;
  final TaskRemoteDataSource? _remoteDataSource;
  final SyncQueue _syncQueue;

  const TaskRepositoryImplWithSync(
    this._localDataSource,
    this._syncQueue, [
    this._remoteDataSource,
  ]);

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await _localDataSource.createTask(task);
      _queueSyncOperation(SyncOperationType.create, task);
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
      _queueSyncOperation(SyncOperationType.update, task);
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
      _queueSyncOperation(SyncOperationType.delete, task);
    } on DatabaseException catch (e) {
      throw TaskRepositoryException('Failed to delete task: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error deleting task: ${e.toString()}');
    }
  }

  @override
  List<TaskModel> searchTasks(String query, List<TaskModel> tasks) {
    try {
      if (query.trim().isEmpty) {
        return tasks;
      }
      return tasks.where((task) {
        return task.title.toLowerCase().contains(query.trim().toLowerCase()) ||
            (task.description
                    ?.toLowerCase()
                    .contains(query.trim().toLowerCase()) ??
                false);
      }).toList();
    } on DatabaseException catch (e) {
      throw TaskRepositoryException('Failed to search tasks: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error searching tasks: ${e.toString()}');
    }
  }

  @override
  List<TaskModel> filterTasks({
    required List<TaskModel> tasks,
    CategoryEnum? category,
    Priority? priority,
    bool? isCompleted,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  }) {
    try {
      final filteredTasks = tasks.where((task) {
        if (category != null && task.category != category) {
          return false;
        }
        if (priority != null && task.priority != priority) {
          return false;
        }
        if (isCompleted != null && task.isCompleted != isCompleted) {
          return false;
        }
        return true;
      }).toList();
      return _applyDateFilter(filteredTasks, dueDateFrom, dueDateTo);
    } on DatabaseException catch (e) {
      throw TaskRepositoryException('Failed to filter tasks: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error filtering tasks: ${e.toString()}');
    }
  }

  @override
  List<TaskModel> getOverdueTasks(List<TaskModel> tasks) {
    try {
      final now = DateTime.now();

      return tasks
          .where((task) => !task.isCompleted && task.dueDate.isBefore(now))
          .toList();
    } on DatabaseException catch (e) {
      throw TaskRepositoryException(
          'Failed to get overdue tasks: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error getting overdue tasks: ${e.toString()}');
    }
  }

  @override
  List<TaskModel> getTasksDueToday(List<TaskModel> tasks) {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return _getTasksDueBetween(tasks, startOfDay, endOfDay);
    } on DatabaseException catch (e) {
      throw TaskRepositoryException(
          'Failed to get tasks due today: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error getting tasks due today: ${e.toString()}');
    }
  }

  @override
  List<TaskModel> getTasksDueOn(DateTime date, List<TaskModel> tasks) {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return _getTasksDueBetween(tasks, startOfDay, endOfDay);
    } on DatabaseException catch (e) {
      throw TaskRepositoryException(
          'Failed to get tasks due on date: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error getting tasks due on date: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, int>> getTaskCounts() async {
    try {
      final allTasks = await _localDataSource.getAllTasks();

      return {
        'total': allTasks.length,
        'completed': allTasks.where((task) => task.isCompleted).length,
        'pending': allTasks.where((task) => !task.isCompleted).length,
        'overdue': allTasks
            .where((task) =>
                !task.isCompleted && task.dueDate.isBefore(DateTime.now()))
            .length,
        'dueToday': allTasks
            .where((task) =>
                !task.isCompleted &&
                task.dueDate.isAfter(
                    DateTime.now().subtract(const Duration(days: 1))) &&
                task.dueDate
                    .isBefore(DateTime.now().add(const Duration(days: 1))))
            .length,
      };
    } on DatabaseException catch (e) {
      throw TaskRepositoryException('Failed to get task counts: ${e.message}');
    } catch (e) {
      throw TaskRepositoryException(
          'Unexpected error getting task counts: ${e.toString()}');
    }
  }

  /// Helper method to apply date filtering to a list of tasks
  List<TaskModel> _applyDateFilter(
    List<TaskModel> tasks,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  ) {
    return tasks.where((task) {
      if (dueDateFrom != null && task.dueDate.isBefore(dueDateFrom)) {
        return false;
      }
      if (dueDateTo != null && task.dueDate.isAfter(dueDateTo)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Helper method to get tasks due between two dates from a given list
  List<TaskModel> _getTasksDueBetween(
    List<TaskModel> tasks,
    DateTime fromDate,
    DateTime toDate,
  ) {
    return tasks
        .where((task) =>
            task.dueDate
                .isAfter(fromDate.subtract(const Duration(seconds: 1))) &&
            task.dueDate.isBefore(toDate))
        .toList();
  }

  /// Queue a sync operation for later execution
  Future<void> _queueSyncOperation(
      SyncOperationType type, TaskModel task) async {
    final operation = SyncOperation(
      id: task.id,
      type: type,
      task: task,
      timestamp: DateTime.now(),
    );

    await _syncQueue.enqueue(operation);

    // Try to process queue if remote is available
    _tryProcessSyncQueue();
  }

  /// Try to process the sync queue when remote is available
  void _tryProcessSyncQueue() {
    if (_remoteDataSource == null) return;
    _remoteDataSource.isRemoteAvailable().then((isAvailable) {
      if (isAvailable && !_syncQueue.isEmpty && !_syncQueue.isProcessing) {
        _syncQueue.processQueue(_executeSyncOperation);
      }
    }).catchError((error) {
      // Silently ignore - queue will be processed later
    });
  }

  /// Execute a sync operation on the remote data source
  Future<void> _executeSyncOperation(SyncOperation operation) async {
    if (_remoteDataSource == null) return;
    switch (operation.type) {
      case SyncOperationType.create:
        await _remoteDataSource.createTask(operation.task);
        break;
      case SyncOperationType.update:
        await _remoteDataSource.updateTask(operation.task);
        break;
      case SyncOperationType.delete:
        await _remoteDataSource.deleteTask(operation.task);
        break;
    }
  }

  /// Sync local and remote data with conflict resolution
  Future<void> syncWithRemote() async {
    if (_remoteDataSource == null) return;

    try {
      final isAvailable = await _remoteDataSource.isRemoteAvailable();
      if (!isAvailable) return;

      // Get local and remote tasks
      final localTasks = await getAllTasks();
      final remoteTasks = await _remoteDataSource.getAllTasks();

      // Merge with conflict resolution
      final mergedTasks =
          ConflictResolver.mergeTaskLists(localTasks, remoteTasks);

      // Update local storage with merged data
      for (final task in mergedTasks) {
        await _localDataSource.updateTask(task);
      }

      // Process any pending sync operations
      if (!_syncQueue.isEmpty) {
        await _syncQueue.processQueue(_executeSyncOperation);
      }
    } catch (e) {
      // Silently ignore sync errors - offline-first approach
    }
  }
}
