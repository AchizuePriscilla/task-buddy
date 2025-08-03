import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/services/task_sync_service.dart';
import 'package:task_buddy/shared/domain/providers/sync_queue_provider.dart';

/// Provider for task sync service
final taskSyncServiceProvider = Provider<TaskSyncService>((ref) {
  final syncQueue = ref.watch(syncQueueProvider);
  return TaskSyncService(syncQueue); // No remote data source for now
});
