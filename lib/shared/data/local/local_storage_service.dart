/// Storage service interface
abstract class LocalStorageService {
  void init();

  Future<bool> remove(String key);

  Future<Object?> get(String key);

  Future<bool> set(String key, String data);

  Future<void> clear();

  Future<bool> has(String key);
}
