import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/services/task_filter_service.dart';

/// Provider for task filter service
final taskFilterServiceProvider = Provider<TaskFilterService>((ref) {
  return TaskFilterService();
});
