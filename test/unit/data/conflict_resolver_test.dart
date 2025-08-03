import 'package:flutter_test/flutter_test.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/shared/data/sync/conflict_resolver.dart';

void main() {
  group('ConflictResolver', () {
    group('resolveConflict', () {
      test('should return local task when local is more recent', () {
        // Arrange
        final localTask = _createTask(
          id: '1',
          title: 'Local Task',
          updatedAt: DateTime.now(),
        );
        final remoteTask = _createTask(
          id: '1',
          title: 'Remote Task',
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Act
        final result = ConflictResolver.resolveConflict(localTask, remoteTask);

        // Assert
        expect(result, equals(localTask));
      });

      test('should return remote task when remote is more recent', () {
        // Arrange
        final localTask = _createTask(
          id: '1',
          title: 'Local Task',
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final remoteTask = _createTask(
          id: '1',
          title: 'Remote Task',
          updatedAt: DateTime.now(),
        );

        // Act
        final result = ConflictResolver.resolveConflict(localTask, remoteTask);

        // Assert
        expect(result, equals(remoteTask));
      });

      test('should use creation time as tiebreaker when updatedAt is same', () {
        // Arrange
        final sameTime = DateTime.now();
        final localTask = _createTask(
          id: '1',
          title: 'Local Task',
          updatedAt: sameTime,
          createdAt: DateTime.now().add(const Duration(hours: 1)),
        );
        final remoteTask = _createTask(
          id: '1',
          title: 'Remote Task',
          updatedAt: sameTime,
          createdAt: DateTime.now(),
        );

        // Act
        final result = ConflictResolver.resolveConflict(localTask, remoteTask);

        // Assert
        expect(result, equals(localTask));
      });

      test(
          'should return remote task when both timestamps are same but remote created first',
          () {
        // Arrange
        final sameTime = DateTime.now();
        final localTask = _createTask(
          id: '1',
          title: 'Local Task',
          updatedAt: sameTime,
          createdAt: DateTime.now()
              .add(const Duration(hours: 1)), // Local created later
        );
        final remoteTask = _createTask(
          id: '1',
          title: 'Remote Task',
          updatedAt: sameTime,
          createdAt: DateTime.now(), // Remote created earlier
        );

        // Act
        final result = ConflictResolver.resolveConflict(localTask, remoteTask);

        // Assert
        expect(result,
            equals(localTask)); // Local should win because it was created later
      });

      test('should return local task when both timestamps are exactly the same',
          () {
        // Arrange
        final sameTime = DateTime(2024, 1, 1, 12, 0, 0); // Fixed timestamp
        final localTask = TaskModel(
          id: '1',
          title: 'Local Task',
          description: null,
          category: CategoryEnum.work,
          dueDate: DateTime(2024, 1, 2),
          priority: Priority.medium,
          isCompleted: false,
        ).copyWith(
          updatedAt: sameTime,
          createdAt: sameTime,
        );
        final remoteTask = TaskModel(
          id: '1',
          title: 'Remote Task',
          description: null,
          category: CategoryEnum.work,
          dueDate: DateTime(2024, 1, 2),
          priority: Priority.medium,
          isCompleted: false,
        ).copyWith(
          updatedAt: sameTime,
          createdAt: sameTime,
        );

        // Act
        final result = ConflictResolver.resolveConflict(localTask, remoteTask);

        // Assert
        expect(
            result,
            equals(
                localTask)); // Local wins as source of truth when everything is equal
      });
    });

    group('hasConflict', () {
      test('should return false for different task IDs', () {
        // Arrange
        final localTask = _createTask(id: '1', title: 'Task 1');
        final remoteTask = _createTask(id: '2', title: 'Task 2');

        // Act
        final result = ConflictResolver.hasConflict(localTask, remoteTask);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for identical tasks', () {
        // Arrange
        final localTask = _createTask(
          id: '1',
          title: 'Same Task',
          description: 'Same description',
          category: CategoryEnum.work,
          priority: Priority.high,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          isCompleted: false,
        );
        final remoteTask = _createTask(
          id: '1',
          title: 'Same Task',
          description: 'Same description',
          category: CategoryEnum.work,
          priority: Priority.high,
          dueDate: localTask.dueDate,
          isCompleted: false,
        );

        // Act
        final result = ConflictResolver.hasConflict(localTask, remoteTask);

        // Assert
        expect(result, isFalse);
      });

      test('should return true when titles are different', () {
        // Arrange
        final localTask = _createTask(id: '1', title: 'Local Title');
        final remoteTask = _createTask(id: '1', title: 'Remote Title');

        // Act
        final result = ConflictResolver.hasConflict(localTask, remoteTask);

        // Assert
        expect(result, isTrue);
      });

      test('should return true when descriptions are different', () {
        // Arrange
        final localTask =
            _createTask(id: '1', description: 'Local description');
        final remoteTask =
            _createTask(id: '1', description: 'Remote description');

        // Act
        final result = ConflictResolver.hasConflict(localTask, remoteTask);

        // Assert
        expect(result, isTrue);
      });

      test('should return true when categories are different', () {
        // Arrange
        final localTask = _createTask(id: '1', category: CategoryEnum.work);
        final remoteTask =
            _createTask(id: '1', category: CategoryEnum.personal);

        // Act
        final result = ConflictResolver.hasConflict(localTask, remoteTask);

        // Assert
        expect(result, isTrue);
      });

      test('should return true when priorities are different', () {
        // Arrange
        final localTask = _createTask(id: '1', priority: Priority.high);
        final remoteTask = _createTask(id: '1', priority: Priority.low);

        // Act
        final result = ConflictResolver.hasConflict(localTask, remoteTask);

        // Assert
        expect(result, isTrue);
      });

      test('should return true when due dates are different', () {
        // Arrange
        final localTask = _createTask(
          id: '1',
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );
        final remoteTask = _createTask(
          id: '1',
          dueDate: DateTime.now().add(const Duration(days: 2)),
        );

        // Act
        final result = ConflictResolver.hasConflict(localTask, remoteTask);

        // Assert
        expect(result, isTrue);
      });

      test('should return true when completion status is different', () {
        // Arrange
        final localTask = _createTask(id: '1', isCompleted: false);
        final remoteTask = _createTask(id: '1', isCompleted: true);

        // Act
        final result = ConflictResolver.hasConflict(localTask, remoteTask);

        // Assert
        expect(result, isTrue);
      });
    });

    group('mergeTaskLists', () {
      test('should merge lists with no conflicts', () {
        // Arrange
        final localTasks = [
          _createTask(id: '1', title: 'Local Task 1'),
          _createTask(id: '2', title: 'Local Task 2'),
        ];
        final remoteTasks = [
          _createTask(id: '3', title: 'Remote Task 3'),
          _createTask(id: '4', title: 'Remote Task 4'),
        ];

        // Act
        final result = ConflictResolver.mergeTaskLists(localTasks, remoteTasks);

        // Assert
        expect(result.length, equals(4));
        expect(result.map((t) => t.id).toSet(), equals({'1', '2', '3', '4'}));
      });

      test('should resolve conflicts using last-write-wins', () {
        // Arrange
        final localTasks = [
          _createTask(
            id: '1',
            title: 'Local Task',
            updatedAt: DateTime.now(),
          ),
        ];
        final remoteTasks = [
          _createTask(
            id: '1',
            title: 'Remote Task',
            updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];

        // Act
        final result = ConflictResolver.mergeTaskLists(localTasks, remoteTasks);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.title, equals('Local Task'));
      });

      test('should keep local task when no conflict exists', () {
        // Arrange
        final localTasks = [
          _createTask(id: '1', title: 'Local Task'),
        ];
        final remoteTasks = [
          _createTask(id: '1', title: 'Local Task'), // Same content
        ];

        // Act
        final result = ConflictResolver.mergeTaskLists(localTasks, remoteTasks);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.title, equals('Local Task'));
      });

      test('should handle empty lists', () {
        // Arrange
        final localTasks = <TaskModel>[];
        final remoteTasks = <TaskModel>[];

        // Act
        final result = ConflictResolver.mergeTaskLists(localTasks, remoteTasks);

        // Assert
        expect(result, isEmpty);
      });

      test('should handle empty local list', () {
        // Arrange
        final localTasks = <TaskModel>[];
        final remoteTasks = [
          _createTask(id: '1', title: 'Remote Task'),
        ];

        // Act
        final result = ConflictResolver.mergeTaskLists(localTasks, remoteTasks);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.title, equals('Remote Task'));
      });

      test('should handle empty remote list', () {
        // Arrange
        final localTasks = [
          _createTask(id: '1', title: 'Local Task'),
        ];
        final remoteTasks = <TaskModel>[];

        // Act
        final result = ConflictResolver.mergeTaskLists(localTasks, remoteTasks);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.title, equals('Local Task'));
      });
    });

    group('getTasksToSync', () {
      test('should return local tasks that do not exist on remote', () {
        // Arrange
        final commonTask = _createTask(id: '2', title: 'Common Task');
        final localTasks = [
          _createTask(id: '1', title: 'Local Only'),
          commonTask,
        ];
        final remoteTasks = [
          commonTask, // Use the same task object to ensure no conflicts
          _createTask(id: '3', title: 'Remote Only'),
        ];

        // Act
        final result = ConflictResolver.getTasksToSync(localTasks, remoteTasks);

        // Assert
        expect(result.length,
            equals(1)); // Only the local-only task should be returned
        expect(result.first.id, equals('1'));
        expect(result.first.title, equals('Local Only'));
      });

      test('should return local tasks that have conflicts with remote', () {
        // Arrange
        final localTasks = [
          _createTask(
            id: '1',
            title: 'Local Version',
            updatedAt: DateTime.now(),
          ),
        ];
        final remoteTasks = [
          _createTask(
            id: '1',
            title: 'Remote Version',
            updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];

        // Act
        final result = ConflictResolver.getTasksToSync(localTasks, remoteTasks);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals('1'));
        expect(result.first.title, equals('Local Version'));
      });

      test('should not return tasks that exist and have no conflicts', () {
        // Arrange
        final sameTask = _createTask(id: '1', title: 'Same Task');
        final localTasks = [sameTask];
        final remoteTasks = [
          sameTask
        ]; // Use the same task object to ensure no conflicts

        // Act
        final result = ConflictResolver.getTasksToSync(localTasks, remoteTasks);

        // Assert
        expect(result, isEmpty); // No conflicts, so no tasks to sync
      });

      test('should handle empty lists', () {
        // Arrange
        final localTasks = <TaskModel>[];
        final remoteTasks = <TaskModel>[];

        // Act
        final result = ConflictResolver.getTasksToSync(localTasks, remoteTasks);

        // Assert
        expect(result, isEmpty);
      });

      test('should return all local tasks when remote is empty', () {
        // Arrange
        final localTasks = [
          _createTask(id: '1', title: 'Local Task 1'),
          _createTask(id: '2', title: 'Local Task 2'),
        ];
        final remoteTasks = <TaskModel>[];

        // Act
        final result = ConflictResolver.getTasksToSync(localTasks, remoteTasks);

        // Assert
        expect(result.length, equals(2));
        expect(result.map((t) => t.id).toSet(), equals({'1', '2'}));
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
  DateTime? updatedAt,
  DateTime? createdAt,
}) {
  return TaskModel(
    id: id,
    title: title,
    description: description,
    category: category,
    dueDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
    priority: priority,
    isCompleted: isCompleted,
  ).copyWith(
    updatedAt: updatedAt ?? DateTime.now(),
    createdAt: createdAt ?? DateTime.now(),
  );
}
