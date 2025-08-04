import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_local_datasource.dart';
import 'package:task_buddy/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:task_buddy/features/task_management/domain/services/task_sync_service.dart';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import 'package:task_buddy/shared/domain/exceptions/database_exception.dart';
import 'package:task_buddy/shared/domain/exceptions/task_repository_exception.dart';
import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factory.dart';

// Generate mocks
@GenerateMocks([TaskLocalDataSource, TaskSyncService])
import 'task_repository_test.mocks.dart';

void main() {
  group('TaskRepositoryImpl', () {
    late TaskRepositoryImpl repository;
    late MockTaskLocalDataSource mockLocalDataSource;
    late MockTaskSyncService mockSyncService;

    setUp(() {
      mockLocalDataSource = MockTaskLocalDataSource();
      mockSyncService = MockTaskSyncService();
      repository = TaskRepositoryImpl(mockLocalDataSource, mockSyncService);
    });

    tearDown(() {
      reset(mockLocalDataSource);
      reset(mockSyncService);
    });

    group('createTask', () {
      test('should create task successfully', () async {
        // Arrange
        final task = TestDataFactory.createTask(id: '1');
        when(mockLocalDataSource.createTask(task))
            .thenAnswer((_) => Future.value());
        when(mockSyncService.queueSyncOperation(SyncOperationType.create, task))
            .thenAnswer((_) => Future.value());

        // Act
        await repository.createTask(task);

        // Assert
        verify(mockLocalDataSource.createTask(task)).called(1);
        verify(mockSyncService.queueSyncOperation(
                SyncOperationType.create, task))
            .called(1);
      });

      test('should throw TaskRepositoryException when local data source fails',
          () async {
        // Arrange
        final task = TestDataFactory.createTask(id: '1');
        when(mockLocalDataSource.createTask(task))
            .thenThrow(DatabaseException(TestConstants.databaseErrorMessage));

        // Act & Assert
        expect(
          () => repository.createTask(task),
          throwsA(isA<TaskRepositoryException>()),
        );
        verifyNoMoreInteractions(mockSyncService);
      });
    });

    group('getTaskById', () {
      test('should return task when found', () async {
        // Arrange
        final task = TestDataFactory.createTask(id: '1');
        when(mockLocalDataSource.getTaskById('1'))
            .thenAnswer((_) => Future.value(task));

        // Act
        final result = await repository.getTaskById('1');

        // Assert
        expect(result, equals(task));
        verify(mockLocalDataSource.getTaskById('1')).called(1);
      });

      test('should return null when task not found', () async {
        // Arrange
        when(mockLocalDataSource.getTaskById('1'))
            .thenAnswer((_) => Future.value(null));

        // Act
        final result = await repository.getTaskById('1');

        // Assert
        expect(result, isNull);
        verify(mockLocalDataSource.getTaskById('1')).called(1);
      });

      test('should throw TaskRepositoryException when data source fails',
          () async {
        // Arrange
        when(mockLocalDataSource.getTaskById('1'))
            .thenThrow(DatabaseException(TestConstants.databaseErrorMessage));

        // Act & Assert
        expect(
          () => repository.getTaskById('1'),
          throwsA(isA<TaskRepositoryException>()),
        );
      });
    });

    group('getAllTasks', () {
      test('should return all tasks successfully', () async {
        // Arrange
        final tasks = [
          TestDataFactory.createTask(id: '1'),
          TestDataFactory.createTask(id: '2'),
        ];
        when(mockLocalDataSource.getAllTasks())
            .thenAnswer((_) => Future.value(tasks));

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result, equals(tasks));
        verify(mockLocalDataSource.getAllTasks()).called(1);
      });

      test('should return empty list when no tasks exist', () async {
        // Arrange
        when(mockLocalDataSource.getAllTasks())
            .thenAnswer((_) => Future.value([]));

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result, isEmpty);
        verify(mockLocalDataSource.getAllTasks()).called(1);
      });

      test('should throw TaskRepositoryException when data source fails',
          () async {
        // Arrange
        when(mockLocalDataSource.getAllTasks())
            .thenThrow(DatabaseException(TestConstants.databaseErrorMessage));

        // Act & Assert
        expect(
          () => repository.getAllTasks(),
          throwsA(isA<TaskRepositoryException>()),
        );
      });
    });

    group('updateTask', () {
      test('should update task successfully', () async {
        // Arrange
        final task = TestDataFactory.createTask(id: '1');
        when(mockLocalDataSource.updateTask(task))
            .thenAnswer((_) => Future.value());
        when(mockSyncService.queueSyncOperation(SyncOperationType.update, task))
            .thenAnswer((_) => Future.value());

        // Act
        await repository.updateTask(task);

        // Assert
        verify(mockLocalDataSource.updateTask(task)).called(1);
        verify(mockSyncService.queueSyncOperation(
                SyncOperationType.update, task))
            .called(1);
      });

      test('should throw TaskRepositoryException when local data source fails',
          () async {
        // Arrange
        final task = TestDataFactory.createTask(id: '1');
        when(mockLocalDataSource.updateTask(task))
            .thenThrow(DatabaseException(TestConstants.databaseErrorMessage));

        // Act & Assert
        expect(
          () => repository.updateTask(task),
          throwsA(isA<TaskRepositoryException>()),
        );
        verifyNoMoreInteractions(mockSyncService);
      });
    });

    group('deleteTask', () {
      test('should delete task successfully', () async {
        // Arrange
        final task = TestDataFactory.createTask(id: '1');
        when(mockLocalDataSource.deleteTask(task))
            .thenAnswer((_) => Future.value());
        when(mockSyncService.queueSyncOperation(SyncOperationType.delete, task))
            .thenAnswer((_) => Future.value());

        // Act
        await repository.deleteTask(task);

        // Assert
        verify(mockLocalDataSource.deleteTask(task)).called(1);
        verify(mockSyncService.queueSyncOperation(
                SyncOperationType.delete, task))
            .called(1);
      });

      test('should throw TaskRepositoryException when local data source fails',
          () async {
        // Arrange
        final task = TestDataFactory.createTask(id: '1');
        when(mockLocalDataSource.deleteTask(task))
            .thenThrow(DatabaseException(TestConstants.databaseErrorMessage));

        // Act & Assert
        expect(
          () => repository.deleteTask(task),
          throwsA(isA<TaskRepositoryException>()),
        );
        verifyNoMoreInteractions(mockSyncService);
      });
    });
  });
}
