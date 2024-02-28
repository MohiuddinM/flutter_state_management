import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar_key_value/isar_key_value.dart';

import 'state.dart';

abstract class StateNotifier<StateType, ErrorType> extends ChangeNotifier {
  StateNotifier(this._state);

  Event<StateType, ErrorType> _state;

  Completer<void>? _loadingCompleter;

  Future<void> get loadingFuture async {
    if (_loadingCompleter == null) return;
    return _loadingCompleter!.future;
  }

  set state(Event<StateType, ErrorType> s) {
    _state = s;

    if (isLoading) {
      _loadingCompleter ??= Completer();
    } else {
      _loadingCompleter?.complete();
      _loadingCompleter = null;
    }

    notifyListeners();
  }

  void refresh() => notifyListeners();

  @protected
  void setLoading() {
    state = hasData ? Loading(data: data) : const Loading();
  }

  @protected
  void setFailure(ErrorType error) {
    state = hasData ? Failed(error: error, data: data) : Failed(error: error);
  }

  @protected
  void setLoaded(StateType data) {
    state = Loaded(data: data);
  }

  @protected
  void setIdle({bool removeData = true}) {
    state = removeData || hasNoData ? const Idle() : Idle(data: data);
  }

  Event<StateType, ErrorType> get state => _state;

  bool get hasData => state.data != null;

  bool get hasNoData => state.data == null;

  bool get hasError => state is Failed;

  bool get isLoading => state is Loading;

  StateType get data => state.data!;

  ErrorType get error => state.error!;
}

abstract class PersistedStateNotifier<StateType, ErrorType>
    extends StateNotifier<StateType, ErrorType> {
  PersistedStateNotifier(
    this._store, {
    StateType? startState,
  }) : super(const Idle()) {
    _initializationCompleter.complete(_initialize(startState));
  }

  final IsarKeyValue _store;
  final _initializationCompleter = Completer<void>();
  late final String key = runtimeType.toString();

  Future<void> get isInitialized => _initializationCompleter.future;

  Future<void> _initialize(StateType? startState) async {
    final lastState = await _store.get(key);

    if (lastState != null) {
      _state = lastState is StateType
          ? Loaded(data: lastState)
          : Loaded(data: deserialize(lastState));
      return notifyListeners();
    }

    _state =
        startState != null ? Loaded(data: startState) : Idle(data: startState);
    return notifyListeners();
  }

  StateType deserialize(dynamic o) {
    if (o is StateType) {
      return o;
    }

    throw ArgumentError('$o is not $StateType');
  }

  dynamic serialize(StateType o) {
    if (_isPrimitive(o)) {
      return o;
    }

    throw ArgumentError('${o.runtimeType} is not a primitive');
  }

  bool _isPrimitive(StateType v) =>
      v is num || v is String || v is DateTime || v is bool;

  set persistedState(Event<StateType, ErrorType> s) {
    if (s is Loaded) {
      final data = s.data as StateType;
      _store.set(key, serialize(data));
    }

    super.state = s;
  }
}
