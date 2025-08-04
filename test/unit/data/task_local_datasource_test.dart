import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_local_datasource.dart';
import 'package:task_buddy/shared/data/local/database/database_service.dart';
import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factory.dart';

@GenerateMocks([DatabaseService])
import 'task_local_datasource_test.mocks.dart';

void main() {
  late TaskLocalDataSource dataSource;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    dataSource = TaskLocalDataSource(mockDatabaseService);
  });

  tearDown(() {
    reset(mockDatabaseService);
  });

  group('TaskLocalDataSource', () {
    test('should get all tasks successfully', () async {
      // Arrange
      final tasks = TestDataFactory.createTaskList(count: 3);
      when(mockDatabaseService.getAllTasks())
          .thenAnswer((_) => Future.value(tasks));

      // Act
      final result = await dataSource.getAllTasks();

      // Assert
      expect(result, equals(tasks));
      verify(mockDatabaseService.getAllTasks()).called(1);
    });

    test('should get task by id successfully', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockDatabaseService.getTask(TestConstants.defaultTaskId))
          .thenAnswer((_) => Future.value(task));

      // Act
      final result = await dataSource.getTaskById(TestConstants.defaultTaskId);

      // Assert
      expect(result, equals(task));
      verify(mockDatabaseService.getTask(TestConstants.defaultTaskId))
          .called(1);
    });

    test('should create task successfully', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockDatabaseService.saveTask(task))
          .thenAnswer((_) => Future.value());

      // Act
      await dataSource.createTask(task);

      // Assert
      verify(mockDatabaseService.saveTask(task)).called(1);
    });

    test('should update task successfully', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockDatabaseService.updateTask(task))
          .thenAnswer((_) => Future.value());

      // Act
      await dataSource.updateTask(task);

      // Assert
      verify(mockDatabaseService.updateTask(task)).called(1);
    });

    test('should delete task successfully', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockDatabaseService.deleteTask(task))
          .thenAnswer((_) => Future.value());

      // Act
      await dataSource.deleteTask(task);

      // Assert
      verify(mockDatabaseService.deleteTask(task)).called(1);
    });

    test('should handle database errors when getting all tasks', () async {
      // Arrange
      when(mockDatabaseService.getAllTasks())
          .thenThrow(Exception(TestConstants.databaseErrorMessage));

      // Act & Assert
      expect(
        () => dataSource.getAllTasks(),
        throwsA(isA<Exception>()),
      );
      verify(mockDatabaseService.getAllTasks()).called(1);
    });

    test('should handle database errors when getting task by id', () async {
      // Arrange
      when(mockDatabaseService.getTask(TestConstants.defaultTaskId))
          .thenThrow(Exception(TestConstants.databaseErrorMessage));

      // Act & Assert
      expect(
        () => dataSource.getTaskById(TestConstants.defaultTaskId),
        throwsA(isA<Exception>()),
      );
      verify(mockDatabaseService.getTask(TestConstants.defaultTaskId))
          .called(1);
    });

    test('should handle database errors when creating task', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockDatabaseService.saveTask(task))
          .thenThrow(Exception(TestConstants.databaseErrorMessage));

      // Act & Assert
      expect(
        () => dataSource.createTask(task),
        throwsA(isA<Exception>()),
      );
      verify(mockDatabaseService.saveTask(task)).called(1);
    });

    test('should handle database errors when updating task', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockDatabaseService.updateTask(task))
          .thenThrow(Exception(TestConstants.databaseErrorMessage));

      // Act & Assert
      expect(
        () => dataSource.updateTask(task),
        throwsA(isA<Exception>()),
      );
      verify(mockDatabaseService.updateTask(task)).called(1);
    });

    test('should handle database errors when deleting task', () async {
      // Arrange
      final task = TestDataFactory.createTask();
      when(mockDatabaseService.deleteTask(task))
          .thenThrow(Exception(TestConstants.databaseErrorMessage));

      // Act & Assert
      expect(
        () => dataSource.deleteTask(task),
        throwsA(isA<Exception>()),
      );
      verify(mockDatabaseService.deleteTask(task)).called(1);
    });
  });
}
