import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/domain/services/smart_priority_service.dart';
import 'package:task_buddy/features/task_management/domain/services/user_analytics_service.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_repository_provider.dart';
import 'package:task_buddy/features/task_management/domain/providers/smart_priority_service_provider.dart';
import 'package:task_buddy/features/task_management/presentation/providers/task_state_provider.dart';
import 'package:task_buddy/shared/localization/strings.dart';

@GenerateMocks([
  TaskRepository,
  SmartPriorityService,
  UserAnalyticsService,
])
import 'task_state_provider_test.mocks.dart';

void main() {
  group('TaskState', () {
    group('copyWith', () {
      test('should create new state with updated tasks', () {
        // Arrange
        const initialState = TaskState();
        final tasks = [_createTask(id: '1', title: 'Test Task')];

        // Act
        final newState = initialState.copyWith(tasks: tasks);

        // Assert
        expect(newState.tasks, equals(tasks));
        expect(newState.isLoading, equals(initialState.isLoading));
        expect(newState.error, equals(initialState.error));
        expect(newState, isNot(same(initialState)));
      });

      test('should create new state with updated loading status', () {
        // Arrange
        const initialState = TaskState();

        // Act
        final newState = initialState.copyWith(isLoading: true);

        // Assert
        expect(newState.isLoading, isTrue);
        expect(newState.tasks, equals(initialState.tasks));
        expect(newState.error, equals(initialState.error));
        expect(newState, isNot(same(initialState)));
      });

      test('should create new state with updated error', () {
        // Arrange
        const initialState = TaskState();
        const errorMessage = 'Test error';

        // Act
        final newState = initialState.copyWith(error: errorMessage);

        // Assert
        expect(newState.error, equals(errorMessage));
        expect(newState.tasks, equals(initialState.tasks));
        expect(newState.isLoading, equals(initialState.isLoading));
        expect(newState, isNot(same(initialState)));
      });

      test('should create new state with multiple updates', () {
        // Arrange
        const initialState = TaskState();
        final tasks = [_createTask(id: '1', title: 'Test Task')];

        // Act
        final newState = initialState.copyWith(
          tasks: tasks,
          isLoading: true,
          error: 'Test error',
        );

        // Assert
        expect(newState.tasks, equals(tasks));
        expect(newState.isLoading, isTrue);
        expect(newState.error, equals('Test error'));
        expect(newState, isNot(same(initialState)));
      });
    });
  });

  group('TaskStateNotifier', () {
    late ProviderContainer container;
    late TaskStateNotifier notifier;
    late MockTaskRepository mockRepository;
    late MockSmartPriorityService mockSmartPriorityService;
    late MockUserAnalyticsService mockAnalyticsService;

    setUp(() {
      mockRepository = MockTaskRepository();
      mockSmartPriorityService = MockSmartPriorityService();
      mockAnalyticsService = MockUserAnalyticsService();

      container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
          smartPriorityServiceProvider
              .overrideWithValue(mockSmartPriorityService),
          userAnalyticsServiceProvider.overrideWithValue(mockAnalyticsService),
        ],
      );

      notifier = container.read(taskStateProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('should initialize with empty state', () {
        // Act
        final state = notifier.state;

        // Assert
        expect(state.tasks, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('loadTasks', () {
      test('should load tasks successfully', () async {
        // Arrange
        final tasks = [
          _createTask(id: '1', title: 'Task 1'),
          _createTask(id: '2', title: 'Task 2'),
        ];
        when(mockRepository.getAllTasks())
            .thenAnswer((_) => Future.value(tasks));

        // Act
        await notifier.loadTasks();

        // Assert
        expect(notifier.state.tasks, equals(tasks));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should handle loading state correctly', () async {
        // Arrange
        final tasks = [_createTask(id: '1', title: 'Task 1')];
        when(mockRepository.getAllTasks())
            .thenAnswer((_) => Future.value(tasks));

        // Act
        final future = notifier.loadTasks();

        // Assert - Check loading state immediately
        expect(notifier.state.isLoading, isTrue);
        expect(notifier.state.error, isNull);

        // Wait for completion
        await future;

        // Assert - Check final state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.tasks, equals(tasks));
      });

      test('should handle repository errors', () async {
        // Arrange
        const errorMessage = 'Database error';
        when(mockRepository.getAllTasks()).thenThrow(Exception(errorMessage));

        // Act
        await notifier.loadTasks();

        // Assert
        expect(notifier.state.tasks, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains(AppStrings.failedToLoadTasks));
        expect(notifier.state.error, contains(errorMessage));
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should clear previous error when loading starts', () async {
        // Arrange
        notifier.state = notifier.state.copyWith(error: 'Previous error');
        final tasks = [_createTask(id: '1', title: 'Task 1')];
        when(mockRepository.getAllTasks())
            .thenAnswer((_) => Future.value(tasks));

        // Act
        await notifier.loadTasks();

        // Assert
        expect(notifier.state.error, isNull);
        expect(notifier.state.tasks, equals(tasks));
      });
    });

    group('createTask', () {
      test('should create task successfully', () async {
        // Arrange
        final newTask = _createTask(id: '1', title: 'New Task');
        final existingTasks = [_createTask(id: '2', title: 'Existing Task')];
        final allTasks = [existingTasks.first, newTask];

        when(mockRepository.createTask(newTask))
            .thenAnswer((_) => Future.value());
        when(mockRepository.getAllTasks())
            .thenAnswer((_) => Future.value(allTasks));
        when(mockSmartPriorityService.onTaskCreated(newTask))
            .thenAnswer((_) => Future.value());

        // Act
        await notifier.createTask(newTask);

        // Assert
        expect(notifier.state.tasks, equals(allTasks));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        verify(mockRepository.createTask(newTask)).called(1);
        verify(mockSmartPriorityService.onTaskCreated(newTask)).called(1);
        verify(mockAnalyticsService.onTaskCreated(newTask)).called(1);
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should handle creation errors', () async {
        // Arrange
        final newTask = _createTask(id: '1', title: 'New Task');
        when(mockRepository.createTask(newTask))
            .thenThrow(Exception('Creation failed'));

        // Act
        await notifier.createTask(newTask);

        // Assert
        expect(notifier.state.tasks, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, equals(AppStrings.failedToCreateTask));
        verify(mockRepository.createTask(newTask)).called(1);
        verifyNever(mockSmartPriorityService.onTaskCreated(any));
        verifyNever(mockAnalyticsService.onTaskCreated(any));
      });

      test('should clear error when creation starts', () async {
        // Arrange
        notifier.state = notifier.state.copyWith(error: 'Previous error');
        final newTask = _createTask(id: '1', title: 'New Task');
        when(mockRepository.createTask(newTask))
            .thenAnswer((_) => Future.value());
        when(mockRepository.getAllTasks())
            .thenAnswer((_) => Future.value([newTask]));
        when(mockSmartPriorityService.onTaskCreated(newTask))
            .thenAnswer((_) => Future.value());

        // Act
        await notifier.createTask(newTask);

        // Assert
        expect(notifier.state.error, isNull);
      });
    });

    group('updateTask', () {
      test('should update task successfully', () async {
        // Arrange
        final originalTask =
            _createTask(id: '1', title: 'Original Task', isCompleted: false);
        final updatedTask =
            _createTask(id: '1', title: 'Updated Task', isCompleted: true);
        final allTasks = [updatedTask];

        notifier.state = notifier.state.copyWith(tasks: [originalTask]);

        when(mockRepository.updateTask(updatedTask))
            .thenAnswer((_) => Future.value());
        when(mockRepository.getAllTasks())
            .thenAnswer((_) => Future.value(allTasks));
        when(mockSmartPriorityService.onTaskUpdated(updatedTask))
            .thenAnswer((_) => Future.value());
        when(mockSmartPriorityService.onTaskCompleted(updatedTask))
            .thenAnswer((_) => Future.value());

        // Act
        await notifier.updateTask(updatedTask);

        // Assert
        expect(notifier.state.tasks, equals(allTasks));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        verify(mockRepository.updateTask(updatedTask)).called(1);
        verify(mockSmartPriorityService.onTaskUpdated(updatedTask)).called(1);
        verify(mockSmartPriorityService.onTaskCompleted(updatedTask)).called(1);
        verify(mockAnalyticsService.onTaskCompleted(updatedTask)).called(1);
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should handle task uncompletion', () async {
        // Arrange
        final originalTask =
            _createTask(id: '1', title: 'Task', isCompleted: true);
        final updatedTask =
            _createTask(id: '1', title: 'Task', isCompleted: false);
        final allTasks = [updatedTask];

        notifier.state = notifier.state.copyWith(tasks: [originalTask]);

        when(mockRepository.updateTask(updatedTask))
            .thenAnswer((_) => Future.value());
        when(mockRepository.getAllTasks())
            .thenAnswer((_) => Future.value(allTasks));
        when(mockSmartPriorityService.onTaskUpdated(updatedTask))
            .thenAnswer((_) => Future.value());

        // Act
        await notifier.updateTask(updatedTask);

        // Assert
        verify(mockSmartPriorityService.onTaskUpdated(updatedTask)).called(1);
        verifyNever(mockSmartPriorityService.onTaskCompleted(any));
        verify(mockAnalyticsService.onTaskUncompleted(updatedTask)).called(1);
        verifyNever(mockAnalyticsService.onTaskCompleted(any));
      });

      test('should handle update errors', () async {
        // Arrange
        final task = _createTask(id: '1', title: 'Task');
        notifier.state = notifier.state.copyWith(tasks: [task]);
        when(mockRepository.updateTask(task))
            .thenThrow(Exception('Update failed'));

        // Act
        await notifier.updateTask(task);

        // Assert
        expect(notifier.state.tasks, equals([task]));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, equals(AppStrings.failedToUpdateTask));
        verify(mockRepository.updateTask(task)).called(1);
        verifyNever(mockSmartPriorityService.onTaskUpdated(any));
      });

      test('should handle task not found error', () async {
        // Arrange
        final task = _createTask(id: '1', title: 'Task');
        notifier.state = notifier.state.copyWith(tasks: []); // Empty tasks list

        // Act
        await notifier.updateTask(task);

        // Assert
        expect(notifier.state.error, equals(AppStrings.failedToUpdateTask));
        verifyNever(mockRepository.updateTask(any));
      });
    });

    group('deleteTask', () {
      test('should delete task successfully', () async {
        // Arrange
        final taskToDelete = _createTask(id: '1', title: 'Task to Delete');
        final remainingTasks = [_createTask(id: '2', title: 'Remaining Task')];

        notifier.state = notifier.state
            .copyWith(tasks: [taskToDelete, remainingTasks.first]);

        when(mockRepository.deleteTask(taskToDelete))
            .thenAnswer((_) => Future.value());
        when(mockRepository.getAllTasks())
            .thenAnswer((_) => Future.value(remainingTasks));
        when(mockSmartPriorityService.onTaskUpdated(taskToDelete))
            .thenAnswer((_) => Future.value());

        // Act
        await notifier.deleteTask(taskToDelete);

        // Assert
        expect(notifier.state.tasks, equals(remainingTasks));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        verify(mockRepository.deleteTask(taskToDelete)).called(1);
        verify(mockSmartPriorityService.onTaskUpdated(taskToDelete)).called(1);
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should handle deletion errors', () async {
        // Arrange
        final task = _createTask(id: '1', title: 'Task');
        notifier.state = notifier.state.copyWith(tasks: [task]);
        when(mockRepository.deleteTask(task))
            .thenThrow(Exception('Deletion failed'));

        // Act
        await notifier.deleteTask(task);

        // Assert
        expect(notifier.state.tasks, equals([task]));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, equals(AppStrings.failedToDeleteTask));
        verify(mockRepository.deleteTask(task)).called(1);
        verifyNever(mockSmartPriorityService.onTaskUpdated(any));
      });
    });

    group('clearError', () {
      test('should clear error state', () {
        // Arrange
        notifier.state = notifier.state.copyWith(error: 'Test error');

        // Act
        notifier.clearError();

        // Assert
        expect(notifier.state.error, isNull);
      });

      test('should not affect other state properties', () {
        // Arrange
        final tasks = [_createTask(id: '1', title: 'Task')];
        notifier.state = notifier.state.copyWith(
          tasks: tasks,
          isLoading: true,
          error: 'Test error',
        );

        // Act
        notifier.clearError();

        // Assert
        expect(notifier.state.error, isNull);
        expect(notifier.state.tasks, equals(tasks));
        expect(notifier.state.isLoading, isTrue);
      });
    });

    group('Error Handling', () {
      test('should preserve tasks when operation fails', () async {
        // Arrange
        final existingTasks = [_createTask(id: '1', title: 'Existing Task')];
        notifier.state = notifier.state.copyWith(tasks: existingTasks);
        when(mockRepository.getAllTasks()).thenThrow(Exception('Load failed'));

        // Act
        await notifier.loadTasks();

        // Assert
        expect(notifier.state.tasks, equals(existingTasks));
        expect(notifier.state.error, isNotNull);
      });

      test('should handle multiple consecutive errors', () async {
        // Arrange
        final task = _createTask(id: '1', title: 'Task');
        when(mockRepository.createTask(task))
            .thenThrow(Exception('Create failed'));
        when(mockRepository.updateTask(task))
            .thenThrow(Exception('Update failed'));

        // Act
        await notifier.createTask(task);
        await notifier.updateTask(task);

        // Assert
        expect(notifier.state.error, equals(AppStrings.failedToUpdateTask));
        expect(notifier.state.isLoading, isFalse);
      });
    });
  });
}

TaskModel _createTask({
  required String id,
  String title = 'Test Task',
  String? description,
  CategoryEnum category = CategoryEnum.work,
  Priority priority = Priority.medium,
  DateTime? dueDate,
  bool isCompleted = false,
}) {
  return TaskModel(
    id: id,
    title: title,
    description: description,
    category: category,
    dueDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
    priority: priority,
    isCompleted: isCompleted,
  );
}
