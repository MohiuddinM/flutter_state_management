sealed class Event<StateType, ErrorType> {
  StateType? get data;

  ErrorType? get error;
}

final class Idle<StateType> implements Event<StateType, Never> {
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

final class Loaded<StateType> implements Event<StateType, Never> {
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

final class Loading<StateType> implements Event<StateType, Never> {
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
}

extension DataEventX<StateType, ErrorType> on Event<StateType, ErrorType> {
  T? when<T>({
    T Function(Loaded<StateType> data)? loaded,
    T Function(Idle<StateType> data)? idle,
    T Function(Loading<StateType> data)? loading,
    T Function(Failed<StateType, ErrorType> data)? failure,
  }) {
    return switch (this) {
      Loading() => loading?.call(this as Loading<StateType>),
      Idle() => idle?.call(this as Idle<StateType>),
      Loaded() => loaded?.call(this as Loaded<StateType>),
      Failed() => failure?.call(this as Failed<StateType, ErrorType>),
      _ => null,
    };
  }
}
