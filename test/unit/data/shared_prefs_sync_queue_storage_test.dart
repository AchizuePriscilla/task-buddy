import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_buddy/shared/data/sync/shared_prefs_sync_queue_storage.dart';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import 'package:task_buddy/shared/data/local/local_storage_service.dart';
import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factory.dart';
import 'shared_prefs_sync_queue_storage_test.mocks.dart';

@GenerateMocks([LocalStorageService])
void main() {
  late SharedPrefsSyncQueueStorage storage;
  late MockLocalStorageService mockLocalStorageService;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    storage = SharedPrefsSyncQueueStorage(mockLocalStorageService);
  });

  tearDown(() {
    reset(mockLocalStorageService);
  });

  group('SharedPrefsSyncQueueStorage', () {
    test('should save operations successfully', () async {
      // Arrange
      final operations = [
        SyncOperation(
          id: TestConstants.defaultTaskId,
          type: SyncOperationType.create,
          task: TestDataFactory.createTask(),
          retryCount: 0,
          timestamp: DateTime.now(),
        ),
      ];

      when(mockLocalStorageService.set(any, any))
          .thenAnswer((_) => Future.value(true));

      // Act
      await storage.saveOperations(operations);

      // Assert
      verify(mockLocalStorageService.set(any, any)).called(1);
    });

    test('should load operations successfully', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      final operationData = [
        {
          'id': TestConstants.defaultTaskId,
          'type': 'create',
          'task': task.toJson(),
          'retryCount': 0,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ];

      when(mockLocalStorageService.get(any))
          .thenAnswer((_) => Future.value(jsonEncode(operationData)));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result.length, equals(1));
      expect(result.first.id, equals(TestConstants.defaultTaskId));
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should return empty list when no operations exist', () async {
      // Arrange
      when(mockLocalStorageService.get(any))
          .thenAnswer((_) => Future.value(null));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result, isEmpty);
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should handle save operations error gracefully', () async {
      // Arrange
      final operations = [
        SyncOperation(
          id: TestConstants.defaultTaskId,
          type: SyncOperationType.create,
          task: TestDataFactory.createTask(),
          retryCount: 0,
          timestamp: DateTime.now(),
        ),
      ];

      when(mockLocalStorageService.set(any, any))
          .thenThrow(Exception(TestConstants.defaultErrorMessage));

      // Act & Assert
      expect(
        () => storage.saveOperations(operations),
        throwsA(isA<Exception>()),
      );
      verify(mockLocalStorageService.set(any, any)).called(1);
    });

    test('should handle load operations error gracefully', () async {
      // Arrange
      when(mockLocalStorageService.get(any))
          .thenThrow(Exception(TestConstants.defaultErrorMessage));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result, isEmpty);
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should save multiple operations', () async {
      // Arrange
      final operations = [
        SyncOperation(
          id: TestConstants.defaultTaskId,
          type: SyncOperationType.create,
          task: TestDataFactory.createTask(),
          retryCount: 0,
          timestamp: DateTime.now(),
        ),
        SyncOperation(
          id: TestConstants.defaultTaskId2,
          type: SyncOperationType.update,
          task: TestDataFactory.createTask(id: TestConstants.defaultTaskId2),
          retryCount: 1,
          timestamp: DateTime.now(),
        ),
      ];

      when(mockLocalStorageService.set(any, any))
          .thenAnswer((_) => Future.value(true));

      // Act
      await storage.saveOperations(operations);

      // Assert
      verify(mockLocalStorageService.set(any, any)).called(1);
    });

    test('should load multiple operations', () async {
      // Arrange
      final task1 = TestDataFactory.createTask();
      final task2 =
          TestDataFactory.createTask(id: TestConstants.defaultTaskId2);
      final operationData = [
        {
          'id': TestConstants.defaultTaskId,
          'type': 'create',
          'task': task1.toJson(),
          'retryCount': 0,
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': TestConstants.defaultTaskId2,
          'type': 'update',
          'task': task2.toJson(),
          'retryCount': 1,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ];

      when(mockLocalStorageService.get(any))
          .thenAnswer((_) => Future.value(jsonEncode(operationData)));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result.length, equals(2));
      expect(result.first.id, equals(TestConstants.defaultTaskId));
      expect(result.last.id, equals(TestConstants.defaultTaskId2));
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should handle empty operations list', () async {
      // Arrange
      final operations = <SyncOperation>[];

      when(mockLocalStorageService.set(any, any))
          .thenAnswer((_) => Future.value(true));

      // Act
      await storage.saveOperations(operations);

      // Assert
      verify(mockLocalStorageService.set(any, any)).called(1);
    });

    test('should handle invalid operation data gracefully', () async {
      // Arrange
      when(mockLocalStorageService.get(any))
          .thenAnswer((_) => Future.value('invalid json data'));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result, isEmpty);
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should handle malformed operation data', () async {
      // Arrange
      final malformedData = [
        {
          'id': TestConstants.defaultTaskId,
          'type': 'invalid_type',
          'task': 'invalid_task_data',
          'retryCount': 'not_a_number',
          'timestamp': 'invalid_timestamp',
        }
      ];

      when(mockLocalStorageService.get(any))
          .thenAnswer((_) => Future.value(jsonEncode(malformedData)));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result, isEmpty);
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should handle null task data', () async {
      // Arrange
      final operationData = [
        {
          'id': TestConstants.defaultTaskId,
          'type': 'create',
          'task': null,
          'retryCount': 0,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ];

      when(mockLocalStorageService.get(any))
          .thenAnswer((_) => Future.value(jsonEncode(operationData)));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result, isEmpty);
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should handle different operation types', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      final operationData = [
        {
          'id': TestConstants.defaultTaskId,
          'type': 'create',
          'task': task.toJson(),
          'retryCount': 0,
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': TestConstants.defaultTaskId2,
          'type': 'update',
          'task': task.toJson(),
          'retryCount': 0,
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': TestConstants.defaultTaskId3,
          'type': 'delete',
          'task': task.toJson(),
          'retryCount': 0,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ];

      when(mockLocalStorageService.get(any))
          .thenAnswer((_) => Future.value(jsonEncode(operationData)));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result.length, equals(3));
      expect(result[0].type, equals(SyncOperationType.create));
      expect(result[1].type, equals(SyncOperationType.update));
      expect(result[2].type, equals(SyncOperationType.delete));
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should handle retry count correctly', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      final operationData = [
        {
          'id': TestConstants.defaultTaskId,
          'type': 'create',
          'task': task.toJson(),
          'retryCount': 3,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ];

      when(mockLocalStorageService.get(any))
          .thenAnswer((_) => Future.value(jsonEncode(operationData)));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result.length, equals(1));
      expect(result.first.retryCount, equals(3));
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should handle timestamp parsing correctly', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      final timestamp = DateTime.now();
      final operationData = [
        {
          'id': TestConstants.defaultTaskId,
          'type': 'create',
          'task': task.toJson(),
          'retryCount': 0,
          'timestamp': timestamp.toIso8601String(),
        }
      ];

      when(mockLocalStorageService.get(any))
          .thenAnswer((_) => Future.value(jsonEncode(operationData)));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result.length, equals(1));
      expect(result.first.timestamp.year, equals(timestamp.year));
      expect(result.first.timestamp.month, equals(timestamp.month));
      expect(result.first.timestamp.day, equals(timestamp.day));
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should handle storage service errors during save', () async {
      // Arrange
      final operations = [
        SyncOperation(
          id: TestConstants.defaultTaskId,
          type: SyncOperationType.create,
          task: TestDataFactory.createTask(),
          retryCount: 0,
          timestamp: DateTime.now(),
        ),
      ];

      when(mockLocalStorageService.set(any, any))
          .thenThrow(Exception(TestConstants.databaseErrorMessage));

      // Act & Assert
      expect(
        () => storage.saveOperations(operations),
        throwsA(isA<Exception>()),
      );
      verify(mockLocalStorageService.set(any, any)).called(1);
    });

    test('should handle storage service errors during load', () async {
      // Arrange
      when(mockLocalStorageService.get(any))
          .thenThrow(Exception(TestConstants.databaseErrorMessage));

      // Act
      final result = await storage.loadOperations();

      // Assert
      expect(result, isA<List<SyncOperation>>());
      expect(result, isEmpty);
      verify(mockLocalStorageService.get(any)).called(1);
    });

    test('should work with large operation lists', () async {
      // Arrange
      final operations = List.generate(10, (index) {
        return SyncOperation(
          id: 'task-$index',
          type: SyncOperationType.create,
          task: TestDataFactory.createTask(id: 'task-$index'),
          retryCount: index % 3,
          timestamp: DateTime.now(),
        );
      });

      when(mockLocalStorageService.set(any, any))
          .thenAnswer((_) => Future.value(true));

      // Act
      await storage.saveOperations(operations);

      // Assert
      verify(mockLocalStorageService.set(any, any)).called(1);
    });

    test('should handle concurrent save operations', () async {
      // Arrange
      final operations1 = [
        SyncOperation(
          id: TestConstants.defaultTaskId,
          type: SyncOperationType.create,
          task: TestDataFactory.createTask(),
          retryCount: 0,
          timestamp: DateTime.now(),
        ),
      ];

      final operations2 = [
        SyncOperation(
          id: TestConstants.defaultTaskId2,
          type: SyncOperationType.update,
          task: TestDataFactory.createTask(id: TestConstants.defaultTaskId2),
          retryCount: 0,
          timestamp: DateTime.now(),
        ),
      ];

      when(mockLocalStorageService.set(any, any))
          .thenAnswer((_) => Future.value(true));

      // Act
      await Future.wait([
        storage.saveOperations(operations1),
        storage.saveOperations(operations2),
      ]);

      // Assert
      verify(mockLocalStorageService.set(any, any)).called(2);
    });

    test('should clear operations successfully', () async {
      // Arrange
      when(mockLocalStorageService.remove(any))
          .thenAnswer((_) => Future.value(true));

      // Act
      await storage.clearOperations();

      // Assert
      verify(mockLocalStorageService.remove(any)).called(1);
    });

    test('should handle clear operations error gracefully', () async {
      // Arrange
      when(mockLocalStorageService.remove(any))
          .thenThrow(Exception(TestConstants.defaultErrorMessage));

      // Act & Assert
      expect(
        () => storage.clearOperations(),
        throwsA(isA<Exception>()),
      );
      verify(mockLocalStorageService.remove(any)).called(1);
    });
  });
}
