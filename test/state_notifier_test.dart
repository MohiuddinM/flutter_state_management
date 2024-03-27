// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_state_management/flutter_state_management.dart';
import 'package:flutter_state_management/src/state.dart';
import 'package:flutter_state_management/src/state_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_key_value/isar_key_value.dart';
import 'package:mockito/mockito.dart';

class MockIsarKeyValue extends Mock implements IsarKeyValue {}

final testResolver = Resolver((_) => TestStateNotifier());

class TestStateNotifier extends StateNotifier<int, String> {
  TestStateNotifier() : super(const Idle());
}

class TestPersistedStateNotifier extends PersistedStateNotifier<int, String> {
  TestPersistedStateNotifier(super.mockIsarKeyValue);
}

class MemoryIsarKeyValue implements IsarKeyValue {
  final _map = <String, dynamic>{};

  @override
  Future<void> clear() async => _map.clear();

  @override
  Future<bool> close({bool deleteDb = false}) async {
    _map.clear();
    return true;
  }

  @override
  String get directory => '.';

  @override
  Future<T?> get<T>(String key) {
    return _map[key];
  }

  @override
  Future<T?> getById<T>(int id) {
    return _map.values.elementAt(id);
  }

  @override
  String get name => 'default';

  @override
  Future<bool> remove(String key) async {
    _map.remove(key);
    return true;
  }

  @override
  Future<bool> removeById(int id) async {
    _map.remove(_map.keys.elementAt(id));
    return true;
  }

  @override
  Future<int> set<T>(String key, T value) async {
    _map[key] = value;
    return _map.keys.toList().indexWhere((e) => e == key);
  }
}

void main() {
  group('TestStateNotifier', () {
    late TestStateNotifier notifier;

    setUp(() {
      notifier = TestStateNotifier();
    });

    test('should set state correctly', () {
      notifier.state = const Loaded(data: 1);
      expect(notifier.state, isA<Loaded>());
      expect(notifier.data, 1);
    });

    test('should set loading state correctly', () {
      notifier.setLoading();
      expect(notifier.isLoading, true);
    });

    test('should set failure state correctly', () {
      notifier.setFailure('error');
      expect(notifier.hasError, true);
      expect(notifier.error, 'error');
    });

    test('should set loaded state correctly', () {
      notifier.setLoaded(1);
      expect(notifier.hasData, true);
      expect(notifier.data, 1);
    });

    test('should set idle state correctly', () {
      notifier.setIdle();
      expect(notifier.hasNoData, true);
    });

    test('should return correct loadingFuture', () async {
      notifier.setLoading();
      expect(notifier.loadingFuture, completes);
      notifier.setLoaded(1);
      expect(notifier.loadingFuture, completes);
    });
  });

  group('Resolver', () {
    test('notifier is removed on dispose', () {
      final notifier = testResolver();
      expect(Resolver.cachedNotifiers.length, 1);
      notifier.dispose();
      expect(Resolver.cachedNotifiers.length, 0);

      final notifier2 = testResolver();
      expect(notifier, isNot(notifier2));
    });

    test('notifier is not removed on dispose if removeFromCache is false', () {
      final notifier = testResolver();
      expect(Resolver.cachedNotifiers.length, 1);
      notifier.dispose(removeFromCache: false);
      expect(Resolver.cachedNotifiers.length, 1);

      final notifier2 = testResolver();
      expect(notifier, notifier2);
    });
  });

  // group('PersistedStateNotifier', () {
  //   late TestPersistedStateNotifier notifier;
  //   late MemoryIsarKeyValue store;
  //
  //   setUp(() {
  //     store = MemoryIsarKeyValue();
  //     notifier = TestPersistedStateNotifier(store);
  //   });
  //
  //   test('should initialize state correctly', () async {
  //     await notifier.isInitialized;
  //     verify(store.get('TestPersistedStateNotifier')).called(1);
  //   });
  //
  //   test('should serialize and deserialize data correctly', () {
  //     final data = 1;
  //     final serialized = notifier.serialize(data);
  //     expect(serialized, data);
  //     final deserialized = notifier.deserialize(serialized);
  //     expect(deserialized, data);
  //   });
  //
  //   test('should set persisted state correctly', () {
  //     notifier.persistedState = Loaded(data: 1);
  //     verify(store.set('TestPersistedStateNotifier', any)).called(1);
  //   });
  // });
}
