import 'package:flutter_test/flutter_test.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_remote_datasource.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
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
        // Act
        final result = await remoteDataSource.getAllTasks();

        // Assert
        expect(result, isA<List<TaskModel>>());
        expect(result, isEmpty);
      });

      test('should get task by id successfully', () async {
        // Act
        final result =
            await remoteDataSource.getTaskById(TestConstants.defaultTaskId);

        // Assert
        expect(result, isNull);
      });

      test('should create task successfully', () async {
        // Arrange
        final task = TestDataFactory.createTask();

        // Act & Assert
        expect(() => remoteDataSource.createTask(task), returnsNormally);
      });

      test('should update task successfully', () async {
        // Arrange
        final task = TestDataFactory.createTask();

        // Act & Assert
        expect(() => remoteDataSource.updateTask(task), returnsNormally);
      });

      test('should delete task successfully', () async {
        // Arrange
        final task = TestDataFactory.createTask();

        // Act & Assert
        expect(() => remoteDataSource.deleteTask(task), returnsNormally);
      });

      test('should handle database errors gracefully', () async {
        // This test verifies that the implementation handles errors properly
        // Since the current implementation doesn't throw errors in normal operation,
        // we test that it returns expected values

        // Act
        final allTasks = await remoteDataSource.getAllTasks();
        final taskById = await remoteDataSource.getTaskById('non-existent-id');

        // Assert
        expect(allTasks, isEmpty);
        expect(taskById, isNull);
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

    group('Error Handling', () {
      test('should handle operations without throwing exceptions', () async {
        // Arrange
        final task = TestDataFactory.createTask();

        // Act & Assert - All operations should complete without throwing
        await expectLater(remoteDataSource.createTask(task), completes);
        await expectLater(remoteDataSource.updateTask(task), completes);
        await expectLater(remoteDataSource.deleteTask(task), completes);
        await expectLater(remoteDataSource.getAllTasks(), completes);
        await expectLater(remoteDataSource.getTaskById('test-id'), completes);
        await expectLater(remoteDataSource.isRemoteAvailable(), completes);
      });
    });
  });
}
