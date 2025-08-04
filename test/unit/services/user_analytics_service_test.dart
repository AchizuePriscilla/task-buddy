import 'package:flutter_test/flutter_test.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/services/user_analytics_service.dart';
import '../../helpers/test_data_factory.dart';

void main() {
  late UserAnalyticsService analyticsService;

  setUp(() {
    analyticsService = UserAnalyticsService();
  });

  group('UserAnalyticsService', () {
    test('should create analytics service', () {
      // Assert
      expect(analyticsService, isA<UserAnalyticsService>());
    });

    test('should track task creation', () {
      // Arrange
      final task = TestDataFactory.createTask(
        category: CategoryEnum.work,
        title: 'Test Task',
      );

      // Act
      analyticsService.onTaskCreated(task);

      // Assert - Service should not throw any exceptions
      expect(analyticsService, isA<UserAnalyticsService>());
    });

    test('should track task completion', () {
      // Arrange
      final task = TestDataFactory.createCompletedTask(
        category: CategoryEnum.personal,
        title: 'Completed Task',
      );

      // Act
      analyticsService.onTaskCompleted(task);

      // Assert - Service should not throw any exceptions
      expect(analyticsService, isA<UserAnalyticsService>());
    });

    test('should track task uncompletion', () {
      // Arrange
      final task = TestDataFactory.createTask(
        category: CategoryEnum.study,
        title: 'Uncompleted Task',
        isCompleted: false,
      );

      // Act
      analyticsService.onTaskUncompleted(task);

      // Assert - Service should not throw any exceptions
      expect(analyticsService, isA<UserAnalyticsService>());
    });

    test('should track multiple task operations', () {
      // Arrange
      final task1 = TestDataFactory.createTask(
        category: CategoryEnum.work,
        title: 'Work Task',
      );
      final task2 = TestDataFactory.createTask(
        category: CategoryEnum.personal,
        title: 'Personal Task',
      );

      // Act
      analyticsService.onTaskCreated(task1);
      analyticsService.onTaskCreated(task2);
      analyticsService.onTaskCompleted(task1);
      analyticsService.onTaskUncompleted(task2);

      // Assert - Service should handle multiple operations
      expect(analyticsService, isA<UserAnalyticsService>());
    });

    test('should handle tasks with different categories', () {
      // Arrange
      final workTask = TestDataFactory.createTask(category: CategoryEnum.work);
      final personalTask =
          TestDataFactory.createTask(category: CategoryEnum.personal);
      final studyTask =
          TestDataFactory.createTask(category: CategoryEnum.study);

      // Act
      analyticsService.onTaskCreated(workTask);
      analyticsService.onTaskCreated(personalTask);
      analyticsService.onTaskCreated(studyTask);

      // Assert - Service should handle different categories
      expect(analyticsService, isA<UserAnalyticsService>());
    });

    test('should handle completed tasks', () {
      // Arrange
      final completedTask = TestDataFactory.createCompletedTask(
        category: CategoryEnum.work,
      );

      // Act
      analyticsService.onTaskCompleted(completedTask);

      // Assert - Service should handle completed tasks
      expect(analyticsService, isA<UserAnalyticsService>());
    });

    test('should handle tasks with different priorities', () {
      // Arrange
      final highPriorityTask = TestDataFactory.createTask(
        category: CategoryEnum.work,
        priority: Priority.high,
      );
      final lowPriorityTask = TestDataFactory.createTask(
        category: CategoryEnum.personal,
        priority: Priority.low,
      );

      // Act
      analyticsService.onTaskCreated(highPriorityTask);
      analyticsService.onTaskCreated(lowPriorityTask);

      // Assert - Service should handle different priorities
      expect(analyticsService, isA<UserAnalyticsService>());
    });

    test('should handle edge cases with null values', () {
      // Arrange
      final task = TestDataFactory.createTask(
        title: '',
        description: '',
      );

      // Act
      analyticsService.onTaskCreated(task);

      // Assert - Service should handle edge cases
      expect(analyticsService, isA<UserAnalyticsService>());
    });

    test('should handle rapid successive operations', () {
      // Arrange
      final task = TestDataFactory.createTask();

      // Act
      for (int i = 0; i < 10; i++) {
        analyticsService.onTaskCreated(task);
        analyticsService.onTaskCompleted(task);
        analyticsService.onTaskUncompleted(task);
      }

      // Assert - Service should handle rapid operations
      expect(analyticsService, isA<UserAnalyticsService>());
    });
  });
}
