sealed class Event<StateType, ErrorType> {
  StateType? get data;

  ErrorType? get error;
}

final class None<StateType> implements Event<StateType, Never> {
  const None({this.data});

  @override
  final StateType? data;

  @override
  Never? get error => null;

  @override
  bool operator ==(Object other) {
    return other is None<StateType> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Idle<$StateType>(data: $data)';
}

final class Active<StateType> implements Event<StateType, Never> {
  const Active({required this.data});

  @override
  final StateType data;

  @override
  Never? get error => null;

  @override
  bool operator ==(Object other) {
    return other is Active<StateType> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Loaded<$StateType>(data: $data)';
}

final class Waiting<StateType> implements Event<StateType, Never> {
  const Waiting({this.data});

  @override
  final StateType? data;

  @override
  Never? get error => null;

  @override
  bool operator ==(Object other) {
    return other is Waiting<StateType> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Loading<$StateType>(data: $data)';
}

final class Failed<StateType, ErrorType>
    implements Event<StateType, ErrorType> {
  const Failed({required this.error, this.data});

  @override
  final ErrorType error;

  @override
  final StateType? data;

  @override
  bool operator ==(Object other) {
    return other is Failed<StateType, ErrorType> &&
        other.error == error &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(error, data);

  @override
  String toString() => 'Failed<$StateType, $ErrorType>(data: $data, $error)';
}

extension DataEventX<StateType, ErrorType> on Event<StateType, ErrorType> {
  T? when<T>({
    T Function(Active<StateType> data)? active,
    T Function(None<StateType> data)? none,
    T Function(Waiting<StateType> data)? waiting,
    T Function(Failed<StateType, ErrorType> data)? failed,
  }) {
    return switch (this) {
      Waiting() => waiting?.call(this as Waiting<StateType>),
      None() => none?.call(this as None<StateType>),
      Active() => active?.call(this as Active<StateType>),
      Failed() => failed?.call(this as Failed<StateType, ErrorType>),
      _ => null,
    };
  }
}

@Deprecated('use None')
typedef Idle<T> = None<T>;

@Deprecated('use Active')
typedef Loaded<T> = Active<T>;

@Deprecated('use Waiting')
typedef Loading<T> = Waiting<T>;
