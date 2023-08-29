import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_state_management/src/state_notifier.dart';
import 'package:flutter_state_management/src/reactive.dart';
import 'builder.dart';

extension StateNotifierExtensions<S> on StateNotifier<S> {
  Widget builder({
    Key? key,
    required LoadedBuilder<S> onLoaded,
    LoadingBuilder<S>? onLoading,
    FailureBuilder? onFailure,
    Selector<StateNotifier<S>>? selector,
  }) {
    return StateNotifierBuilder<S>(
      key: key,
      onLoaded: onLoaded,
      onFailure: onFailure,
      onLoading: onLoading,
      selector: selector,
      notifier: this,
    );
  }
}
