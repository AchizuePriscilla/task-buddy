import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_local_datasource.dart';
import 'package:task_buddy/shared/domain/providers/database_provider.dart';

/// Provider for TaskLocalDataSource
final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final databaseService = ref.watch(databaseProvider);
  return TaskLocalDataSource(databaseService);
});
