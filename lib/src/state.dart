sealed class DataEvent<T> {
  T? get data;
}

final class Idle<T> implements DataEvent<T> {
  const Idle({this.data});

  @override
  final T? data;

  @override
  bool operator ==(Object other) {
    return other is Idle<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

final class Loaded<T> implements DataEvent<T> {
  const Loaded({required this.data});

  @override
  final T data;

  @override
  bool operator ==(Object other) {
    return other is Loaded<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

final class Loading<T> implements DataEvent<T> {
  const Loading({this.data});

  @override
  final T? data;

  @override
  bool operator ==(Object other) {
    return other is Loading<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

final class Failure<T> implements DataEvent<T> {
  const Failure({required this.reason, this.data});

  final FailureReason reason;

  @override
  final T? data;

  @override
  bool operator ==(Object other) {
    return other is Failure<T> && other.reason == reason && other.data == data;
  }

  @override
  int get hashCode => Object.hash(reason, data);
}

class FailureReason {
  const FailureReason(this.code);

  final int code;

  @override
  bool operator ==(Object other) {
    return other is FailureReason && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}