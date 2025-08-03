import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_filter_service_provider.dart';
import 'package:task_buddy/features/task_management/presentation/providers/task_state_provider.dart';
import 'package:task_buddy/features/task_management/presentation/providers/filter_state_provider.dart';

/// Computed provider for filtered tasks
/// Combines task state and filter state
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final taskState = ref.watch(taskStateProvider);
  final filterState = ref.watch(filterStateProvider);
  final filterService = ref.watch(taskFilterServiceProvider);

  return filterService.filterTasks(
    tasks: taskState.tasks,
    searchQuery: filterState.searchQuery,
    category: filterState.selectedCategory,
    priority: filterState.selectedPriority,
    isCompleted: filterState.selectedCompletionStatus,
    dueDateFrom: filterState.dueDateFrom,
    dueDateTo: filterState.dueDateTo,
  );
});

/// Computed provider for task counts
final taskCountsProvider = Provider<Map<String, int>>((ref) {
  final taskState = ref.watch(taskStateProvider);
  final filterService = ref.watch(taskFilterServiceProvider);
  return filterService.getTaskCounts(taskState.tasks);
});

/// Computed provider for overdue tasks
final overdueTasksProvider = Provider<List<TaskModel>>((ref) {
  final taskState = ref.watch(taskStateProvider);
  final filterService = ref.watch(taskFilterServiceProvider);
  return filterService.getOverdueTasks(taskState.tasks);
});

/// Computed provider for tasks due today
final tasksDueTodayProvider = Provider<List<TaskModel>>((ref) {
  final taskState = ref.watch(taskStateProvider);
  final filterService = ref.watch(taskFilterServiceProvider);
  return filterService.getTasksDueToday(taskState.tasks);
});

/// Computed provider for active filters
final hasActiveFiltersProvider = Provider<bool>((ref) {
  final filterState = ref.watch(filterStateProvider);
  return filterState.hasActiveFilters;
});

/// Computed provider for task completion percentage
final taskCompletionPercentageProvider = Provider<double>((ref) {
  final taskState = ref.watch(taskStateProvider);
  final tasks = taskState.tasks;

  if (tasks.isEmpty) return 0.0;

  final completedTasks = tasks.where((task) => task.isCompleted).length;
  return (completedTasks / tasks.length) * 100;
});
