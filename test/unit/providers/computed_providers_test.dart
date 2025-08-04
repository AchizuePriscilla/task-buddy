import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/services/task_filter_service.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_filter_service_provider.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/domain/services/smart_priority_service.dart';
import 'package:task_buddy/features/task_management/domain/services/user_analytics_service.dart';
import 'package:task_buddy/features/task_management/presentation/providers/computed_providers.dart';
import 'package:task_buddy/features/task_management/presentation/providers/task_state_provider.dart';
import 'package:task_buddy/features/task_management/presentation/providers/filter_state_provider.dart';
import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factory.dart';

@GenerateMocks([
  TaskFilterService,
  TaskRepository,
  SmartPriorityService,
  UserAnalyticsService,
])
import 'computed_providers_test.mocks.dart';

void main() {
  group('Computed Providers', () {
    late ProviderContainer container;
    late MockTaskFilterService mockFilterService;

    setUp(() {
      mockFilterService = MockTaskFilterService();
      container = ProviderContainer(
        overrides: [
          taskFilterServiceProvider.overrideWithValue(mockFilterService),
          // Override taskStateProvider to avoid database dependency
          taskStateProvider.overrideWith((ref) => TaskStateNotifier(
                MockTaskRepository(),
                MockSmartPriorityService(),
                MockUserAnalyticsService(),
              )),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('filteredTasksProvider', () {
      test('should return filtered tasks based on current state', () {
        // Arrange
        final tasks = [
          TestDataFactory.createTask(
              id: '1', title: 'Work Task', category: CategoryEnum.work),
          TestDataFactory.createTask(
              id: '2', title: 'Personal Task', category: CategoryEnum.personal),
        ];
        final filteredTasks = [tasks.first];

        // Set up task state
        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        // Set up filter state
        container
            .read(filterStateProvider.notifier)
            .setCategory(CategoryEnum.work);

        when(mockFilterService.filterTasks(
          tasks: tasks,
          searchQuery: '',
          category: CategoryEnum.work,
          priority: null,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).thenReturn(filteredTasks);

        // Act
        final result = container.read(filteredTasksProvider);

        // Assert
        expect(result, equals(filteredTasks));
        verify(mockFilterService.filterTasks(
          tasks: tasks,
          searchQuery: '',
          category: CategoryEnum.work,
          priority: null,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).called(1);
      });

      test('should return empty list when no tasks exist', () {
        // Arrange
        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: []);

        when(mockFilterService.filterTasks(
          tasks: [],
          searchQuery: '',
          category: null,
          priority: null,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).thenReturn([]);

        // Act
        final result = container.read(filteredTasksProvider);

        // Assert
        expect(result, isEmpty);
      });

      test('should apply multiple filters', () {
        // Arrange
        final tasks = [
          TestDataFactory.createTask(
              id: '1',
              title: 'High Priority Work Task',
              category: CategoryEnum.work,
              priority: Priority.high),
          TestDataFactory.createTask(
              id: '2',
              title: 'Low Priority Personal Task',
              category: CategoryEnum.personal,
              priority: Priority.low),
        ];
        final filteredTasks = [tasks.first];

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        container.read(filterStateProvider.notifier)
          ..setCategory(CategoryEnum.work)
          ..setPriority(Priority.high)
          ..setSearchQuery('High');

        when(mockFilterService.filterTasks(
          tasks: tasks,
          searchQuery: 'High',
          category: CategoryEnum.work,
          priority: Priority.high,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).thenReturn(filteredTasks);

        // Act
        final result = container.read(filteredTasksProvider);

        // Assert
        expect(result, equals(filteredTasks));
        verify(mockFilterService.filterTasks(
          tasks: tasks,
          searchQuery: 'High',
          category: CategoryEnum.work,
          priority: Priority.high,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).called(1);
      });
    });

    group('taskCountsProvider', () {
      test('should return task counts for all categories', () {
        // Arrange
        final tasks = [
          TestDataFactory.createTask(
              id: '1', title: 'Work Task', category: CategoryEnum.work),
          TestDataFactory.createTask(
              id: '2', title: 'Personal Task', category: CategoryEnum.personal),
          TestDataFactory.createTask(
              id: '3', title: 'Another Work Task', category: CategoryEnum.work),
        ];
        final expectedCounts = {
          'work': 2,
          'personal': 1,
          'shopping': 0,
          'health': 0,
          'education': 0,
        };

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        when(mockFilterService.getTaskCounts(tasks)).thenReturn(expectedCounts);

        // Act
        final result = container.read(taskCountsProvider);

        // Assert
        expect(result, equals(expectedCounts));
        verify(mockFilterService.getTaskCounts(tasks)).called(1);
      });

      test('should return zero counts when no tasks exist', () {
        // Arrange
        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: []);

        final expectedCounts = {
          'work': 0,
          'personal': 0,
          'shopping': 0,
          'health': 0,
          'education': 0,
        };

        when(mockFilterService.getTaskCounts([])).thenReturn(expectedCounts);

        // Act
        final result = container.read(taskCountsProvider);

        // Assert
        expect(result, equals(expectedCounts));
        verify(mockFilterService.getTaskCounts([])).called(1);
      });
    });

    group('overdueTasksProvider', () {
      test('should return overdue tasks', () {
        // Arrange
        final tasks = [
          TestDataFactory.createTask(
              id: '1',
              title: 'Overdue Task',
              dueDate: TestConstants.pastDueDate),
          TestDataFactory.createTask(
              id: '2',
              title: 'Future Task',
              dueDate: TestConstants.defaultDueDate),
        ];
        final overdueTasks = [tasks.first];

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        when(mockFilterService.getOverdueTasks(tasks)).thenReturn(overdueTasks);

        // Act
        final result = container.read(overdueTasksProvider);

        // Assert
        expect(result, equals(overdueTasks));
        verify(mockFilterService.getOverdueTasks(tasks)).called(1);
      });

      test('should return empty list when no overdue tasks', () {
        // Arrange
        final tasks = [
          TestDataFactory.createTask(
              id: '1',
              title: 'Future Task',
              dueDate: TestConstants.defaultDueDate),
        ];

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        when(mockFilterService.getOverdueTasks(tasks)).thenReturn([]);

        // Act
        final result = container.read(overdueTasksProvider);

        // Assert
        expect(result, isEmpty);
        verify(mockFilterService.getOverdueTasks(tasks)).called(1);
      });
    });

    group('tasksDueTodayProvider', () {
      test('should return tasks due today', () {
        // Arrange
        final tasks = [
          TestDataFactory.createTask(
              id: '1', title: 'Today Task', dueDate: DateTime.now()),
          TestDataFactory.createTask(
              id: '2',
              title: 'Tomorrow Task',
              dueDate: TestConstants.defaultDueDate),
        ];
        final todayTasks = [tasks.first];

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        when(mockFilterService.getTasksDueToday(tasks)).thenReturn(todayTasks);

        // Act
        final result = container.read(tasksDueTodayProvider);

        // Assert
        expect(result, equals(todayTasks));
        verify(mockFilterService.getTasksDueToday(tasks)).called(1);
      });

      test('should return empty list when no tasks due today', () {
        // Arrange
        final tasks = [
          TestDataFactory.createTask(
              id: '1',
              title: 'Tomorrow Task',
              dueDate: TestConstants.defaultDueDate),
        ];

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        when(mockFilterService.getTasksDueToday(tasks)).thenReturn([]);

        // Act
        final result = container.read(tasksDueTodayProvider);

        // Assert
        expect(result, isEmpty);
        verify(mockFilterService.getTasksDueToday(tasks)).called(1);
      });
    });

    group('hasActiveFiltersProvider', () {
      test('should return true when filters are active', () {
        // Arrange
        container
            .read(filterStateProvider.notifier)
            .setCategory(CategoryEnum.work);

        // Act
        final result = container.read(hasActiveFiltersProvider);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when no filters are active', () {
        // Arrange
        // No filters set (default state)

        // Act
        final result = container.read(hasActiveFiltersProvider);

        // Assert
        expect(result, isFalse);
      });

      test('should return true when search query is active', () {
        // Arrange
        container.read(filterStateProvider.notifier).setSearchQuery('test');

        // Act
        final result = container.read(hasActiveFiltersProvider);

        // Assert
        expect(result, isTrue);
      });

      test('should return true when date range is active', () {
        // Arrange
        container
            .read(filterStateProvider.notifier)
            .setDateRange(DateTime(2024, 1, 1), DateTime(2024, 1, 31));

        // Act
        final result = container.read(hasActiveFiltersProvider);

        // Assert
        expect(result, isTrue);
      });
    });

    group('taskCompletionPercentageProvider', () {
      test('should return 0.0 when no tasks exist', () {
        // Arrange
        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: []);

        // Act
        final result = container.read(taskCompletionPercentageProvider);

        // Assert
        expect(result, equals(0.0));
      });

      test('should return 100.0 when all tasks are completed', () {
        // Arrange
        final tasks = [
          TestDataFactory.createCompletedTask(
              id: '1', title: 'Completed Task 1'),
          TestDataFactory.createCompletedTask(
              id: '2', title: 'Completed Task 2'),
        ];

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        // Act
        final result = container.read(taskCompletionPercentageProvider);

        // Assert
        expect(result, equals(100.0));
      });

      test('should return 50.0 when half of tasks are completed', () {
        // Arrange
        final tasks = [
          TestDataFactory.createCompletedTask(id: '1', title: 'Completed Task'),
          TestDataFactory.createTask(
              id: '2', title: 'Incomplete Task', isCompleted: false),
        ];

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        // Act
        final result = container.read(taskCompletionPercentageProvider);

        // Assert
        expect(result, equals(50.0));
      });

      test('should return 0.0 when no tasks are completed', () {
        // Arrange
        final tasks = [
          TestDataFactory.createTask(
              id: '1', title: 'Incomplete Task 1', isCompleted: false),
          TestDataFactory.createTask(
              id: '2', title: 'Incomplete Task 2', isCompleted: false),
        ];

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        // Act
        final result = container.read(taskCompletionPercentageProvider);

        // Assert
        expect(result, equals(0.0));
      });
    });

    group('Provider Reactivity', () {
      test('should update filtered tasks when task state changes', () {
        // Arrange
        final initialTasks = [
          TestDataFactory.createTask(id: '1', title: 'Initial Task')
        ];
        final newTasks = [
          TestDataFactory.createTask(id: '1', title: 'Initial Task'),
          TestDataFactory.createTask(id: '2', title: 'New Task'),
        ];

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: initialTasks);

        when(mockFilterService.filterTasks(
          tasks: initialTasks,
          searchQuery: '',
          category: null,
          priority: null,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).thenReturn(initialTasks);

        when(mockFilterService.filterTasks(
          tasks: newTasks,
          searchQuery: '',
          category: null,
          priority: null,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).thenReturn(newTasks);

        // Act - Read initial state
        final initialResult = container.read(filteredTasksProvider);

        // Update task state
        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: newTasks);

        // Read updated state
        final updatedResult = container.read(filteredTasksProvider);

        // Assert
        expect(initialResult, equals(initialTasks));
        expect(updatedResult, equals(newTasks));
        verify(mockFilterService.filterTasks(
          tasks: initialTasks,
          searchQuery: '',
          category: null,
          priority: null,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).called(1);
        verify(mockFilterService.filterTasks(
          tasks: newTasks,
          searchQuery: '',
          category: null,
          priority: null,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).called(1);
      });

      test('should update filtered tasks when filter state changes', () {
        // Arrange
        final tasks = [
          TestDataFactory.createTask(
              id: '1', title: 'Work Task', category: CategoryEnum.work),
          TestDataFactory.createTask(
              id: '2', title: 'Personal Task', category: CategoryEnum.personal),
        ];

        container.read(taskStateProvider.notifier).state = container
            .read(taskStateProvider.notifier)
            .state
            .copyWith(tasks: tasks);

        when(mockFilterService.filterTasks(
          tasks: tasks,
          searchQuery: '',
          category: null,
          priority: null,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).thenReturn(tasks);

        when(mockFilterService.filterTasks(
          tasks: tasks,
          searchQuery: '',
          category: CategoryEnum.work,
          priority: null,
          isCompleted: null,
          dueDateFrom: null,
          dueDateTo: null,
        )).thenReturn([tasks.first]);

        // Act - Read initial state
        final initialResult = container.read(filteredTasksProvider);

        // Update filter state
        container
            .read(filterStateProvider.notifier)
            .setCategory(CategoryEnum.work);

        // Read updated state
        final updatedResult = container.read(filteredTasksProvider);

        // Assert
        expect(initialResult, equals(tasks));
        expect(updatedResult, equals([tasks.first]));
      });
    });
  });
}
