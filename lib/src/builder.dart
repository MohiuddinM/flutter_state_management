import 'package:flutter/material.dart';

import 'state.dart';
import 'state_notifier.dart';

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

/// Used to select a specific property from a [Listenable]
///
/// This is used when the widget needs to rebuild only when a specific property
/// of the [Listenable] changes, rather than rebuilding on every state change.
typedef Selector<T extends Listenable> = dynamic Function(T model);

class StateNotifierBuilder<StateType, ErrorType> extends StatefulWidget {
  const StateNotifierBuilder({
    super.key,
    required this.notifier,
    required this.onActive,
    this.onWaiting,
    this.onNone,
    this.onFailure,
    this.selector,
    this.selectOnActiveOnly = true,
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

  /// Widget is rebuild only when selector returns a different value than
  /// the last one
  ///
  /// Make value returned by the selector is immutable, otherwise the widget
  /// will not rebuild when the state changes even if the value returned by
  /// the selector changes. This is because selector user ´==´ to compare the
  /// last value with the new one.
  final Selector<StateNotifier<StateType, ErrorType>>? selector;

  /// if true, selector will be called only when state is Active
  final bool selectOnActiveOnly;

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

  @override
  State<StateNotifierBuilder<StateType, ErrorType>> createState() =>
      _StateNotifierBuilderState<StateType, ErrorType>();
}

class _StateNotifierBuilderState<StateType, ErrorType>
    extends State<StateNotifierBuilder<StateType, ErrorType>> {
  dynamic lastSelection;

  Widget _buildNone(BuildContext context, StateType? data) {
    return widget.onNone?.call(context, data) ?? _buildWaiting(context, data);
  }

  /// Widget that the builder returns when the notifier is busy
  Widget _buildWaiting(BuildContext context, StateType? data) {
    return widget.onWaiting?.call(context, data) ??
        StateNotifierBuilder.globalOnWaiting(
          context,
          data != null ? widget.onActive(context, data) : null,
        );
  }

  /// Widget that the builder return when the notifier has an error
  Widget _buildFailure(
    BuildContext context,
    StateType? data,
    ErrorType error,
  ) {
    return widget.onFailure?.call(context, error) ??
        StateNotifierBuilder.globalOnFailure(
          context,
          error,
          data != null ? widget.onActive(context, data) : null,
        );
  }

  void notifierListener() {
    final state = widget.notifier.state;

    if (state is! Active && widget.selectOnActiveOnly) {
      return setState(() {});
    }

    final selector = widget.selector;

    if (selector == null) {
      return setState(() {});
    }

    final selection = selector(widget.notifier);

    if (selection == lastSelection) {
      return;
    }

    setState(() {
      lastSelection = selection;
    });
  }

  @override
  void initState() {
    super.initState();

    widget.notifier.addListener(notifierListener);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(notifierListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.notifier.state) {
      None(:final data) => _buildNone(context, data),
      Waiting(:final data) => _buildWaiting(context, data),
      Active(:final data) => widget.onActive(context, data),
      Failed(:final data, :final error) => _buildFailure(
          context,
          data,
          error,
        ),
      _ => throw StateError(widget.notifier.state.toString()),
    };
  }
}
