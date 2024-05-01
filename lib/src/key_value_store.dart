abstract class KeyValueStore {
  String get name;

  String get directory;

  Future<void> clear();

  Future<bool> close({bool deleteDb = false});

  Future<T?> get<T>(String key);

  Future<T?> getById<T>(int id);

  Future<bool> remove(String key);

  Future<bool> removeById(int id);

  Future<int> set<T>(String key, T value);
}
