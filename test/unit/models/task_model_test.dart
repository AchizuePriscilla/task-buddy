import 'package:flutter_test/flutter_test.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';

void main() {
  group('TaskModel', () {
    late DateTime testDate;
    late TaskModel testTask;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testTask = TaskModel(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        category: CategoryEnum.work,
        dueDate: testDate,
        priority: Priority.high,
        isCompleted: false,
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    group('constructor', () {
      test('should create task with all required fields', () {
        // Assert
        expect(testTask.id, equals('test-id'));
        expect(testTask.title, equals('Test Task'));
        expect(testTask.description, equals('Test Description'));
        expect(testTask.category, equals(CategoryEnum.work));
        expect(testTask.dueDate, equals(testDate));
        expect(testTask.priority, equals(Priority.high));
        expect(testTask.isCompleted, isFalse);
        expect(testTask.createdAt, equals(testDate));
        expect(testTask.updatedAt, equals(testDate));
      });

      test(
          'should create task with default values when optional fields not provided',
          () {
        // Act
        final task = TaskModel(
          id: 'test-id',
          title: 'Test Task',
          category: CategoryEnum.work,
          dueDate: testDate,
          priority: Priority.medium,
        );

        // Assert
        expect(task.description, isNull);
        expect(task.isCompleted, isFalse);
        expect(task.createdAt, isNotNull);
        expect(task.updatedAt, isNotNull);
        expect(
            task.createdAt
                .isAfter(DateTime.now().subtract(const Duration(seconds: 1))),
            isTrue);
        expect(
            task.updatedAt
                .isAfter(DateTime.now().subtract(const Duration(seconds: 1))),
            isTrue);
      });
    });

    group('copyWith', () {
      test('should create new instance with updated fields', () {
        // Act
        final updatedTask = testTask.copyWith(
          title: 'Updated Task',
          isCompleted: true,
          priority: Priority.urgent,
        );

        // Assert
        expect(updatedTask.id, equals(testTask.id));
        expect(updatedTask.title, equals('Updated Task'));
        expect(updatedTask.description, equals(testTask.description));
        expect(updatedTask.category, equals(testTask.category));
        expect(updatedTask.dueDate, equals(testTask.dueDate));
        expect(updatedTask.priority, equals(Priority.urgent));
        expect(updatedTask.isCompleted, isTrue);
        expect(updatedTask.createdAt, equals(testTask.createdAt));
        expect(updatedTask.updatedAt.isAfter(testTask.updatedAt), isTrue);
      });

      test('should keep original values when fields not specified', () {
        // Act
        final updatedTask = testTask.copyWith(title: 'Updated Task');

        // Assert
        expect(updatedTask.id, equals(testTask.id));
        expect(updatedTask.title, equals('Updated Task'));
        expect(updatedTask.description, equals(testTask.description));
        expect(updatedTask.category, equals(testTask.category));
        expect(updatedTask.dueDate, equals(testTask.dueDate));
        expect(updatedTask.priority, equals(testTask.priority));
        expect(updatedTask.isCompleted, equals(testTask.isCompleted));
        expect(updatedTask.createdAt, equals(testTask.createdAt));
        expect(updatedTask.updatedAt.isAfter(testTask.updatedAt), isTrue);
      });
    });

    group('toJson', () {
      test('should convert task to JSON format', () {
        // Act
        final json = testTask.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['title'], equals('Test Task'));
        expect(json['description'], equals('Test Description'));
        expect(json['category'], equals('work'));
        expect(json['dueDate'], equals(testDate.toIso8601String()));
        expect(json['priority'], equals('high'));
        expect(json['isCompleted'], isFalse);
        expect(json['createdAt'], equals(testDate.toIso8601String()));
        expect(json['updatedAt'], equals(testDate.toIso8601String()));
      });
    });

    group('fromJson', () {
      test('should create task from JSON format', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'title': 'Test Task',
          'description': 'Test Description',
          'category': 'work',
          'dueDate': testDate.toIso8601String(),
          'priority': 'high',
          'isCompleted': false,
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
        };

        // Act
        final task = TaskModel.fromJson(json);

        // Assert
        expect(task.id, equals('test-id'));
        expect(task.title, equals('Test Task'));
        expect(task.description, equals('Test Description'));
        expect(task.category, equals(CategoryEnum.work));
        expect(task.dueDate, equals(testDate));
        expect(task.priority, equals(Priority.high));
        expect(task.isCompleted, isFalse);
        expect(task.createdAt, equals(testDate));
        expect(task.updatedAt, equals(testDate));
      });

      test('should handle null description in JSON', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'title': 'Test Task',
          'description': null,
          'category': 'work',
          'dueDate': testDate.toIso8601String(),
          'priority': 'high',
          'isCompleted': false,
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
        };

        // Act
        final task = TaskModel.fromJson(json);

        // Assert
        expect(task.description, isNull);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final task1 = TaskModel(
          id: 'test-id',
          title: 'Test Task',
          category: CategoryEnum.work,
          dueDate: testDate,
          priority: Priority.high,
          createdAt: testDate,
          updatedAt: testDate,
        );
        final task2 = TaskModel(
          id: 'test-id',
          title: 'Test Task',
          category: CategoryEnum.work,
          dueDate: testDate,
          priority: Priority.high,
          createdAt: testDate,
          updatedAt: testDate,
        );

        // Assert
        expect(task1, equals(task2));
        expect(task1.hashCode, equals(task2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final task1 = TaskModel(
          id: 'test-id-1',
          title: 'Test Task 1',
          category: CategoryEnum.work,
          dueDate: testDate,
          priority: Priority.high,
        );
        final task2 = TaskModel(
          id: 'test-id-2',
          title: 'Test Task 2',
          category: CategoryEnum.personal,
          dueDate: testDate,
          priority: Priority.low,
        );

        // Assert
        expect(task1, isNot(equals(task2)));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testTask.toString();

        // Assert
        expect(stringRepresentation, contains('test-id'));
        expect(stringRepresentation, contains('Test Task'));
        expect(stringRepresentation, contains('false'));
      });
    });
  });
}
