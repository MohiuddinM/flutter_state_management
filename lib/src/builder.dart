import 'package:flutter/material.dart';

import 'state.dart';
import 'state_notifier.dart';
import 'reactive.dart';

/// Used when notifier updates its state and widget needs to rebuild with
/// new data
typedef LoadedBuilder<T> = Widget Function(BuildContext context, T data);

/// Used when [StateNotifier.state] is a [Loading] and widget needs to rebuild
/// with busy widget (e.g. progress indicator)
typedef LoadingBuilder<T> = Widget Function(BuildContext context, T? data);

/// Used when [StateNotifier.state] is a [Failure] and an error widget should
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
/// Used when onLoading is not provided to a [StateNotifierBuilder]
typedef GlobalLoadingBuilder = Widget Function(
  BuildContext context,
  Widget? lastStateBuild,
);

class StateNotifierBuilder<StateType, ErrorType> extends RStatelessWidget {
  const StateNotifierBuilder({
    Key? key,
    required this.notifier,
    required this.onLoaded,
    this.onLoading,
    this.onFailure,
    this.selector,
  }) : super(key: key);

  /// [StateNotifier] whose changes this builder listens to
  final StateNotifier<StateType, ErrorType> notifier;

  /// This is called when [notifier.state] is [Loaded]
  final LoadedBuilder<StateType> onLoaded;

  /// This is called when [notifier.state] is [Loading]
  final LoadingBuilder<StateType>? onLoading;

  /// This is called when [notifier.state] is [Failure]
  final FailureBuilder? onFailure;

  /// Widget is rebuild only when selector return a different value than
  /// the last one
  final Selector<StateNotifier<StateType, ErrorType>>? selector;

  /// This is called when there is a [Failure] but no [onFailure] is defined
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

  /// This is called when there is [Loading] state but no [onLoading] is defined
  static GlobalLoadingBuilder globalOnLoading = (_, lastStateBuild) {
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

  /// Widget that the builder returns when the notifier is busy
  Widget _buildLoading(BuildContext context, StateType? data) {
    return onLoading?.call(context, data) ??
        globalOnLoading(
          context,
          data != null ? onLoaded(context, data) : null,
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
          data != null ? onLoaded(context, data) : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    watch(context, notifier, selector: selector);

    return switch (notifier.state) {
      Loading(:final data) || Idle(:final data) => _buildLoading(context, data),
      Loaded(:final data) => onLoaded(context, data),
      Failure(:final data, :final error) => _buildFailure(
          context,
          data,
          error,
        ),
      _ => throw StateError(notifier.state.toString()),
    };
  }
}
