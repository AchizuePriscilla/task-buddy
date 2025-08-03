import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import 'package:task_buddy/shared/data/sync/shared_prefs_sync_queue_storage.dart';

// Generate mocks
@GenerateMocks([SharedPrefsSyncQueueStorage])
import 'sync_queue_test.mocks.dart';

void main() {
  group('SyncQueue', () {
    late SyncQueue syncQueue;
    late MockSharedPrefsSyncQueueStorage mockStorage;

    setUp(() async {
      mockStorage = MockSharedPrefsSyncQueueStorage();
      // Set up the loadOperations mock to return empty list
      when(mockStorage.loadOperations()).thenAnswer((_) => Future.value([]));
      syncQueue = SyncQueue(mockStorage);
      await syncQueue.initialize();
    });

    tearDown(() {
      reset(mockStorage);
    });

    test('should initialize with empty queue', () {
      expect(syncQueue.isEmpty, isTrue);
      expect(syncQueue.isProcessing, isFalse);
    });

    test('should add operation to queue', () async {
      // Arrange
      final operation = _createSyncOperation('1', SyncOperationType.create);
      when(mockStorage.saveOperations(argThat(isA<List<SyncOperation>>())))
          .thenAnswer((_) => Future.value());

      // Act
      await syncQueue.enqueue(operation);

      // Assert
      expect(syncQueue.isEmpty, isFalse);
    });

    test('should process operations successfully', () async {
      // Arrange
      final operation = _createSyncOperation('1', SyncOperationType.create);
      when(mockStorage.saveOperations(argThat(isA<List<SyncOperation>>())))
          .thenAnswer((_) => Future.value());
      await syncQueue.enqueue(operation);

      int processedCount = 0;
      Future<void> syncFunction(SyncOperation operation) async {
        processedCount++;
      }

      // Act
      await syncQueue.processQueue(syncFunction);

      // Assert
      expect(processedCount, equals(1));
      expect(syncQueue.isEmpty, isTrue);
    });

    test('should handle operation failures gracefully', () async {
      // Arrange
      final operation = _createSyncOperation('1', SyncOperationType.create);
      when(mockStorage.saveOperations(argThat(isA<List<SyncOperation>>())))
          .thenAnswer((_) => Future.value());
      await syncQueue.enqueue(operation);

      Future<void> failingSyncFunction(SyncOperation operation) async {
        throw Exception('Sync failed');
      }

      // Act & Assert
      expect(() async => await syncQueue.processQueue(failingSyncFunction),
          returnsNormally);
      expect(syncQueue.isEmpty, isFalse); // Operation should remain in queue
    });

    test('should handle storage errors gracefully', () async {
      // Arrange
      final operation = _createSyncOperation('1', SyncOperationType.create);
      when(mockStorage.saveOperations(argThat(isA<List<SyncOperation>>())))
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(() async => await syncQueue.enqueue(operation), returnsNormally);
      expect(syncQueue.isEmpty,
          isFalse); // Operation should still be added to memory
    });

    test('should load existing operations on initialization', () async {
      // Arrange
      final existingOperations = [
        _createSyncOperation('1', SyncOperationType.create),
        _createSyncOperation('2', SyncOperationType.update),
      ];
      when(mockStorage.loadOperations())
          .thenAnswer((_) => Future.value(existingOperations));

      // Act
      final newSyncQueue = SyncQueue(mockStorage);
      await newSyncQueue.initialize();

      // Assert
      expect(newSyncQueue.isEmpty, isFalse);
    });

    test('should handle initialization errors gracefully', () async {
      // Arrange
      when(mockStorage.loadOperations()).thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(() async {
        final newSyncQueue = SyncQueue(mockStorage);
        await newSyncQueue.initialize();
      }, returnsNormally);
    });

    test('should clear all operations', () async {
      // Arrange
      final operation = _createSyncOperation('1', SyncOperationType.create);
      when(mockStorage.saveOperations(argThat(isA<List<SyncOperation>>())))
          .thenAnswer((_) => Future.value());
      await syncQueue.enqueue(operation);

      // Act
      await syncQueue.dequeue();

      // Assert
      expect(syncQueue.isEmpty, isTrue);
    });

    test('should not process when already processing', () async {
      // Arrange
      final operation = _createSyncOperation('1', SyncOperationType.create);
      when(mockStorage.saveOperations(argThat(isA<List<SyncOperation>>())))
          .thenAnswer((_) => Future.value());
      await syncQueue.enqueue(operation);

      int processedCount = 0;
      Future<void> syncFunction(SyncOperation operation) async {
        processedCount++;
        // Simulate long-running operation
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Act - Start processing but don't wait for completion
      final future1 = syncQueue.processQueue(syncFunction);
      final future2 = syncQueue.processQueue(syncFunction);

      // Wait for both to complete
      await future1;
      await future2;

      // Assert - Only one operation should be processed due to isProcessing flag
      expect(processedCount, equals(1));
    });

    test('should process multiple operations', () async {
      // Arrange
      final operations = [
        _createSyncOperation('1', SyncOperationType.create),
        _createSyncOperation('2', SyncOperationType.update),
        _createSyncOperation('3', SyncOperationType.delete),
      ];
      when(mockStorage.saveOperations(argThat(isA<List<SyncOperation>>())))
          .thenAnswer((_) => Future.value());

      for (final operation in operations) {
        await syncQueue.enqueue(operation);
      }

      final processedOperations = <String>[];
      Future<void> syncFunction(SyncOperation operation) async {
        processedOperations.add(operation.id);
      }

      // Act
      await syncQueue.processQueue(syncFunction);

      // Assert
      expect(processedOperations.length, equals(3));
      expect(processedOperations, contains('1'));
      expect(processedOperations, contains('2'));
      expect(processedOperations, contains('3'));
      expect(syncQueue.isEmpty, isTrue);
    });
  });
}

SyncOperation _createSyncOperation(String id, SyncOperationType type) {
  return SyncOperation(
    id: id,
    type: type,
    task: TaskModel(
      id: id,
      title: 'Test Task $id',
      description: 'Test description',
      category: CategoryEnum.work,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: Priority.medium,
    ),
    timestamp: DateTime.now(),
  );
}
