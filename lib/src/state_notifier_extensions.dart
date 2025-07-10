import 'package:flutter/widgets.dart';
import 'package:flutter_state_management/src/state_notifier.dart';
import 'builder.dart';
import 'state.dart';

extension StateNotifierExtensions<StateType, ErrorType>
    on StateNotifier<StateType, ErrorType> {
  /// Builds a widget based on the state of the [StateNotifier].
  ///
  /// [onActive] is called when the state is [Active].
  /// [onWaiting] is called when the state is [Waiting].
  /// [onNone] is called when the state is [None].
  /// [onFailure] is called when the state is [Failed].
  /// [selector] can be used to rebuild the widget only when a specific part of the state changes.
  /// [selectOnActiveOnly] determines if the selector should only be applied for the [Active] state.
  Widget builder({
    Key? key,
    required ActiveBuilder<StateType> onActive,
    WaitingBuilder<StateType>? onWaiting,
    WaitingBuilder<StateType>? onNone,
    FailureBuilder? onFailure,
    Selector<StateNotifier<StateType, ErrorType>>? selector,
    bool selectOnActiveOnly = true,
  }) {
    return StateNotifierBuilder<StateType, ErrorType>(
      key: key,
      onActive: onActive,
      onFailure: onFailure,
      onWaiting: onWaiting,
      onNone: onNone,
      selector: selector,
      selectOnActiveOnly: selectOnActiveOnly,
      notifier: this,
    );
  }

  /// Returns a [ValueWidgetBuilder] that can be used with widgets like [ValueListenableBuilder].
  ///
  /// This provides a way to build widgets based on the state, passing the state's data
  /// and an optional child widget to the builder functions.
  ///
  /// [onActive] is called for the [Active] state.
  /// [onWaiting] is called for the [Waiting] state.
  /// [onNone] is called for the [None] state.
  /// [onFailure] is called for the [Failed] state.
  /// [child] is an optional widget that can be passed to the builder functions.
  ValueWidgetBuilder<Event<StateType, ErrorType>> builderArg({
    required Widget Function(BuildContext, StateType, Widget?) onActive,
    required Widget Function(BuildContext, StateType?, Widget?) onWaiting,
    required Widget Function(BuildContext, StateType?, Widget?) onNone,
    required Widget Function(
      BuildContext,
      ErrorType,
      StateType?,
      Widget?,
    ) onFailure,
    Widget? child,
  }) {
    return (context, value, child) {
      return switch (value) {
        None(:final data) => onNone.call(context, data, child),
        Waiting(:final data) => onWaiting.call(context, data, child),
        Active(:final data) => onActive(context, data, child),
        Failed(:final data, :final error) => onFailure(
            context,
            error,
            data,
            child,
          ),
        _ => throw StateError(value.toString()),
      };
    };
  }
}

extension BuildContextNotifierX on BuildContext {
  /// Finds the nearest [StateNotifier] provided by a [StateNotifierBuilder] in the widget tree.
  ///
  /// Returns `null` if no matching notifier is found.
  T? notifier<R, S, T extends StateNotifier<R, S>>() {
    final builder = findAncestorWidgetOfExactType<StateNotifierBuilder<R, S>>();
    return builder?.notifier as T?;
  }
}
