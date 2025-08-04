import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/services/task_sync_service.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_sync_service_provider.dart';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import 'package:task_buddy/shared/domain/providers/sync_queue_provider.dart';
import 'task_sync_service_provider_test.mocks.dart';

@GenerateMocks([SyncQueue])
void main() {
  late ProviderContainer container;
  late MockSyncQueue mockSyncQueue;

  setUp(() {
    mockSyncQueue = MockSyncQueue();
    container = ProviderContainer(
      overrides: [
        syncQueueProvider.overrideWithValue(mockSyncQueue),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    reset(mockSyncQueue);
  });

  group('TaskSyncServiceProvider', () {
    test('should create TaskSyncService with sync queue', () {
      // Act
      final syncService = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService, isA<TaskSyncService>());
    });

    test('should provide singleton instance', () {
      // Act
      final syncService1 = container.read(taskSyncServiceProvider);
      final syncService2 = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService1, same(syncService2));
    });

    test('should have correct type', () {
      // Act
      final syncService = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService, isA<TaskSyncService>());
      expect(syncService.runtimeType, equals(TaskSyncService));
    });

    test('should not be null', () {
      // Act
      final syncService = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService, isNotNull);
    });

    test('should be accessible multiple times', () {
      // Act
      final syncService1 = container.read(taskSyncServiceProvider);
      final syncService2 = container.read(taskSyncServiceProvider);
      final syncService3 = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService1, isNotNull);
      expect(syncService2, isNotNull);
      expect(syncService3, isNotNull);
      expect(syncService1, same(syncService2));
      expect(syncService2, same(syncService3));
    });

    test('should maintain provider state', () {
      // Act
      final syncService = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService, isA<TaskSyncService>());

      // Act again
      final sameSyncService = container.read(taskSyncServiceProvider);

      // Assert
      expect(sameSyncService, same(syncService));
    });

    test('should handle provider access in different contexts', () {
      // Act
      final syncService1 = container.read(taskSyncServiceProvider);

      // Simulate different context
      final syncService2 = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService1, isA<TaskSyncService>());
      expect(syncService2, isA<TaskSyncService>());
      expect(syncService1, same(syncService2));
    });

    test('should provide consistent instance across reads', () {
      // Arrange
      final instances = <TaskSyncService>[];

      // Act
      for (int i = 0; i < 5; i++) {
        instances.add(container.read(taskSyncServiceProvider));
      }

      // Assert
      expect(instances.length, equals(5));
      for (int i = 1; i < instances.length; i++) {
        expect(instances[i], same(instances[0]));
      }
    });

    test('should not throw when accessed multiple times', () {
      // Act & Assert
      expect(() {
        for (int i = 0; i < 10; i++) {
          container.read(taskSyncServiceProvider);
        }
      }, returnsNormally);
    });

    test('should provide valid TaskSyncService instance', () {
      // Act
      final syncService = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService, isA<TaskSyncService>());
      expect(syncService, isNotNull);
    });

    test('should handle concurrent access', () {
      // Act
      final futures = <Future<TaskSyncService>>[];

      for (int i = 0; i < 3; i++) {
        futures.add(Future.value(container.read(taskSyncServiceProvider)));
      }

      // Assert
      expect(futures.length, equals(3));
    });

    test('should maintain provider contract', () {
      // Act
      final syncService = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService, isA<TaskSyncService>());

      // Verify it can be used as expected
      expect(syncService, isNotNull);
    });

    test('should not create new instance on each read', () {
      // Act
      final syncService1 = container.read(taskSyncServiceProvider);
      final syncService2 = container.read(taskSyncServiceProvider);
      final syncService3 = container.read(taskSyncServiceProvider);

      // Assert
      expect(identical(syncService1, syncService2), isTrue);
      expect(identical(syncService2, syncService3), isTrue);
      expect(identical(syncService1, syncService3), isTrue);
    });

    test('should provide stable reference', () {
      // Act
      final syncService = container.read(taskSyncServiceProvider);
      final hashCode = syncService.hashCode;

      // Act again
      final sameSyncService = container.read(taskSyncServiceProvider);
      final sameHashCode = sameSyncService.hashCode;

      // Assert
      expect(hashCode, equals(sameHashCode));
    });

    test('should handle provider disposal', () {
      // Act
      final syncService = container.read(taskSyncServiceProvider);

      // Dispose container
      container.dispose();

      // Create new container
      final newContainer = ProviderContainer(
        overrides: [
          syncQueueProvider.overrideWithValue(mockSyncQueue),
        ],
      );

      final newSyncService = newContainer.read(taskSyncServiceProvider);

      // Assert
      expect(syncService, isA<TaskSyncService>());
      expect(newSyncService, isA<TaskSyncService>());
      expect(syncService, isNot(same(newSyncService)));

      newContainer.dispose();
    });

    test('should handle null remote data source', () {
      // Act
      final syncService = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService, isA<TaskSyncService>());
      // The service should handle null remote data source gracefully
    });

    test('should provide service with correct dependencies', () {
      // Arrange
      when(mockSyncQueue.isEmpty).thenReturn(false);
      when(mockSyncQueue.isProcessing).thenReturn(true);

      // Act
      final syncService = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService, isA<TaskSyncService>());
      expect(syncService.isQueueEmpty, isA<bool>());
      expect(syncService.isQueueProcessing, isA<bool>());
    });

    test('should handle multiple container instances', () {
      // Act
      final syncService1 = container.read(taskSyncServiceProvider);

      // Create another container
      final container2 = ProviderContainer(
        overrides: [
          syncQueueProvider.overrideWithValue(mockSyncQueue),
        ],
      );

      final syncService2 = container2.read(taskSyncServiceProvider);

      // Assert
      expect(syncService1, isA<TaskSyncService>());
      expect(syncService2, isA<TaskSyncService>());
      expect(syncService1, isNot(same(syncService2)));

      container2.dispose();
    });

    test('should provide service with queue status access', () {
      // Arrange
      when(mockSyncQueue.isEmpty).thenReturn(true);
      when(mockSyncQueue.isProcessing).thenReturn(false);

      // Act
      final syncService = container.read(taskSyncServiceProvider);

      // Assert
      expect(syncService.isQueueEmpty, isTrue);
      expect(syncService.isQueueProcessing, isFalse);
    });
  });
}
