import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:task_buddy/shared/data/sync/sync_queue.dart';
import 'package:task_buddy/shared/data/local/local_storage_service.dart';

/// SharedPreferences implementation for sync queue storage
class SharedPrefsSyncQueueStorage {
  static const String _operationsKey = 'sync_queue_operations';

  final LocalStorageService _localStorage;

  SharedPrefsSyncQueueStorage(this._localStorage);
  Future<void> saveOperations(List<SyncOperation> operations) async {
    try {
      // Save operations as JSON array
      final operationsJson = operations.map((op) => op.toJson()).toList();
      final operationsString = jsonEncode(operationsJson);
      await _localStorage.set(_operationsKey, operationsString);

      debugPrint('Sync queue saved: ${operations.length} operations');
    } catch (e) {
      debugPrint('Failed to save sync queue: $e');
      rethrow;
    }
  }

  Future<List<SyncOperation>> loadOperations() async {
    try {
      final operationsString = await _localStorage.get(_operationsKey);
      if (operationsString == null) return [];
      final operationsJson =
          jsonDecode(operationsString.toString()) as List<dynamic>;
      final operations = operationsJson
          .map((json) => SyncOperation.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('Sync queue loaded: ${operations.length} operations');
      return operations;
    } catch (e) {
      debugPrint('Failed to load sync queue: $e');
      // Return empty list instead of rethrowing to allow graceful recovery
      return [];
    }
  }

  Future<void> clearOperations() async {
    try {
      await _localStorage.remove(_operationsKey);
      debugPrint('Sync queue cleared successfully');
    } catch (e) {
      debugPrint('Failed to clear sync queue: $e');
      rethrow;
    }
  }
}
