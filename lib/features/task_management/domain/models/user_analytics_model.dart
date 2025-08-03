import 'package:hive/hive.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';

part 'user_analytics_model.g.dart';

@HiveType(typeId: 3)
class UserAnalyticsModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final CategoryEnum category;

  @HiveField(2)
  final int totalTasksCreated;

  @HiveField(3)
  final int totalTasksCompleted;

  @HiveField(4)
  final int tasksCompletedOnTime;

  @HiveField(5)
  final int tasksCompletedLate;

  @HiveField(6)
  final DateTime lastUpdated;

  UserAnalyticsModel({
    required this.id,
    required this.category,
    this.totalTasksCreated = 0,
    this.totalTasksCompleted = 0,
    this.tasksCompletedOnTime = 0,
    this.tasksCompletedLate = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  double get completionRate {
    if (totalTasksCreated == 0) return 0.0;
    return totalTasksCompleted / totalTasksCreated;
  }

  double get onTimeCompletionRate {
    if (totalTasksCompleted == 0) return 0.0;
    return tasksCompletedOnTime / totalTasksCompleted;
  }

  UserAnalyticsModel copyWith({
    String? id,
    CategoryEnum? category,
    int? totalTasksCreated,
    int? totalTasksCompleted,
    int? tasksCompletedOnTime,
    int? tasksCompletedLate,
    DateTime? lastUpdated,
  }) {
    return UserAnalyticsModel(
      id: id ?? this.id,
      category: category ?? this.category,
      totalTasksCreated: totalTasksCreated ?? this.totalTasksCreated,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      tasksCompletedOnTime: tasksCompletedOnTime ?? this.tasksCompletedOnTime,
      tasksCompletedLate: tasksCompletedLate ?? this.tasksCompletedLate,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'totalTasksCreated': totalTasksCreated,
      'totalTasksCompleted': totalTasksCompleted,
      'tasksCompletedOnTime': tasksCompletedOnTime,
      'tasksCompletedLate': tasksCompletedLate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return UserAnalyticsModel(
      id: json['id'],
      category: CategoryEnum.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      totalTasksCreated: json['totalTasksCreated'] ?? 0,
      totalTasksCompleted: json['totalTasksCompleted'] ?? 0,
      tasksCompletedOnTime: json['tasksCompletedOnTime'] ?? 0,
      tasksCompletedLate: json['tasksCompletedLate'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAnalyticsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserAnalyticsModel(category: $category, completionRate: ${completionRate.toStringAsFixed(2)})';
  }
}
