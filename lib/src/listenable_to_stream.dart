import 'dart:async';

import 'package:flutter/foundation.dart';

extension ValueListenableToStreamX<T> on ValueListenable<T> {
  /// Returns a [Stream] that emits all value changes from this
  /// [ValueListenable]
  ///
  /// First item in the stream will be the value of ValueListenable at the time
  /// Last item in the stream will be the value of ValueListenable to the time
  /// the stream is cancelled.
  Stream<T> asStream() {
    final controller = StreamController<T>()..add(value);

    void listener() {
      controller.add(value);
    }

    addListener(listener);

    controller.done.then(
      (_) async => removeListener(listener),
    );

    return controller.stream;
  }
}
