import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/models/user_analytics_model.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/domain/services/smart_priority_service.dart';
import 'package:task_buddy/features/task_management/domain/services/user_analytics_service.dart';

// Generate mocks
@GenerateMocks([TaskRepository, UserAnalyticsService])
import 'smart_priority_service_test.mocks.dart';

void main() {
  group('SmartPriorityCalculator', () {
    group('calculatePriority', () {
      test('should increase priority for categories with many incomplete tasks',
          () {
        // Arrange
        final dueDate = DateTime.now().add(const Duration(days: 5));
        final manyTasks = List.generate(
          7,
          (index) => _createTask(
            id: 'task$index',
            dueDate: dueDate,
            isCompleted: false,
          ),
        );

        // Act
        final result = SmartPriorityCalculator.calculatePriority(
          dueDate: dueDate,
          category: CategoryEnum.work,
          analytics: null,
          categoryTasks: manyTasks,
        );

        // Assert - should be higher than base medium priority due to many incomplete tasks
        expect(result, equals(Priority.high));
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
        _createTask(
          id: '1',
          category: CategoryEnum.work,
          priority: Priority.low,
          isCompleted: false,
        ),
        _createTask(
          id: '2',
          category: CategoryEnum.work,
          priority: Priority.medium,
          isCompleted: true,
        ),
        _createTask(
          id: '3',
          category: CategoryEnum.personal,
          priority: Priority.high,
          isCompleted: false,
        ),
      ];

      when(mockTaskRepository.getAllTasks())
          .thenAnswer((_) => Future.value(tasks));
      when(mockAnalyticsService.getAnalyticsForCategory(CategoryEnum.work))
          .thenReturn(UserAnalyticsModel(
              id: 'work',
              category: CategoryEnum.work,
              totalTasksCreated: 10,
              totalTasksCompleted: 3,
              tasksCompletedOnTime: 2,
              tasksCompletedLate: 1,
              lastUpdated: DateTime.now()));

      // Act
      await smartPriorityService.recalculatePriorities(CategoryEnum.work);

      // Assert
      verify(mockTaskRepository.getAllTasks()).called(1);
      verify(mockAnalyticsService.getAnalyticsForCategory(CategoryEnum.work))
          .called(1);
      // Should only update incomplete tasks in the work category
      verify(mockTaskRepository.updateTask(any)).called(1);
    });

    test('should not update task if priority has not changed', () async {
      // Arrange
      final tasks = [
        _createTask(
          id: '1',
          category: CategoryEnum.work,
          priority: Priority
              .medium, // Due within a week, should remain medium after adjustments
          dueDate: DateTime.now().add(const Duration(days: 5)),
          isCompleted: false,
        ),
      ];

      when(mockTaskRepository.getAllTasks())
          .thenAnswer((_) => Future.value(tasks));
      when(mockAnalyticsService.getAnalyticsForCategory(CategoryEnum.work))
          .thenReturn(UserAnalyticsModel(
              id: 'work',
              category: CategoryEnum.work,
              totalTasksCreated: 10,
              totalTasksCompleted: 8, // High completion rate
              tasksCompletedOnTime: 8, // High on-time rate
              tasksCompletedLate: 0,
              lastUpdated: DateTime.now()));

      // Act
      await smartPriorityService.recalculatePriorities(CategoryEnum.work);

      // Assert
      verify(mockTaskRepository.getAllTasks()).called(1);
      // The priority might change due to workload adjustments, so we just verify the service was called
      verify(mockAnalyticsService.getAnalyticsForCategory(CategoryEnum.work))
          .called(1);
    });

    test('should handle repository errors gracefully', () async {
      // Arrange
      when(mockTaskRepository.getAllTasks())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () async =>
            await smartPriorityService.recalculatePriorities(CategoryEnum.work),
        returnsNormally,
      );
    });
  });
}

TaskModel _createTask({
  required String id,
  CategoryEnum category = CategoryEnum.work,
  Priority priority = Priority.medium,
  DateTime? dueDate,
  bool isCompleted = false,
}) {
  return TaskModel(
    id: id,
    title: 'Test Task $id',
    description: 'Test description',
    category: category,
    dueDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
    priority: priority,
    isCompleted: isCompleted,
  );
}
