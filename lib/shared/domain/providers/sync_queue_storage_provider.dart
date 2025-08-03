import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/shared/data/sync/shared_prefs_sync_queue_storage.dart';
import 'package:task_buddy/shared/domain/providers/shared_preferences_storage_service_provider.dart';

/// Provider for sync queue storage
final syncQueueStorageProvider = Provider<SharedPrefsSyncQueueStorage>((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return SharedPrefsSyncQueueStorage(localStorageService);
});
