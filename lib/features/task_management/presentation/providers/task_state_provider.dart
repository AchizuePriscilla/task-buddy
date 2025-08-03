import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_repository_provider.dart';
import 'package:task_buddy/features/task_management/domain/providers/smart_priority_service_provider.dart';
import 'package:task_buddy/features/task_management/domain/services/smart_priority_service.dart';
import 'package:task_buddy/features/task_management/domain/services/user_analytics_service.dart';
import 'package:task_buddy/shared/localization/strings.dart';

/// Task state for UI
class TaskState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? error;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });

  TaskState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Task state notifier
class TaskStateNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  final SmartPriorityService _smartPriorityService;
  final UserAnalyticsService _analyticsService;

  TaskStateNotifier(
      this._repository, this._smartPriorityService, this._analyticsService)
      : super(const TaskState());

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _repository.getAllTasks();
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: '${AppStrings.failedToLoadTasks} ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> createTask(TaskModel task) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createTask(task);

      // Trigger smart priority recalculation for the task's category
      await _smartPriorityService.onTaskCreated(task);
      _analyticsService.onTaskCreated(task);

      await loadTasks();
    } catch (e) {
      state = state.copyWith(
        error: AppStrings.failedToCreateTask,
        isLoading: false,
      );
    }
  }

  Future<void> updateTask(TaskModel task) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check if completion status changed
      final originalTask = state.tasks.firstWhere((t) => t.id == task.id);
      final wasCompleted = originalTask.isCompleted;
      final isCompleted = task.isCompleted;

      await _repository.updateTask(task);

      // Trigger smart priority recalculation for the task's category
      await _smartPriorityService.onTaskUpdated(task);

      // If task was completed, trigger additional recalculation
      if (!wasCompleted && isCompleted) {
        await _smartPriorityService.onTaskCompleted(task);
        _analyticsService.onTaskCompleted(task);
      } else if (wasCompleted && !isCompleted) {
        _analyticsService.onTaskUncompleted(task);
      }

      // Reload tasks to get updated priorities from smart priority system
      await loadTasks();
    } catch (e) {
      state = state.copyWith(
        error: AppStrings.failedToUpdateTask,
        isLoading: false,
      );
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteTask(task);

      // Trigger smart priority recalculation for the task's category
      await _smartPriorityService.onTaskUpdated(task);

      // Reload tasks to get updated priorities from smart priority system
      await loadTasks();
    } catch (e) {
      state = state.copyWith(
        error: AppStrings.failedToDeleteTask,
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for task state management
final taskStateProvider =
    StateNotifierProvider<TaskStateNotifier, TaskState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final smartPriorityService = ref.watch(smartPriorityServiceProvider);
  final analyticsService = ref.watch(userAnalyticsServiceProvider);
  return TaskStateNotifier(repository, smartPriorityService, analyticsService);
});
