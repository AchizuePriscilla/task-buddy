import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_remote_datasource.dart';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import 'package:task_buddy/shared/data/sync/conflict_resolver.dart';

/// Service responsible for task synchronization
class TaskSyncService {
  final TaskRemoteDataSource? _remoteDataSource;
  final SyncQueue _syncQueue;

  const TaskSyncService(this._syncQueue, [this._remoteDataSource]);

  /// Queue a sync operation
  Future<void> queueSyncOperation(
      SyncOperationType type, TaskModel task) async {
    final operation = SyncOperation(
      id: task.id,
      type: type,
      task: task,
      timestamp: DateTime.now(),
    );

    await _syncQueue.enqueue(operation);
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
  Future<List<TaskModel>> syncWithRemote(List<TaskModel> localTasks) async {
    if (_remoteDataSource == null) return localTasks;

    try {
      final isAvailable = await _remoteDataSource.isRemoteAvailable();
      if (!isAvailable) return localTasks;

      // Get remote tasks
      final remoteTasks = await _remoteDataSource.getAllTasks();

      // Merge with conflict resolution
      final mergedTasks =
          ConflictResolver.mergeTaskLists(localTasks, remoteTasks);

      // Process any pending sync operations
      if (!_syncQueue.isEmpty) {
        await _syncQueue.processQueue(_executeSyncOperation);
      }

      return mergedTasks;
    } catch (e) {
      // Return local tasks if sync fails
      return localTasks;
    }
  }

  /// Check if remote is available
  Future<bool> isRemoteAvailable() async {
    if (_remoteDataSource == null) return false;
    return await _remoteDataSource.isRemoteAvailable();
  }

  /// Get sync queue status
  bool get isQueueEmpty => _syncQueue.isEmpty;
  bool get isQueueProcessing => _syncQueue.isProcessing;
}
