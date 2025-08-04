import 'package:flutter_test/flutter_test.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/user_analytics_model.dart';
import '../../helpers/test_data_factory.dart';

void main() {
  group('UserAnalyticsModel', () {
    test('should create with required parameters and default values', () {
      final analytics = UserAnalyticsModel(
        id: 'test-id',
        category: CategoryEnum.work,
      );

      expect(analytics.id, equals('test-id'));
      expect(analytics.category, equals(CategoryEnum.work));
      expect(analytics.totalTasksCreated, equals(0));
      expect(analytics.totalTasksCompleted, equals(0));
      expect(analytics.lastUpdated, isA<DateTime>());
    });

    test('should calculate completion rate correctly', () {
      final analytics = UserAnalyticsModel(
        id: 'test-id',
        category: CategoryEnum.work,
        totalTasksCreated: 10,
        totalTasksCompleted: 7,
      );

      expect(analytics.completionRate, equals(0.7));
    });

    test('should calculate on-time completion rate correctly', () {
      final analytics = UserAnalyticsModel(
        id: 'test-id',
        category: CategoryEnum.work,
        totalTasksCompleted: 10,
        tasksCompletedOnTime: 8,
      );

      expect(analytics.onTimeCompletionRate, equals(0.8));
    });

    test('should return 0.0 for rates when no tasks exist', () {
      final analytics = UserAnalyticsModel(
        id: 'test-id',
        category: CategoryEnum.work,
      );

      expect(analytics.completionRate, equals(0.0));
      expect(analytics.onTimeCompletionRate, equals(0.0));
    });

    test('should create copy with updated values', () {
      final original = TestDataFactory.createUserAnalytics();
      final updated = original.copyWith(
        totalTasksCreated: 15,
        totalTasksCompleted: 12,
      );

      expect(updated.totalTasksCreated, equals(15));
      expect(updated.totalTasksCompleted, equals(12));
      expect(updated.id, equals(original.id));
      expect(updated.category, equals(original.category));
    });

    test('should convert to and from JSON correctly', () {
      final analytics = UserAnalyticsModel(
        id: 'test-id',
        category: CategoryEnum.work,
        totalTasksCreated: 10,
        totalTasksCompleted: 8,
        tasksCompletedOnTime: 6,
        tasksCompletedLate: 2,
        lastUpdated: DateTime(2024, 1, 15, 10, 30, 0),
      );

      final json = analytics.toJson();
      final fromJson = UserAnalyticsModel.fromJson(json);

      expect(fromJson.id, equals(analytics.id));
      expect(fromJson.category, equals(analytics.category));
      expect(fromJson.totalTasksCreated, equals(analytics.totalTasksCreated));
      expect(
          fromJson.totalTasksCompleted, equals(analytics.totalTasksCompleted));
    });

    test('should handle equality correctly', () {
      final now = DateTime.now();
      final analytics1 = UserAnalyticsModel(
        id: 'test-id',
        category: CategoryEnum.work,
        lastUpdated: now,
      );
      final analytics2 = UserAnalyticsModel(
        id: 'test-id',
        category: CategoryEnum.work,
        lastUpdated: now,
      );

      expect(analytics1, equals(analytics2));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = {
        'id': 'test-id',
        'category': 'work',
        'lastUpdated': '2024-01-15T10:30:00.000',
      };

      final analytics = UserAnalyticsModel.fromJson(json);

      expect(analytics.totalTasksCreated, equals(0));
      expect(analytics.totalTasksCompleted, equals(0));
      expect(analytics.tasksCompletedOnTime, equals(0));
      expect(analytics.tasksCompletedLate, equals(0));
    });
  });
}
