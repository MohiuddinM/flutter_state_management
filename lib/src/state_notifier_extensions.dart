import 'package:flutter/widgets.dart';
import 'package:flutter_state_management/src/state_notifier.dart';
import 'package:flutter_state_management/src/reactive.dart';
import 'builder.dart';
import 'state.dart';

extension StateNotifierExtensions<StateType, ErrorType>
    on StateNotifier<StateType, ErrorType> {
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
  T? notifier<R, S, T extends StateNotifier<R, S>>() {
    final builder = findAncestorWidgetOfExactType<StateNotifierBuilder<R, S>>();
    return builder?.notifier as T?;
  }
}
