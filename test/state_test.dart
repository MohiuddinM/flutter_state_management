import 'package:flutter_state_management/src/state.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('Event', () {
    test('Idle should return correct data and error', () {
      const idle = Idle<int>(data: 1);
      expect(idle.data, equals(1));
      expect(idle.error, isNull);
    });

    test('Loaded should return correct data and error', () {
      const loaded = Loaded<int>(data: 2);
      expect(loaded.data, equals(2));
      expect(loaded.error, isNull);
    });

    test('Loading should return correct data and error', () {
      const loading = Loading<int>(data: 3);
      expect(loading.data, equals(3));
      expect(loading.error, isNull);
    });

    test('Failed should return correct data and error', () {
      const failed = Failed<int, String>(error: 'Error', data: 4);
      expect(failed.data, equals(4));
      expect(failed.error, equals('Error'));
    });

    test('when should return correct value based on event type', () {
      const idle = Idle<int>(data: 1);
      const loaded = Loaded<int>(data: 2);
      const loading = Loading<int>(data: 3);
      const failed = Failed<int, String>(error: 'Error', data: 4);

      expect(idle.when(onIdle: (event) => event.data), equals(1));
      expect(loaded.when(onLoaded: (event) => event.data), equals(2));
      expect(loading.when(onLoading: (event) => event.data), equals(3));
      expect(failed.when(onFailure: (event) => event.data), equals(4));
    });
  });
}
