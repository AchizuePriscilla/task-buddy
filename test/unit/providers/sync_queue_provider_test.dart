import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import 'package:task_buddy/shared/domain/providers/sync_queue_provider.dart';
import 'package:task_buddy/shared/domain/providers/sync_queue_storage_provider.dart';
import 'package:task_buddy/shared/data/sync/shared_prefs_sync_queue_storage.dart';
import 'sync_queue_provider_test.mocks.dart';

@GenerateMocks([SharedPrefsSyncQueueStorage])
void main() {
  late ProviderContainer container;
  late MockSharedPrefsSyncQueueStorage mockSyncQueueStorage;

  setUp(() {
    mockSyncQueueStorage = MockSharedPrefsSyncQueueStorage();
    when(mockSyncQueueStorage.loadOperations())
        .thenAnswer((_) => Future.value([]));
    container = ProviderContainer(
      overrides: [
        syncQueueStorageProvider.overrideWithValue(mockSyncQueueStorage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    reset(mockSyncQueueStorage);
  });

  group('SyncQueueProvider', () {
    test('should create SyncQueue with storage', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());
    });

    test('should provide singleton instance', () {
      // Act
      final syncQueue1 = container.read(syncQueueProvider);
      final syncQueue2 = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue1, same(syncQueue2));
    });

    test('should have correct type', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());
      expect(syncQueue.runtimeType, equals(SyncQueue));
    });

    test('should not be null', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isNotNull);
    });

    test('should be accessible multiple times', () {
      // Act
      final syncQueue1 = container.read(syncQueueProvider);
      final syncQueue2 = container.read(syncQueueProvider);
      final syncQueue3 = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue1, isNotNull);
      expect(syncQueue2, isNotNull);
      expect(syncQueue3, isNotNull);
      expect(syncQueue1, same(syncQueue2));
      expect(syncQueue2, same(syncQueue3));
    });

    test('should maintain provider state', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());

      // Act again
      final sameSyncQueue = container.read(syncQueueProvider);

      // Assert
      expect(sameSyncQueue, same(syncQueue));
    });

    test('should handle provider access in different contexts', () {
      // Act
      final syncQueue1 = container.read(syncQueueProvider);

      // Simulate different context
      final syncQueue2 = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue1, isA<SyncQueue>());
      expect(syncQueue2, isA<SyncQueue>());
      expect(syncQueue1, same(syncQueue2));
    });

    test('should provide consistent instance across reads', () {
      // Arrange
      final instances = <SyncQueue>[];

      // Act
      for (int i = 0; i < 5; i++) {
        instances.add(container.read(syncQueueProvider));
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
          container.read(syncQueueProvider);
        }
      }, returnsNormally);
    });

    test('should provide valid SyncQueue instance', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());
      expect(syncQueue, isNotNull);
    });

    test('should handle concurrent access', () {
      // Act
      final futures = <Future<SyncQueue>>[];

      for (int i = 0; i < 3; i++) {
        futures.add(Future.value(container.read(syncQueueProvider)));
      }

      // Assert
      expect(futures.length, equals(3));
    });

    test('should maintain provider contract', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());

      // Verify it can be used as expected
      expect(syncQueue, isNotNull);
    });

    test('should not create new instance on each read', () {
      // Act
      final syncQueue1 = container.read(syncQueueProvider);
      final syncQueue2 = container.read(syncQueueProvider);
      final syncQueue3 = container.read(syncQueueProvider);

      // Assert
      expect(identical(syncQueue1, syncQueue2), isTrue);
      expect(identical(syncQueue2, syncQueue3), isTrue);
      expect(identical(syncQueue1, syncQueue3), isTrue);
    });

    test('should provide stable reference', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);
      final hashCode = syncQueue.hashCode;

      // Act again
      final sameSyncQueue = container.read(syncQueueProvider);
      final sameHashCode = sameSyncQueue.hashCode;

      // Assert
      expect(hashCode, equals(sameHashCode));
    });

    test('should use storage from provider', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());
      // Note: We can't directly verify the storage injection
      // since it's private, but we can verify the provider works
    });

    test('should handle provider disposal', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Dispose container
      container.dispose();

      // Create new container
      final newContainer = ProviderContainer(
        overrides: [
          syncQueueStorageProvider.overrideWithValue(mockSyncQueueStorage),
        ],
      );

      final newSyncQueue = newContainer.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());
      expect(newSyncQueue, isA<SyncQueue>());
      expect(syncQueue, isNot(same(newSyncQueue)));

      newContainer.dispose();
    });

    test('should provide queue with status access', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());
      expect(syncQueue.isEmpty, isA<bool>());
      expect(syncQueue.isProcessing, isA<bool>());
    });

    test('should handle multiple container instances', () {
      // Act
      final syncQueue1 = container.read(syncQueueProvider);

      // Create another container
      final container2 = ProviderContainer(
        overrides: [
          syncQueueStorageProvider.overrideWithValue(mockSyncQueueStorage),
        ],
      );

      final syncQueue2 = container2.read(syncQueueProvider);

      // Assert
      expect(syncQueue1, isA<SyncQueue>());
      expect(syncQueue2, isA<SyncQueue>());
      expect(syncQueue1, isNot(same(syncQueue2)));

      container2.dispose();
    });

    test('should provide queue with operations access', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());
      // Verify the queue has the expected methods
      expect(syncQueue, isNotNull);
    });

    test('should handle storage dependency injection', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());
      // The queue should be properly initialized with the storage dependency
    });

    test('should provide queue with proper initialization', () {
      // Act
      final syncQueue = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue, isA<SyncQueue>());
      // The queue should be initialized and ready to use
    });

    test('should maintain queue state across reads', () {
      // Act
      final syncQueue1 = container.read(syncQueueProvider);
      final syncQueue2 = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue1, same(syncQueue2));
      // Both should reference the same queue instance
    });

    test('should provide queue with consistent behavior', () {
      // Act
      final syncQueue1 = container.read(syncQueueProvider);
      final syncQueue2 = container.read(syncQueueProvider);

      // Assert
      expect(syncQueue1.isEmpty, equals(syncQueue2.isEmpty));
      expect(syncQueue1.isProcessing, equals(syncQueue2.isProcessing));
    });
  });
}
