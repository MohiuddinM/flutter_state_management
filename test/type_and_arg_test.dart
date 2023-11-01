import 'package:flutter_state_management/src/type_and_arg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TypeAndArg == operator', () {
    test('returns true when types and arguments are the same', () {
      const typeAndArg1 = TypeAndArg<int>(int, 1);
      const typeAndArg2 = TypeAndArg<int>(int, 1);
      expect(typeAndArg1 == typeAndArg2, true);
    });

    test('returns true when arguments are lists', () {
      const typeAndArg1 = TypeAndArg<List<int>>(List<int>, [1, 2, 3]);
      const typeAndArg2 = TypeAndArg<List<int>>(List<int>, [1, 2, 3]);
      expect(typeAndArg1 == typeAndArg2, true);
    });

    test('returns true when arguments are sets', () {
      const typeAndArg1 = TypeAndArg<Set<int>>(Set<int>, {1, 2, 3});
      const typeAndArg2 = TypeAndArg<Set<int>>(Set<int>, {1, 2, 3});
      expect(typeAndArg1 == typeAndArg2, true);
    });

    test('returns true when arguments are maps', () {
      const typeAndArg1 = TypeAndArg<Map<String, int>>(
        Map<String, int>,
        {'one': 1, 'two': 2, 'three': 3},
      );
      const typeAndArg2 = TypeAndArg<Map<String, int>>(
        Map<String, int>,
        {'one': 1, 'two': 2, 'three': 3},
      );
      expect(typeAndArg1 == typeAndArg2, true);
    });

    test('returns false when types are different', () {
      const typeAndArg1 = TypeAndArg<int>(int, 1);
      const typeAndArg2 = TypeAndArg<String>(String, '1');
      // ignore: unrelated_type_equality_checks
      expect(typeAndArg1 == typeAndArg2, false);
    });

    test('returns false when arguments are different', () {
      const typeAndArg1 = TypeAndArg<int>(int, 1);
      const typeAndArg2 = TypeAndArg<int>(int, 2);
      expect(typeAndArg1 == typeAndArg2, false);
    });

    test('returns false when arguments are lists with different items', () {
      const typeAndArg1 = TypeAndArg<List<int>>(List<int>, [1, 2, 3]);
      const typeAndArg2 = TypeAndArg<List<int>>(List<int>, [1, 2, 4]);
      expect(typeAndArg1 == typeAndArg2, false);
    });

    test('returns false when arguments are lists with different lengths', () {
      const typeAndArg1 = TypeAndArg<List<int>>(List<int>, [1, 2, 3]);
      const typeAndArg2 = TypeAndArg<List<int>>(List<int>, [1, 2]);
      expect(typeAndArg1 == typeAndArg2, false);
    });

    test('returns false when arguments are sets with different items', () {
      const typeAndArg1 = TypeAndArg<Set<int>>(Set<int>, {1, 2, 3});
      const typeAndArg2 = TypeAndArg<Set<int>>(Set<int>, {1, 2, 4});
      expect(typeAndArg1 == typeAndArg2, false);
    });

    test('returns false when arguments are sets with different lengths', () {
      const typeAndArg1 = TypeAndArg<Set<int>>(Set<int>, {1, 2, 3});
      const typeAndArg2 = TypeAndArg<Set<int>>(Set<int>, {1, 2});
      expect(typeAndArg1 == typeAndArg2, false);
    });

    test('returns false when arguments are maps with different items', () {
      const typeAndArg1 = TypeAndArg<Map<String, int>>(
          Map<String, int>, {'one': 1, 'two': 2, 'three': 3});
      const typeAndArg2 = TypeAndArg<Map<String, int>>(
          Map<String, int>, {'one': 1, 'two': 2, 'four': 4});
      expect(typeAndArg1 == typeAndArg2, false);
    });

    test('returns false when arguments are maps with different lengths', () {
      const typeAndArg1 = TypeAndArg<Map<String, int>>(
        Map<String, int>,
        {'one': 1, 'two': 2, 'three': 3},
      );
      const typeAndArg2 = TypeAndArg<Map<String, int>>(
        Map<String, int>,
        {'one': 1, 'two': 2},
      );
      expect(typeAndArg1 == typeAndArg2, false);
    });
  });

  group('TypeAndArg hashCode', () {
    test('returns same hashCode for equal instances', () {
      const typeAndArg1 = TypeAndArg<int>(int, 1);
      const typeAndArg2 = TypeAndArg<int>(int, 1);
      expect(typeAndArg1.hashCode, typeAndArg2.hashCode);
    });

    test('returns different hashCode for different instances', () {
      const typeAndArg1 = TypeAndArg<int>(int, 1);
      const typeAndArg2 = TypeAndArg<int>(int, 2);
      expect(typeAndArg1.hashCode, isNot(typeAndArg2.hashCode));
    });
  });
}
