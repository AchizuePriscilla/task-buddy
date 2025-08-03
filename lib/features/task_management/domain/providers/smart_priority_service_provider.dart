import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/services/smart_priority_service.dart';
import 'package:task_buddy/features/task_management/domain/services/user_analytics_service.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_repository_provider.dart';

/// Provider for smart priority service
final smartPriorityServiceProvider = Provider<SmartPriorityService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final analyticsService = ref.watch(userAnalyticsServiceProvider);
  return SmartPriorityService(taskRepository, analyticsService);
});

/// Provider for user analytics service
final userAnalyticsServiceProvider = Provider<UserAnalyticsService>((ref) {
  return UserAnalyticsService();
});
