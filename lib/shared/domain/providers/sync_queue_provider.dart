import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import 'package:task_buddy/shared/domain/providers/sync_queue_storage_provider.dart';

/// Provider for sync queue
final syncQueueProvider = Provider<SyncQueue>((ref) {
  final storage = ref.watch(syncQueueStorageProvider);
  final queue = SyncQueue(storage);
  queue.initialize();
  return queue;
});
