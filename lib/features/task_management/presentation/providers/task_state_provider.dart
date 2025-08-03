import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
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

      // Add sample data if no tasks exist (for testing)
      if (tasks.isEmpty) {
        await _addSampleTasks();
        final updatedTasks = await _repository.getAllTasks();
        state = state.copyWith(tasks: updatedTasks, isLoading: false);
      } else {
        state = state.copyWith(tasks: tasks, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: '${AppStrings.failedToLoadTasks} ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> _addSampleTasks() async {
    final sampleTasks = [
      TaskModel(
        id: '1',
        title: 'Complete project documentation',
        description:
            'Write comprehensive documentation for the Flutter project',
        category: CategoryEnum.work,
        dueDate: DateTime.now().add(Duration(days: 2)),
        priority: Priority.high,
        isCompleted: false,
      ),
      TaskModel(
        id: '2',
        title: 'Buy groceries',
        description: 'Get milk, bread, eggs, and vegetables',
        category: CategoryEnum.personal,
        dueDate: DateTime.now().add(Duration(days: 1)),
        priority: Priority.medium,
        isCompleted: false,
      ),
      TaskModel(
        id: '3',
        title: 'Exercise routine',
        description: '30 minutes cardio and strength training',
        category: CategoryEnum.health,
        dueDate: DateTime.now(),
        priority: Priority.high,
        isCompleted: true,
      ),
      TaskModel(
        id: '4',
        title: 'Read Flutter documentation',
        description: 'Study Riverpod and state management patterns',
        category: CategoryEnum.study,
        dueDate: DateTime.now().add(Duration(days: 5)),
        priority: Priority.low,
        isCompleted: false,
      ),
      TaskModel(
        id: '5',
        title: 'Call dentist',
        description: 'Schedule annual checkup appointment',
        category: CategoryEnum.health,
        dueDate: DateTime.now().add(Duration(days: 3)),
        priority: Priority.medium,
        isCompleted: false,
      ),
    ];

    for (final task in sampleTasks) {
      await _repository.createTask(task);
    }
  }

  Future<void> createTask(TaskModel task) async {
    try {
      await _repository.createTask(task);
      await loadTasks();
    } catch (e) {
      state = state.copyWith(
          error: '${AppStrings.failedToCreateTask} ${e.toString()}');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _repository.updateTask(task);
      final updatedTasks = state.tasks.map((t) {
        return t.id == task.id ? task : t;
      }).toList();
      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      state = state.copyWith(
          error: '${AppStrings.failedToUpdateTask} ${e.toString()}');
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    try {
      await _repository.deleteTask(task);
      final updatedTasks = state.tasks.where((t) => t.id != task.id).toList();
      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      state = state.copyWith(
          error: '${AppStrings.failedToDeleteTask} ${e.toString()}');
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
