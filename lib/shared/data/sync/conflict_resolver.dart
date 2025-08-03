import 'package:task_buddy/features/task_management/domain/models/task_model.dart';

/// Handles conflict resolution using last-write-wins strategy
class ConflictResolver {
  /// Resolves conflicts between local and remote tasks using last-write-wins
  /// Returns the task that should be kept (the most recently updated one)
  static TaskModel resolveConflict(TaskModel localTask, TaskModel remoteTask) {
    // Compare timestamps to determine which is more recent
    if (localTask.updatedAt.isAfter(remoteTask.updatedAt)) {
      return localTask; // Local is more recent
    } else if (remoteTask.updatedAt.isAfter(localTask.updatedAt)) {
      return remoteTask; // Remote is more recent
    } else {
      // Same updatedAt timestamp, compare creation time as tiebreaker
      if (localTask.createdAt.isAfter(remoteTask.createdAt)) {
        return localTask; // Local was created later
      } else if (remoteTask.createdAt.isAfter(localTask.createdAt)) {
        return remoteTask; // Remote was created later
      } else {
        // Same creation time too, default to local as the source of truth
        return localTask;
      }
    }
  }

  /// Determines if two tasks have conflicts that need resolution
  static bool hasConflict(TaskModel localTask, TaskModel remoteTask) {
    // Tasks conflict if they have the same ID but different content
    if (localTask.id != remoteTask.id) return false;

    // Check if content is different
    return localTask.title != remoteTask.title ||
        localTask.description != remoteTask.description ||
        localTask.category != remoteTask.category ||
        localTask.dueDate != remoteTask.dueDate ||
        localTask.priority != remoteTask.priority ||
        localTask.isCompleted != remoteTask.isCompleted;
  }

  /// Merges local and remote task lists, resolving conflicts
  static List<TaskModel> mergeTaskLists(
    List<TaskModel> localTasks,
    List<TaskModel> remoteTasks,
  ) {
    final Map<String, TaskModel> mergedTasks = {};

    // Add all local tasks
    for (final localTask in localTasks) {
      mergedTasks[localTask.id] = localTask;
    }

    // Process remote tasks, resolving conflicts
    for (final remoteTask in remoteTasks) {
      final existingLocalTask = mergedTasks[remoteTask.id];

      if (existingLocalTask == null) {
        // New remote task, add it
        mergedTasks[remoteTask.id] = remoteTask;
      } else if (hasConflict(existingLocalTask, remoteTask)) {
        // Conflict detected, resolve using last-write-wins
        final resolvedTask = resolveConflict(existingLocalTask, remoteTask);
        mergedTasks[remoteTask.id] = resolvedTask;
      }
      // If no conflict, keep existing (local) task
    }

    return mergedTasks.values.toList();
  }

  /// Gets a list of tasks that need to be synced (local tasks not on remote)
  static List<TaskModel> getTasksToSync(
    List<TaskModel> localTasks,
    List<TaskModel> remoteTasks,
  ) {
    final remoteTaskIds = remoteTasks.map((task) => task.id).toSet();

    return localTasks.where((localTask) {
      // If task doesn't exist on remote, it needs to be synced
      if (!remoteTaskIds.contains(localTask.id)) {
        return true;
      }

      // Find the corresponding remote task
      final remoteTask = remoteTasks.firstWhere(
        (task) => task.id == localTask.id,
        orElse: () =>
            localTask, // This should never be reached due to the check above
      );

      // Include if there are conflicts
      return hasConflict(localTask, remoteTask);
    }).toList();
  }
}
