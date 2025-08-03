import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_repository_provider.dart';
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

  TaskStateNotifier(this._repository) : super(const TaskState());

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
      await _repository.updateTask(task);
      final updatedTasks = state.tasks.map((t) {
        return t.id == task.id ? task : t;
      }).toList();
      state = state.copyWith(tasks: updatedTasks, isLoading: false);
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
      final updatedTasks = state.tasks.where((t) => t.id != task.id).toList();
      state = state.copyWith(tasks: updatedTasks, isLoading: false);
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
  return TaskStateNotifier(repository);
});
