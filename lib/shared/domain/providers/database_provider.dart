import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/shared/data/local/database/database_service.dart';

/// Provider for the pre-initialized database service
/// This should be overridden in main() with the actual initialized database
final databaseProvider = Provider<DatabaseService>((ref) {
  // This should never be called since we override it in main()
  throw UnimplementedError('Database should be initialized in main()');
});
