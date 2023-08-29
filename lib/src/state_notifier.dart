import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar_key_value/isar_key_value.dart';

import 'state.dart';

abstract class StateNotifier<T> extends ChangeNotifier {
  StateNotifier(this._state);

  DataEvent<T> _state;

  set state(DataEvent<T> s) {
    _state = s;
    notifyListeners();
  }

  void refresh() => notifyListeners();

  DataEvent<T> get state => _state;

  bool get hasData => state.data != null;

  T get data => state.data!;
}

abstract class PersistedStateNotifier<T> extends StateNotifier<T> {
  PersistedStateNotifier(
      this._store, {
        T? startState,
      }) : super(const Idle()) {
    _initializationCompleter.complete(_initialize(startState));
  }

  final _initializationCompleter = Completer<void>();
  final IsarKeyValue _store;

  Future<void> _initialize(T? startState) async {
    final lastState = await _store.get(key);

    if (lastState != null) {
      _state = lastState is T
          ? Loaded(data: lastState)
          : Loaded(data: deserialize(lastState));
      return notifyListeners();
    }

    _state =
    startState != null ? Loaded(data: startState) : Idle(data: startState);
    return notifyListeners();
  }

  T deserialize(dynamic o) {
    if (o is T) {
      return o;
    }

    throw ArgumentError('$o is not $T');
  }

  dynamic serialize(T o) {
    if (_isPrimitive(o)) {
      return o;
    }

    throw ArgumentError('${o.runtimeType} is not a primitive');
  }

  Future<void> get isInitialized => _initializationCompleter.future;
  late final String key = runtimeType.toString();

  bool _isPrimitive(T v) =>
      v is num || v is String || v is DateTime || v is bool;

  set persistedState(DataEvent<T> s) {
    if (s is Loaded) {
      final data = s.data as T;
      _store.set(key, serialize(data));
    }

    super.state = s;
  }
}


