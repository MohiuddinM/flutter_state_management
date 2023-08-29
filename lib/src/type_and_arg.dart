import 'package:flutter/foundation.dart';

/// Acts as a key for resolver cache
///
/// For cache to return cache value, both type and arg must match with a
/// stored version
final class TypeAndArg<T> {
  final Type type;
  final dynamic arg;

  const TypeAndArg(this.type, this.arg);

  @override
  bool operator ==(Object other) {
    if (other is! TypeAndArg || other.type != type) {
      return false;
    }

    if (other.arg is List && arg is List) {
      return listEquals(other.arg, arg);
    }

    if (other.arg is Set && arg is Set) {
      return setEquals(other.arg, arg);
    }

    if (other.arg is Map && arg is Map) {
      return mapEquals(other.arg, arg);
    }

    return other.arg == arg;
  }

  @override
  int get hashCode => Object.hash(type, arg);
}
