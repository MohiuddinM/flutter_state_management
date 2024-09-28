import 'package:flutter/material.dart';

import 'state.dart';
import 'state_notifier.dart';
import 'reactive.dart';

/// Used when notifier updates its state and widget needs to rebuild with
/// new data
typedef ActiveBuilder<T> = Widget Function(BuildContext context, T data);

/// Used when [StateNotifier.state] is a [Waiting] and widget needs to rebuild
/// with busy widget (e.g. progress indicator)
typedef WaitingBuilder<T> = Widget Function(BuildContext context, T? data);

/// Used when [StateNotifier.state] is a [Failed] and an error widget should
/// be built to show that error
typedef FailureBuilder<ErrorType> = Widget Function(
  BuildContext context,
  ErrorType error,
);

/// Used when [onFailure] is not provided to a [StateNotifierBuilder]
typedef GlobalFailureBuilder<ErrorType> = Widget Function(
  BuildContext context,
  ErrorType error,
  Widget? lastStateBuild,
);

/// This function takes a [BuildContext] and a [Widget] and returns a widget
///
/// Used when onWaiting is not provided to a [StateNotifierBuilder]
typedef GlobalWaitingBuilder = Widget Function(
  BuildContext context,
  Widget? lastStateBuild,
);

class StateNotifierBuilder<StateType, ErrorType> extends RStatelessWidget {
  const StateNotifierBuilder({
    super.key,
    required this.notifier,
    required this.onActive,
    this.onWaiting,
    this.onNone,
    this.onFailure,
    this.selector,
  });

  /// [StateNotifier] whose changes this builder listens to
  final StateNotifier<StateType, ErrorType> notifier;

  /// This is called when [notifier.state] is [Active]
  final ActiveBuilder<StateType> onActive;

  /// This is called when [notifier.state] is [Waiting]
  final WaitingBuilder<StateType>? onWaiting;

  /// This is called when [notifier.state] is [None]
  final WaitingBuilder<StateType>? onNone;

  /// This is called when [notifier.state] is [Failed]
  final FailureBuilder? onFailure;

  /// Widget is rebuild only when selector return a different value than
  /// the last one
  final Selector<StateNotifier<StateType, ErrorType>>? selector;

  /// This is called when there is a [Failed] but no [onFailure] is defined
  static GlobalFailureBuilder globalOnFailure =
      (context, error, lastStateBuild) {
    if (lastStateBuild != null) {
      return lastStateBuild;
    }

    return Container(
      color: Colors.red,
      child: Center(
        child: Text(error.toString()),
      ),
    );
  };

  /// This is called when there is [Waiting] state but no [onWaiting] is defined
  static GlobalWaitingBuilder globalOnWaiting = (_, lastStateBuild) {
    if (lastStateBuild != null) {
      return lastStateBuild;
    }

    return const Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  };

  Widget _buildNone(BuildContext context, StateType? data) {
    return onNone?.call(context, data) ?? _buildWaiting(context, data);
  }

  /// Widget that the builder returns when the notifier is busy
  Widget _buildWaiting(BuildContext context, StateType? data) {
    return onWaiting?.call(context, data) ??
        globalOnWaiting(
          context,
          data != null ? onActive(context, data) : null,
        );
  }

  /// Widget that the builder return when the notifier has an error
  Widget _buildFailure(
    BuildContext context,
    StateType? data,
    ErrorType error,
  ) {
    return onFailure?.call(context, error) ??
        globalOnFailure(
          context,
          error,
          data != null ? onActive(context, data) : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    watch(context, notifier, selector: selector);

    return switch (notifier.state) {
      None(:final data) => _buildNone(context, data),
      Waiting(:final data) => _buildWaiting(context, data),
      Active(:final data) => onActive(context, data),
      Failed(:final data, :final error) => _buildFailure(
          context,
          data,
          error,
        ),
      _ => throw StateError(notifier.state.toString()),
    };
  }
}
