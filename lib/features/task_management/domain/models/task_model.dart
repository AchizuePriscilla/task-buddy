import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';

class TaskModel {
  final String title;
  final String? description;
  final CategoryEnum category;
  final DateTime? dueDate;
  final Priority priority;
  final bool isCompleted;

  TaskModel({
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });
}
