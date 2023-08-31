sealed class DataEvent<StateType, ErrorType> {
  StateType? get data;

  ErrorType? get error;
}

final class Idle<StateType> implements DataEvent<StateType, Never> {
  const Idle({this.data});

  @override
  final StateType? data;

  @override
  Never? get error => null;

  @override
  bool operator ==(Object other) {
    return other is Idle<StateType> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

final class Loaded<StateType> implements DataEvent<StateType, Never> {
  const Loaded({required this.data});

  @override
  final StateType data;

  @override
  Never? get error => null;

  @override
  bool operator ==(Object other) {
    return other is Loaded<StateType> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

final class Loading<StateType> implements DataEvent<StateType, Never> {
  const Loading({this.data});

  @override
  final StateType? data;

  @override
  Never? get error => null;

  @override
  bool operator ==(Object other) {
    return other is Loading<StateType> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

final class Failure<StateType, ErrorType>
    implements DataEvent<StateType, ErrorType> {
  const Failure({required this.error, this.data});

  @override
  final ErrorType error;

  @override
  final StateType? data;

  @override
  bool operator ==(Object other) {
    return other is Failure<StateType, ErrorType> &&
        other.error == error &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(error, data);
}
