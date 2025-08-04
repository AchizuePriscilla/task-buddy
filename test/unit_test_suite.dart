import 'unit/services/task_filter_service_test.dart' as task_filter_test;
import 'unit/models/task_model_test.dart' as task_model_test;
import 'unit/enums/priority_enum_test.dart' as priority_enum_test;
import 'unit/services/smart_priority_service_test.dart' as smart_priority_test;
import 'unit/repositories/task_repository_test.dart' as task_repository_test;
import 'unit/data/sync_queue_test.dart' as sync_queue_test;

void main() {
  // Run all unit tests for business logic and data layer
  task_filter_test.main();
  task_model_test.main();
  priority_enum_test.main();
  smart_priority_test.main();
  task_repository_test.main();
  sync_queue_test.main();
}
