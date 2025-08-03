import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/shared/data/local/database/database_service.dart';
import 'package:task_buddy/shared/data/local/database/hive_database_service.dart';

/// Provider for database service initialization
final databaseProvider = FutureProvider<DatabaseService>((ref) async {
  final service = HiveDatabaseService();
  await service.initialize();
  return service;
});

/// Provider for initialized database service
final initializedDatabaseProvider = Provider<DatabaseService>((ref) {
  final databaseAsync = ref.watch(databaseProvider);
  return databaseAsync.when(
    data: (service) => service,
    loading: () => throw Exception('Database is still initializing'),
    error: (error, stack) =>
        throw Exception('Failed to initialize database: $error'),
  );
});
