import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/shared/data/local/shared_prefs_storage_service.dart';

final localStorageServiceProvider = Provider((ref) {
  final SharedPrefsService prefsService = SharedPrefsService();
  prefsService.init();
  return prefsService;
});
