import 'package:flutter_test/flutter_test.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/services/task_filter_service.dart';
import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factory.dart';

void main() {
  group('TaskFilterService', () {
    late TaskFilterService filterService;
    late List<TaskModel> testTasks;

    setUp(() {
      filterService = TaskFilterService();
      testTasks = [
        TestDataFactory.createTask(
          id: TestConstants.defaultTaskId,
          title: 'Work Task',
          description: 'Important work task',
          category: CategoryEnum.work,
          priority: Priority.high,
          dueDate: TestConstants.defaultDueDate,
        ),
        TestDataFactory.createTask(
          id: TestConstants.defaultTaskId2,
          title: 'Personal Task',
          description: 'Personal todo',
          category: CategoryEnum.personal,
          priority: Priority.medium,
          dueDate: DateTime.now().add(const Duration(days: 2)),
          isCompleted: true,
        ),
        TestDataFactory.createTask(
          id: TestConstants.defaultTaskId3,
          title: 'Home Task',
          description: 'Buy groceries',
          category: CategoryEnum.home,
          priority: Priority.low,
          dueDate: TestConstants.pastDueDate,
        ),
        TestDataFactory.createTask(
          id: '4',
          title: 'Another Work Task',
          description: 'Another important task',
          category: CategoryEnum.work,
          priority: Priority.urgent,
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
      ];
    });

    group('filterTasks', () {
      test('should return all tasks when no filters applied', () {
        // Act
        final result = filterService.filterTasks(tasks: testTasks);

        // Assert
        expect(result.length, equals(4));
        expect(result, equals(testTasks));
      });

      test('should filter by search query in title', () {
        // Act
        final result = filterService.filterTasks(
          tasks: testTasks,
          searchQuery: 'Work',
        );

        // Assert
        expect(result.length, equals(2));
        expect(result.every((task) => task.title.contains('Work')), isTrue);
      });

      test('should filter by search query in description', () {
        // Act
        final result = filterService.filterTasks(
          tasks: testTasks,
          searchQuery: 'important',
        );

        // Assert
        expect(result.length, equals(2));
        expect(
            result.every((task) =>
                task.description?.toLowerCase().contains('important') ?? false),
            isTrue);
      });

      test('should filter by category', () {
        // Act
        final result = filterService.filterTasks(
          tasks: testTasks,
          category: CategoryEnum.work,
        );

        // Assert
        expect(result.length, equals(2));
        expect(
            result.every((task) => task.category == CategoryEnum.work), isTrue);
      });

      test('should filter by priority', () {
        // Act
        final result = filterService.filterTasks(
          tasks: testTasks,
          priority: Priority.high,
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first.priority, equals(Priority.high));
      });

      test('should filter by completion status', () {
        // Act
        final result = filterService.filterTasks(
          tasks: testTasks,
          isCompleted: false,
        );

        // Assert
        expect(result.length, equals(3));
        expect(result.every((task) => !task.isCompleted), isTrue);
      });

      test('should filter by due date range', () {
        // Arrange
        final fromDate = DateTime.now();
        final toDate = DateTime.now().add(const Duration(days: 2));

        // Act
        final result = filterService.filterTasks(
          tasks: testTasks,
          dueDateFrom: fromDate,
          dueDateTo: toDate,
        );

        // Assert
        expect(result.length, equals(2));
        expect(
            result.every((task) =>
                task.dueDate
                    .isAfter(fromDate.subtract(const Duration(seconds: 1))) &&
                task.dueDate.isBefore(toDate.add(const Duration(seconds: 1)))),
            isTrue);
      });

      test('should combine multiple filters', () {
        // Act
        final result = filterService.filterTasks(
          tasks: testTasks,
          category: CategoryEnum.work,
          priority: Priority.high,
          isCompleted: false,
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first.category, equals(CategoryEnum.work));
        expect(result.first.priority, equals(Priority.high));
        expect(result.first.isCompleted, isFalse);
      });

      test('should return empty list when no tasks match filters', () {
        // Act
        final result = filterService.filterTasks(
          tasks: testTasks,
          category: CategoryEnum.work,
          priority: Priority.low,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getOverdueTasks', () {
      test('should return only overdue incomplete tasks', () {
        // Act
        final result = filterService.getOverdueTasks(testTasks);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals(TestConstants.defaultTaskId3));
        expect(result.first.isCompleted, isFalse);
        expect(result.first.dueDate.isBefore(DateTime.now()), isTrue);
      });

      test('should not return completed overdue tasks', () {
        // Arrange
        final completedOverdueTask = TestDataFactory.createTask(
          id: '5',
          dueDate: TestConstants.pastDueDate,
          isCompleted: true,
        );
        final tasksWithCompleted = [...testTasks, completedOverdueTask];

        // Act
        final result = filterService.getOverdueTasks(tasksWithCompleted);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals(TestConstants.defaultTaskId3));
      });
    });

    group('getTasksDueToday', () {
      test('should return tasks due today', () {
        // Arrange - Create a task due today
        final todayTask = TestDataFactory.createTask(
          id: '5',
          title: 'Today Task',
          dueDate: DateTime.now(),
          isCompleted: false,
        );
        final tasksWithToday = [...testTasks, todayTask];

        // Act
        final result = filterService.getTasksDueToday(tasksWithToday);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals('5'));
        expect(result.first.dueDate.day, equals(DateTime.now().day));
        expect(result.first.dueDate.month, equals(DateTime.now().month));
        expect(result.first.dueDate.year, equals(DateTime.now().year));
      });
    });

    group('getTasksDueOn', () {
      test('should return tasks due on specific date', () {
        // Arrange
        final specificDate = DateTime.now().add(const Duration(days: 1));

        // Act
        final result = filterService.getTasksDueOn(specificDate, testTasks);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals(TestConstants.defaultTaskId));
        expect(result.first.dueDate.day, equals(specificDate.day));
        expect(result.first.dueDate.month, equals(specificDate.month));
        expect(result.first.dueDate.year, equals(specificDate.year));
      });
    });

    group('getTaskCounts', () {
      test('should return correct task counts', () {
        // Act
        final result = filterService.getTaskCounts(testTasks);

        // Assert
        expect(result['total'], equals(4));
        expect(result['completed'], equals(1));
        expect(result['pending'], equals(3));
        expect(result['overdue'], equals(1));
        expect(result['dueToday'], equals(1));
      });

      test('should handle empty task list', () {
        // Act
        final result = filterService.getTaskCounts([]);

        // Assert
        expect(result['total'], equals(0));
        expect(result['completed'], equals(0));
        expect(result['pending'], equals(0));
        expect(result['overdue'], equals(0));
        expect(result['dueToday'], equals(0));
      });
    });
  });
}
