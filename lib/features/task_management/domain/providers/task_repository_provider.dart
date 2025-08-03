import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_local_datasource_provider.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_sync_service_provider.dart';

/// Provider for task repository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final localDataSource = ref.watch(taskLocalDataSourceProvider);
  final syncService = ref.watch(taskSyncServiceProvider);
  return TaskRepositoryImpl(localDataSource, syncService);
});
