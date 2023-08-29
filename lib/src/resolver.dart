import 'state_notifier.dart';
import 'type_and_arg.dart';

/// Takes [context] and [arg], returns a [StateNotifier]
typedef ArgNotifierBuilder<T extends StateNotifier, R> = T Function(R? arg);

/// Creates and caches notifiers instances on the fly
///
/// Guarantees compile time safety
final class Resolver<T extends StateNotifier, R> {
  Resolver(this._builder);

  final ArgNotifierBuilder<T, R> _builder;

  /// Caches of all types are kept in the same static instance, so we can
  /// support [clearAllCaches]
  static final _cache = <TypeAndArg, StateNotifier>{};
  T? _toInject;

  /// Injects a notifier into this resolver
  ///
  /// This [Resolver] will always return this injected [notifier].
  /// This can be used during testing, to inject mocks.
  void inject(T notifier) => _toInject = notifier;

  /// Removed the injected notifier, and restores normal notifier creation
  void removeInjection() => _toInject = null;

  /// Creates a new notifier, or retrieves a cached one
  ///
  /// if [useCache] is false then a new notifier is created everytime,
  /// otherwise returns a cached notifier if it exists
  T create({R? arg, bool useCache = true}) {
    if (_toInject != null) {
      return _toInject!;
    }

    if (!useCache) {
      return _builder(arg);
    }

    final cacheKey = TypeAndArg(T, arg);

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]! as T;
    }

    return _cache[cacheKey] = _builder(arg);
  }

  /// Redirects to [create]
  T call({R? arg, bool useCache = true}) =>
      create(arg: arg, useCache: useCache);

  /// Clears cached notifiers only of type [T]
  void clearCache({bool dispose = false}) {
    final entries = _cache.entries.where((e) => e.key.type == T);

    for (final MapEntry(:key, :value) in entries) {
      if (dispose) {
        value.dispose();
      }
      _cache.remove(key);
    }
  }

  /// Removes all cached notifiers of all types
  static void clearAllCaches({bool dispose = false}) {
    if (dispose) {
      _cache.forEach((key, value) {
        value.dispose();
      });
    }

    _cache.clear();
  }

  static Iterable<StateNotifier> get cachedNotifiers => _cache.values;
}
