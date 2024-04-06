import 'package:flutter/widgets.dart';
import 'package:flutter_state_management/src/state_notifier.dart';
import 'package:flutter_state_management/src/reactive.dart';
import 'builder.dart';
import 'state.dart';

extension StateNotifierExtensions<StateType, ErrorType>
    on StateNotifier<StateType, ErrorType> {
  Widget builder({
    Key? key,
    required LoadedBuilder<StateType> onLoaded,
    LoadingBuilder<StateType>? onLoading,
    LoadingBuilder<StateType>? onIdle,
    FailureBuilder? onFailure,
    Selector<StateNotifier<StateType, ErrorType>>? selector,
  }) {
    return StateNotifierBuilder<StateType, ErrorType>(
      key: key,
      onLoaded: onLoaded,
      onFailure: onFailure,
      onLoading: onLoading,
      onIdle: onIdle,
      selector: selector,
      notifier: this,
    );
  }

  ValueWidgetBuilder<Event<StateType, ErrorType>> builderArg({
    required Widget Function(BuildContext, StateType, Widget?) onLoaded,
    required Widget Function(BuildContext, StateType?, Widget?) onLoading,
    required Widget Function(BuildContext, StateType?, Widget?) onIdle,
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
        Idle(:final data) => onIdle.call(context, data, child),
        Loading(:final data) => onLoading.call(context, data, child),
        Loaded(:final data) => onLoaded(context, data, child),
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
