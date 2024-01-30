import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_state_management/src/state_notifier.dart';
import 'package:flutter_state_management/src/reactive.dart';
import 'builder.dart';

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
}
