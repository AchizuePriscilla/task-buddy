import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_remote_datasource.dart';
import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factory.dart';

void main() {
  group('TaskRemoteDataSource', () {
    late TaskRemoteDataSource remoteDataSource;

    setUp(() {
      remoteDataSource = TaskRemoteDataSource();
    });
    group('CRUD Operations', () {
      test('should get all tasks successfully', () async {
        // Arrange
        final tasks = TestDataFactory.createTaskList(count: 3);
        when(remoteDataSource.getAllTasks())
            .thenAnswer((_) => Future.value(tasks));

        // Act
        final result = await remoteDataSource.getAllTasks();

        // Assert
        expect(result, equals(tasks));
        verify(remoteDataSource.getAllTasks()).called(1);
      });

      test('should get task by id successfully', () async {
        // Arrange
        final task = TestDataFactory.createTask();
        when(remoteDataSource.getTaskById(TestConstants.defaultTaskId))
            .thenAnswer((_) => Future.value(task));

        // Act
        final result =
            await remoteDataSource.getTaskById(TestConstants.defaultTaskId);

        // Assert
        expect(result, equals(task));
        verify(remoteDataSource.getTaskById(TestConstants.defaultTaskId))
            .called(1);
      });

      test('should create task successfully', () async {
        // Arrange
        final task = TestDataFactory.createTask();
        when(remoteDataSource.createTask(task))
            .thenAnswer((_) => Future.value());

        // Act
        await remoteDataSource.createTask(task);

        // Assert
        verify(remoteDataSource.createTask(task)).called(1);
      });

      test('should update task successfully', () async {
        // Arrange
        final task = TestDataFactory.createTask();
        when(remoteDataSource.updateTask(task))
            .thenAnswer((_) => Future.value());

        // Act
        await remoteDataSource.updateTask(task);

        // Assert
        verify(remoteDataSource.updateTask(task)).called(1);
      });

      test('should delete task successfully', () async {
        // Arrange
        final task = TestDataFactory.createTask();
        when(remoteDataSource.deleteTask(task))
            .thenAnswer((_) => Future.value());

        // Act
        await remoteDataSource.deleteTask(task);

        // Assert
        verify(remoteDataSource.deleteTask(task)).called(1);
      });

      test('should handle database errors when getting all tasks', () async {
        // Arrange
        when(remoteDataSource.getAllTasks())
            .thenThrow(Exception(TestConstants.databaseErrorMessage));

        // Act & Assert
        expect(
          () => remoteDataSource.getAllTasks(),
          throwsA(isA<Exception>()),
        );
        verify(remoteDataSource.getAllTasks()).called(1);
      });

      test('should handle database errors when getting task by id', () async {
        // Arrange
        when(remoteDataSource.getTaskById(TestConstants.defaultTaskId))
            .thenThrow(Exception(TestConstants.databaseErrorMessage));

        // Act & Assert
        expect(
          () => remoteDataSource.getTaskById(TestConstants.defaultTaskId),
          throwsA(isA<Exception>()),
        );
        verify(remoteDataSource.getTaskById(TestConstants.defaultTaskId))
            .called(1);
      });

      test('should handle database errors when creating task', () async {
        // Arrange
        final task = TestDataFactory.createTask();
        when(remoteDataSource.createTask(task))
            .thenThrow(Exception(TestConstants.databaseErrorMessage));

        // Act & Assert
        expect(
          () => remoteDataSource.createTask(task),
          throwsA(isA<Exception>()),
        );
        verify(remoteDataSource.createTask(task)).called(1);
      });

      test('should handle database errors when updating task', () async {
        // Arrange
        final task = TestDataFactory.createTask();
        when(remoteDataSource.updateTask(task))
            .thenThrow(Exception(TestConstants.databaseErrorMessage));

        // Act & Assert
        expect(
          () => remoteDataSource.updateTask(task),
          throwsA(isA<Exception>()),
        );
        verify(remoteDataSource.updateTask(task)).called(1);
      });

      test('should handle database errors when deleting task', () async {
        // Arrange
        final task = TestDataFactory.createTask();
        when(remoteDataSource.deleteTask(task))
            .thenThrow(Exception(TestConstants.databaseErrorMessage));

        // Act & Assert
        expect(
          () => remoteDataSource.deleteTask(task),
          throwsA(isA<Exception>()),
        );
        verify(remoteDataSource.deleteTask(task)).called(1);
      });
    });

    group('Remote Availability', () {
      test('should return false for isRemoteAvailable', () async {
        // Act
        final result = await remoteDataSource.isRemoteAvailable();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
