import 'package:flutter/foundation.dart';
import 'package:flutter_state_management/src/listenable_to_stream.dart';
import 'package:flutter_test/flutter_test.dart';

class TestValueListenable extends ValueNotifier<int> {
  TestValueListenable(super.value);
}

void main() {
  test(
    'asStream emits all elements from value listenable from the time stream is created',
    () {
      final items = [0, 2, 4, 6, 8, 10];
      final notifier = TestValueListenable(0);
      final notifierStream = notifier.asStream();

      for (var e in items) {
        notifier.value = e;
      }

      expect(notifierStream, emitsInOrder(items));
    },
  );
}
