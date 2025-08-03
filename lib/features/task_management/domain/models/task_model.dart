import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final CategoryEnum category;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final Priority priority;

  @HiveField(6)
  final bool isCompleted;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    CategoryEnum? category,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: CategoryEnum.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      dueDate: DateTime.parse(json['dueDate']),
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
      ),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        dueDate,
        priority,
        isCompleted,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}
