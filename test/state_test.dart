import 'package:flutter_state_management/src/state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Event', () {
    test('None should return correct data and error', () {
      const none = None<int>(data: 1);
      expect(none.data, equals(1));
      expect(none.error, isNull);
    });

    test('Active should return correct data and error', () {
      const active = Active<int>(data: 2);
      expect(active.data, equals(2));
      expect(active.error, isNull);
    });

    test('Waiting should return correct data and error', () {
      const waiting = Waiting<int>(data: 3);
      expect(waiting.data, equals(3));
      expect(waiting.error, isNull);
    });

    test('Failed should return correct data and error', () {
      const failed = Failed<int, String>(error: 'Error', data: 4);
      expect(failed.data, equals(4));
      expect(failed.error, equals('Error'));
    });

    test('when should return correct value based on event type', () {
      const none = None<int>(data: 1);
      const active = Active<int>(data: 2);
      const waiting = Waiting<int>(data: 3);
      const failed = Failed<int, String>(error: 'Error', data: 4);

      expect(none.when(none: (event) => event.data), equals(1));
      expect(active.when(active: (event) => event.data), equals(2));
      expect(waiting.when(waiting: (event) => event.data), equals(3));
      expect(failed.when(failed: (event) => event.data), equals(4));
    });
  });
}
