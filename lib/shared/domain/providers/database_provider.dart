import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/shared/data/local/database/database_service.dart';
import 'package:task_buddy/shared/data/local/database/hive_database_service.dart';

/// Provider for database service
final databaseProvider = Provider<DatabaseService>((ref) {
  return HiveDatabaseService();
});
