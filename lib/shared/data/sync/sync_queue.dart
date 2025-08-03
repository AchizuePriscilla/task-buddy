import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:flutter/foundation.dart';
import 'package:task_buddy/shared/data/sync/shared_prefs_sync_queue_storage.dart';

/// Represents a sync operation to be queued for later execution
enum SyncOperationType {
  create,
  update,
  delete,
}

class SyncOperation {
  final String id;
  final SyncOperationType type;
  final TaskModel task;
  final DateTime timestamp;
  final int retryCount;

  SyncOperation({
    required this.id,
    required this.type,
    required this.task,
    required this.timestamp,
    this.retryCount = 0,
  });

  SyncOperation copyWith({
    String? id,
    SyncOperationType? type,
    TaskModel? task,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      task: task ?? this.task,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'task': task.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'],
      type: SyncOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      task: TaskModel.fromJson(json['task']),
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }
}

/// Manages sync operations queue for offline-first architecture
class SyncQueue {
  static const int _maxRetries = 10;

  final List<SyncOperation> _operations = [];
  final SharedPrefsSyncQueueStorage _storage;
  bool _isProcessing = false;
  bool _isInitialized = false;

  SyncQueue(this._storage);

  /// Initialize the sync queue and load existing operations
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _storage.loadOperations().then((operations) {
        _operations.addAll(operations);
        debugPrint(
            'Sync queue initialized with ${operations.length} operations');
      });
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize sync queue: $e');
      // Continue without persistence if storage fails
      _isInitialized = true;
    }
  }

  /// Save queue to persistent storage
  Future<void> saveQueue() async {
    try {
      await _storage.saveOperations(_operations);
    } catch (e) {
      debugPrint('Failed to save sync queue: $e');
      // Don't rethrow - queue operations should continue even if persistence fails
    }
  }

  /// Add a sync operation to the queue
  Future<void> enqueue(SyncOperation operation) async {
    _operations.add(operation);
    await saveQueue();
  }

  /// Check if queue is empty
  bool get isEmpty => _operations.isEmpty;

  /// Check if queue is being processed
  bool get isProcessing => _isProcessing;

  /// Process all pending operations
  Future<void> processQueue(Function(SyncOperation) syncFunction) async {
    if (_isProcessing || _operations.isEmpty) return;

    _isProcessing = true;

    try {
      // Create a copy of the operations list to avoid concurrent modification
      final operationsToProcess = List<SyncOperation>.from(_operations);
      final operationsToRemove = <SyncOperation>[];
      final operationsToUpdate = <SyncOperation>[];

      for (final operation in operationsToProcess) {
        try {
          await syncFunction(operation);
          operationsToRemove.add(operation);
        } catch (e) {
          debugPrint('Sync operation failed: ${operation.id}, error: $e');

          // Increment retry count
          final updatedOperation = operation.copyWith(
            retryCount: operation.retryCount + 1,
          );

          if (updatedOperation.retryCount >= _maxRetries) {
            // Remove operation after max retries
            operationsToRemove.add(operation);
            debugPrint(
                'Sync operation failed after $_maxRetries retries: ${operation.id}');
          } else {
            // Update operation with new retry count
            operationsToUpdate.add(updatedOperation);
          }
        }
      }

      // Apply all changes after processing
      for (final operation in operationsToRemove) {
        _operations.remove(operation);
      }

      for (final updatedOperation in operationsToUpdate) {
        final index =
            _operations.indexWhere((op) => op.id == updatedOperation.id);
        if (index != -1) {
          _operations[index] = updatedOperation;
        }
      }

      await saveQueue();
    } finally {
      _isProcessing = false;
    }
  }

  /// Clear all operations from queue
  Future<void> dequeue() async {
    _operations.clear();
    await saveQueue();
  }
}
