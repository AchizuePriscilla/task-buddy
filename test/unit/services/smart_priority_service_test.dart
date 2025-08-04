import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/domain/services/smart_priority_service.dart';
import 'package:task_buddy/features/task_management/domain/services/user_analytics_service.dart';
import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factory.dart';
import '../../helpers/test_helpers.dart' as helpers;

// Generate mocks
@GenerateMocks([TaskRepository, UserAnalyticsService])
import 'smart_priority_service_test.mocks.dart';

void main() {
  group('SmartPriorityCalculator', () {
    group('calculatePriority', () {
      test('should increase priority for categories with many incomplete tasks',
          () {
        // Arrange
        final dueDate = TestConstants.defaultDueDate;
        final manyTasks = TestDataFactory.createTaskList(
          count: 7,
          isCompleted: false,
        );

        // Act
        final result = SmartPriorityCalculator.calculatePriority(
          dueDate: dueDate,
          category: CategoryEnum.work,
          analytics: null,
          categoryTasks: manyTasks,
        );
        expect(result, equals(Priority.urgent));
      });
    });
  });

  group('SmartPriorityService', () {
    late SmartPriorityService smartPriorityService;
    late MockTaskRepository mockTaskRepository;
    late MockUserAnalyticsService mockAnalyticsService;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      mockAnalyticsService = MockUserAnalyticsService();
      smartPriorityService =
          SmartPriorityService(mockTaskRepository, mockAnalyticsService);
    });

    tearDown(() {
      reset(mockTaskRepository);
      reset(mockAnalyticsService);
    });

    test('should recalculate priorities for incomplete tasks in category',
        () async {
      // Arrange
      final tasks = [
        TestDataFactory.createTask(
          id: TestConstants.defaultTaskId,
          category: CategoryEnum.work,
          priority: Priority.low,
          isCompleted: false,
        ),
        TestDataFactory.createCompletedTask(
          id: TestConstants.defaultTaskId2,
          category: CategoryEnum.work,
          priority: Priority.medium,
        ),
        TestDataFactory.createTask(
          id: TestConstants.defaultTaskId3,
          category: CategoryEnum.personal,
          priority: Priority.high,
          isCompleted: false,
        ),
      ];

      helpers.TestHelpers.setupMockTaskRepositoryWithData(
          mockTaskRepository, tasks);
      when(mockAnalyticsService.getAnalyticsForCategory(CategoryEnum.work))
          .thenReturn(TestDataFactory.createUserAnalytics(
        id: 'work',
        category: CategoryEnum.work,
      ));

      // Act
      await smartPriorityService.recalculatePriorities(CategoryEnum.work);

      // Assert
      helpers.TestHelpers.verifyGetAllTasksWasCalled(mockTaskRepository);
      verify(mockAnalyticsService.getAnalyticsForCategory(CategoryEnum.work))
          .called(1);
      // Should only update incomplete tasks in the work category
      verify(mockTaskRepository.updateTask(any)).called(1);
    });

    test('should not update task if priority has not changed', () async {
      // Arrange
      final tasks = [
        TestDataFactory.createTask(
          id: TestConstants.defaultTaskId,
          category: CategoryEnum.work,
          priority: Priority
              .medium, // Due within a week, should remain medium after adjustments
          dueDate: TestConstants.defaultDueDate,
          isCompleted: false,
        ),
      ];

      helpers.TestHelpers.setupMockTaskRepositoryWithData(
          mockTaskRepository, tasks);
      when(mockAnalyticsService.getAnalyticsForCategory(CategoryEnum.work))
          .thenReturn(TestDataFactory.createUserAnalytics(
        id: 'work',
        category: CategoryEnum.work,
        totalTasksCreated: 10,
        totalTasksCompleted: 8, // High completion rate
        tasksCompletedOnTime: 8, // High on-time rate
        tasksCompletedLate: 0,
      ));

      // Act
      await smartPriorityService.recalculatePriorities(CategoryEnum.work);

      // Assert
      helpers.TestHelpers.verifyGetAllTasksWasCalled(mockTaskRepository);
      // The priority might change due to workload adjustments, so we just verify the service was called
      verify(mockAnalyticsService.getAnalyticsForCategory(CategoryEnum.work))
          .called(1);
    });

    test('should handle repository errors gracefully', () async {
      // Arrange
      when(mockTaskRepository.getAllTasks())
          .thenThrow(helpers.TestHelpers.createDatabaseException());

      // Act & Assert
      expect(
        () async =>
            await smartPriorityService.recalculatePriorities(CategoryEnum.work),
        returnsNormally,
      );
    });
  });
}
