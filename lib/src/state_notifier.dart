import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_state_management/src/key_value_store.dart';

import 'create_notifier.dart';
import 'state.dart';

/// An abstract class that manages a piece of state and notifies listeners
/// when the state changes.
abstract class StateNotifier<StateType, ErrorType> extends ChangeNotifier
    implements ValueListenable<Event<StateType, ErrorType>> {
  StateNotifier(this._state);

  Event<StateType, ErrorType> _state;

  Completer<void>? _waitingCompleter;

  /// A future that completes when the notifier is no longer in a waiting state.
  ///
  /// This can be useful for awaiting the completion of an asynchronous operation.
  Future<void> get waitingFuture async {
    if (_waitingCompleter == null) return;
    return _waitingCompleter!.future;
  }

  /// Updates the current state of the notifier.
  ///
  /// Setting a new state will notify all registered listeners.
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

  /// Refreshes the listeners without changing the state.
  void refresh() => notifyListeners();

  /// Sets the state to [Waiting].
  ///
  /// If [removeData] is true, any existing data will be cleared.
  void setWaiting({bool removeData = false}) {
    state = (removeData || hasNoData) ? const Waiting() : Waiting(data: data);
  }

  /// Sets the state to [Failed] with the given [error].
  ///
  /// If [removeData] is true, any existing data will be cleared.
  void setFailed(ErrorType error, {bool removeData = false}) {
    state = (removeData || hasNoData)
        ? Failed(error: error)
        : Failed(error: error, data: data);
  }

  /// Sets the state to [Active] with the given [data].
  void setActive(StateType data) {
    state = Active(data: data);
  }

  /// Sets the state to [None].
  ///
  /// If [removeData] is true, any existing data will be cleared.
  void setNone({bool removeData = false}) {
    state = (removeData || hasNoData) ? const None() : None(data: data);
  }

  /// The current state of the notifier. Most application do not need to
  /// access this directly, but it can be useful for debugging or
  /// logging purposes.
  ///
  /// Consider using [data] or [error] instead.
  Event<StateType, ErrorType> get state => _state;


  /// The current state of the notifier. Most application do not need to
  /// access this directly, but it can be useful for debugging or
  /// logging purposes.
  ///
  /// Consider using [data] or [error] instead.
  @override
  Event<StateType, ErrorType> get value => _state;

  /// Whether the current state has data.
  bool get hasData => state.data != null;

  /// Whether the current state has no data.
  bool get hasNoData => state.data == null;

  /// Whether the state is [Active].
  bool get hasCurrentData => state is Active;

  /// Whether the state is [Failed].
  bool get hasError => state is Failed;

  /// Whether the state is [Waiting].
  bool get isWaiting => state is Waiting;

  /// Whether the state is [None].
  bool get isNone => state is None;

  /// The data from the current state. Check [hasData] before accessing this.
  ///
  /// Throws a [StateError] if the state has no data.
  StateType get data => state.data!;

  /// The error from the current state. Check [hasError] before accessing this.
  ///
  /// Throws a [StateError] if the state is not [Failed].
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

/// An extension of [StateNotifier] that persists its state.
///
/// The state is stored in a [KeyValueStore] and restored upon initialization.
abstract class PersistedStateNotifier<StateType, ErrorType>
    extends StateNotifier<StateType, ErrorType> {
  /// Creates a [PersistedStateNotifier].
  ///
  /// It will attempt to load the last persisted state from the [_store].
  /// If no state is found, it will use the [startState] if provided.
  PersistedStateNotifier(
    this._store, {
    StateType? startState,
  }) : super(const None()) {
    _initializationCompleter.complete(_initialize(startState));
  }

  final KeyValueStore _store;
  final _initializationCompleter = Completer<void>();

  /// The key used to store and retrieve the state in the [KeyValueStore].
  /// Defaults to the runtime type of the notifier.
  late final String key = runtimeType.toString();

  /// A future that completes when the notifier has been initialized with data
  /// from the store or the [startState].
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

  /// Deserializes an object from the [KeyValueStore] into [StateType].
  ///
  /// This function should be overridden in subclasses where [StateType] is
  /// not a primitive type.
  StateType deserialize(dynamic o) {
    if (o is StateType) {
      return o;
    }

    throw ArgumentError('$o is not $StateType');
  }

  /// Serializes the [StateType] data into a type that can be stored by
  /// the [KeyValueStore].
  ///
  /// By default, it only supports primitive types. This function should be
  /// overridden in subclasses complex types.
  ///
  /// This function should return a type that is supported by the
  /// [KeyValueStore] implementation that is being used.
  ///
  /// Popular supported types are: primitive types (int, double, String, DateTime, bool),
  /// List of primitives and Map with primitive keys and values.
  dynamic serialize(StateType o) {
    if (_isPrimitive(o)) {
      return o;
    }

    throw ArgumentError('${o.runtimeType} is not a primitive');
  }

  @pragma('vm:prefer-inline')
  bool _isPrimitive(StateType v) =>
      v is num || v is String || v is DateTime || v is bool;

  /// Updates the persisted state in the [KeyValueStore].
  ///
  /// Only [Active] states are persisted. So, when the app is restarted,
  /// the last active state can be restored.
  set persistedState(Event<StateType, ErrorType> s) {
    if (s is Active) {
      final data = s.data as StateType;
      _store.set(key, serialize(data));
    }

    super.state = s;
  }

  @override

  /// Sets the state to [Active] and optionally persists it.
  void setActive(StateType data, {bool persist = true}) {
    if (persist) {
      persistedState = Active(data: data);
      return;
    }

    super.setActive(data);
  }
}
