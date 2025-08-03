import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_local_datasource.dart';
import 'package:task_buddy/shared/domain/providers/database_provider.dart';

/// Provider for local data source
final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final databaseService = ref.watch(initializedDatabaseProvider);
  return TaskLocalDataSource(databaseService);
});
