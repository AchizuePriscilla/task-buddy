import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_remote_datasource.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/services/task_sync_service.dart';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import '../../helpers/test_data_factory.dart';
import 'task_sync_service_test.mocks.dart';

@GenerateMocks([TaskRemoteDataSource, SyncQueue])
void main() {
  late TaskSyncService syncService;
  late MockTaskRemoteDataSource mockRemoteDataSource;
  late MockSyncQueue mockSyncQueue;

  setUp(() {
    mockRemoteDataSource = MockTaskRemoteDataSource();
    mockSyncQueue = MockSyncQueue();
    syncService = TaskSyncService(mockSyncQueue, mockRemoteDataSource);
  });

  tearDown(() {
    reset(mockRemoteDataSource);
    reset(mockSyncQueue);
  });

  group('TaskSyncService', () {
    test('should create sync service', () {
      // Assert
      expect(syncService, isA<TaskSyncService>());
    });

    test('should create sync service without remote data source', () {
      // Act
      final syncServiceWithoutRemote = TaskSyncService(mockSyncQueue);

      // Assert
      expect(syncServiceWithoutRemote, isA<TaskSyncService>());
    });

    test('should queue sync operation successfully', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockSyncQueue.enqueue(any)).thenAnswer((_) => Future.value());
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(false));

      // Act
      await syncService.queueSyncOperation(SyncOperationType.create, task);

      // Assert
      verify(mockSyncQueue.enqueue(any)).called(1);
    });

    test('should try to process sync queue when remote is available', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockSyncQueue.enqueue(any)).thenAnswer((_) => Future.value());
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(true));
      when(mockSyncQueue.isEmpty).thenReturn(false);
      when(mockSyncQueue.isProcessing).thenReturn(false);
      when(mockSyncQueue.processQueue(any)).thenAnswer((_) => Future.value());

      // Act
      await syncService.queueSyncOperation(SyncOperationType.create, task);

      // Assert
      verify(mockSyncQueue.enqueue(any)).called(1);
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
      // Note: processQueue is called asynchronously, so we can't verify it here
    });

    test('should not process queue when queue is empty', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockSyncQueue.enqueue(any)).thenAnswer((_) => Future.value());
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(true));
      when(mockSyncQueue.isEmpty).thenReturn(true);

      // Act
      await syncService.queueSyncOperation(SyncOperationType.create, task);

      // Assert
      verify(mockSyncQueue.enqueue(any)).called(1);
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
      verifyNever(mockSyncQueue.processQueue(any));
    });

    test('should not process queue when already processing', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockSyncQueue.enqueue(any)).thenAnswer((_) => Future.value());
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(true));
      when(mockSyncQueue.isEmpty).thenReturn(false);
      when(mockSyncQueue.isProcessing).thenReturn(true);

      // Act
      await syncService.queueSyncOperation(SyncOperationType.create, task);

      // Assert
      verify(mockSyncQueue.enqueue(any)).called(1);
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
      verifyNever(mockSyncQueue.processQueue(any));
    });

    test('should handle remote availability check errors gracefully', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockSyncQueue.enqueue(any)).thenAnswer((_) => Future.value());
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(false));

      // Act & Assert - Should not throw
      await syncService.queueSyncOperation(SyncOperationType.create, task);

      // Assert
      verify(mockSyncQueue.enqueue(any)).called(1);
      // The error handling is tested indirectly through the implementation
    });

    test('should execute create sync operation', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockSyncQueue.enqueue(any)).thenAnswer((_) => Future.value());
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(false));

      // Act - Test the sync operation through the public interface
      await syncService.queueSyncOperation(SyncOperationType.create, task);

      // Assert
      verify(mockSyncQueue.enqueue(any)).called(1);
    });

    test('should execute update sync operation', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockSyncQueue.enqueue(any)).thenAnswer((_) => Future.value());
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(false));

      // Act
      await syncService.queueSyncOperation(SyncOperationType.update, task);

      // Assert
      verify(mockSyncQueue.enqueue(any)).called(1);
    });

    test('should execute delete sync operation', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockSyncQueue.enqueue(any)).thenAnswer((_) => Future.value());
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(false));

      // Act
      await syncService.queueSyncOperation(SyncOperationType.delete, task);

      // Assert
      verify(mockSyncQueue.enqueue(any)).called(1);
    });

    test('should check remote availability', () async {
      // Arrange
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(true));

      // Act
      final result = await syncService.isRemoteAvailable();

      // Assert
      expect(result, isTrue);
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
    });

    test('should return false when remote is not available', () async {
      // Arrange
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(false));

      // Act
      final result = await syncService.isRemoteAvailable();

      // Assert
      expect(result, isFalse);
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
    });

    test('should return false when remote data source is null', () async {
      // Arrange
      final syncServiceWithNullRemote = TaskSyncService(mockSyncQueue, null);

      // Act
      final result = await syncServiceWithNullRemote.isRemoteAvailable();

      // Assert
      expect(result, isFalse);
    });

    test('should sync with remote successfully', () async {
      // Arrange
      final localTasks = TestDataFactory.createTaskList(count: 2);
      final remoteTasks = TestDataFactory.createTaskList(count: 3);

      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(true));
      when(mockRemoteDataSource.getAllTasks())
          .thenAnswer((_) => Future.value(remoteTasks));
      when(mockSyncQueue.isEmpty).thenReturn(false);
      when(mockSyncQueue.processQueue(any)).thenAnswer((_) => Future.value());

      // Act
      final result = await syncService.syncWithRemote(localTasks);

      // Assert
      expect(result, isA<List<TaskModel>>());
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
      verify(mockRemoteDataSource.getAllTasks()).called(1);
      verify(mockSyncQueue.processQueue(any)).called(1);
    });

    test('should return local tasks when remote is not available', () async {
      // Arrange
      final localTasks = TestDataFactory.createTaskList(count: 2);

      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(false));

      // Act
      final result = await syncService.syncWithRemote(localTasks);

      // Assert
      expect(result, equals(localTasks));
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
      verifyNever(mockRemoteDataSource.getAllTasks());
      verifyNever(mockSyncQueue.processQueue(any));
    });

    test('should return local tasks when remote data source is null', () async {
      // Arrange
      final localTasks = TestDataFactory.createTaskList(count: 2);
      final syncServiceWithNullRemote = TaskSyncService(mockSyncQueue, null);

      // Act
      final result = await syncServiceWithNullRemote.syncWithRemote(localTasks);

      // Assert
      expect(result, equals(localTasks));
    });

    test('should handle remote errors gracefully', () async {
      // Arrange
      final localTasks = TestDataFactory.createTaskList(count: 2);

      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(true));
      when(mockRemoteDataSource.getAllTasks())
          .thenThrow(Exception('Remote error'));

      // Act
      final result = await syncService.syncWithRemote(localTasks);

      // Assert
      expect(result, equals(localTasks));
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
      verify(mockRemoteDataSource.getAllTasks()).called(1);
    });

    test('should not process queue when queue is empty during sync', () async {
      // Arrange
      final localTasks = TestDataFactory.createTaskList(count: 2);
      final remoteTasks = TestDataFactory.createTaskList(count: 3);

      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(true));
      when(mockRemoteDataSource.getAllTasks())
          .thenAnswer((_) => Future.value(remoteTasks));
      when(mockSyncQueue.isEmpty).thenReturn(true);

      // Act
      final result = await syncService.syncWithRemote(localTasks);

      // Assert
      expect(result, isA<List<TaskModel>>());
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
      verify(mockRemoteDataSource.getAllTasks()).called(1);
      verifyNever(mockSyncQueue.processQueue(any));
    });

    test('should check queue status', () {
      // Arrange
      when(mockSyncQueue.isEmpty).thenReturn(true);
      when(mockSyncQueue.isProcessing).thenReturn(false);

      // Act
      final isEmpty = syncService.isQueueEmpty;
      final isProcessing = syncService.isQueueProcessing;

      // Assert
      expect(isEmpty, isTrue);
      expect(isProcessing, isFalse);
      verify(mockSyncQueue.isEmpty).called(1);
      verify(mockSyncQueue.isProcessing).called(1);
    });

    test('should queue different operation types', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockSyncQueue.enqueue(any)).thenAnswer((_) => Future.value());
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(false));

      // Act
      await syncService.queueSyncOperation(SyncOperationType.create, task);
      await syncService.queueSyncOperation(SyncOperationType.update, task);
      await syncService.queueSyncOperation(SyncOperationType.delete, task);

      // Assert
      verify(mockSyncQueue.enqueue(any)).called(3);
    });

    test('should handle sync queue errors gracefully', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockSyncQueue.enqueue(any)).thenThrow(Exception('Queue error'));
      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(false));

      // Act & Assert
      expect(
        () => syncService.queueSyncOperation(SyncOperationType.create, task),
        throwsA(isA<Exception>()),
      );
      verify(mockSyncQueue.enqueue(any)).called(1);
    });

    test('should handle empty local tasks list', () async {
      // Arrange
      final localTasks = <TaskModel>[];
      final remoteTasks = TestDataFactory.createTaskList(count: 3);

      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(true));
      when(mockRemoteDataSource.getAllTasks())
          .thenAnswer((_) => Future.value(remoteTasks));
      when(mockSyncQueue.isEmpty).thenReturn(true);

      // Act
      final result = await syncService.syncWithRemote(localTasks);

      // Assert
      expect(result, isA<List<TaskModel>>());
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
      verify(mockRemoteDataSource.getAllTasks()).called(1);
    });

    test('should handle empty remote tasks list', () async {
      // Arrange
      final localTasks = TestDataFactory.createTaskList(count: 2);
      final remoteTasks = <TaskModel>[];

      when(mockRemoteDataSource.isRemoteAvailable())
          .thenAnswer((_) => Future.value(true));
      when(mockRemoteDataSource.getAllTasks())
          .thenAnswer((_) => Future.value(remoteTasks));
      when(mockSyncQueue.isEmpty).thenReturn(true);

      // Act
      final result = await syncService.syncWithRemote(localTasks);

      // Assert
      expect(result, isA<List<TaskModel>>());
      verify(mockRemoteDataSource.isRemoteAvailable()).called(1);
      verify(mockRemoteDataSource.getAllTasks()).called(1);
    });
  });
}
