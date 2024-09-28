import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_state_management/src/key_value_store.dart';

import 'resolver.dart';
import 'state.dart';

abstract class StateNotifier<StateType, ErrorType> extends ChangeNotifier
    implements ValueListenable<Event<StateType, ErrorType>> {
  StateNotifier(this._state);

  Event<StateType, ErrorType> _state;

  Completer<void>? _waitingCompleter;

  Future<void> get waitingFuture async {
    if (_waitingCompleter == null) return;
    return _waitingCompleter!.future;
  }

  set state(Event<StateType, ErrorType> s) {
    _state = s;

    if (isWaiting) {
      _waitingCompleter ??= Completer();
    } else {
      _waitingCompleter?.complete();
      _waitingCompleter = null;
    }

    notifyListeners();
  }

  void refresh() => notifyListeners();

  void setWaiting({bool removeData = false}) {
    state = (removeData || hasNoData) ? const Waiting() : Waiting(data: data);
  }

  void setFailure(ErrorType error, {bool removeData = false}) {
    state = (removeData || hasNoData)
        ? Failed(error: error)
        : Failed(error: error, data: data);
  }

  void setActive(StateType data) {
    state = Active(data: data);
  }

  void setNone({bool removeData = false}) {
    state = (removeData || hasNoData) ? const None() : None(data: data);
  }

  Event<StateType, ErrorType> get state => _state;

  @override
  Event<StateType, ErrorType> get value => _state;

  bool get hasData => state.data != null;

  bool get hasNoData => state.data == null;

  bool get hasCurrentData => state is Active;

  bool get hasError => state is Failed;

  bool get isWaiting => state is Waiting;

  bool get isNone => state is None;

  StateType get data => state.data!;

  ErrorType get error => state.error!;

  @override
  @mustCallSuper
  void dispose({bool removeFromCache = true}) {
    if (removeFromCache) {
      CreateNotifier.removeCachedNotifier(this);
    }
    super.dispose();
  }

  @override
  String toString() {
    return '$runtimeType($_state)';
  }
}

abstract class PersistedStateNotifier<StateType, ErrorType>
    extends StateNotifier<StateType, ErrorType> {
  PersistedStateNotifier(
    this._store, {
    StateType? startState,
  }) : super(const None()) {
    _initializationCompleter.complete(_initialize(startState));
  }

  final KeyValueStore _store;
  final _initializationCompleter = Completer<void>();
  late final String key = runtimeType.toString();

  Future<void> get isInitialized => _initializationCompleter.future;

  Future<void> _initialize(StateType? startState) async {
    final lastState = await _store.get(key);

    if (lastState != null) {
      _state = lastState is StateType
          ? Active(data: lastState)
          : Active(data: deserialize(lastState));
      return notifyListeners();
    }

    _state =
        startState != null ? Active(data: startState) : None(data: startState);
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
    if (s is Active) {
      final data = s.data as StateType;
      _store.set(key, serialize(data));
    }

    super.state = s;
  }
}
