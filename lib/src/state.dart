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
    T Function(Loaded<StateType> data)? onLoaded,
    T Function(Idle<StateType> data)? onIdle,
    T Function(Loading<StateType> data)? onLoading,
    T Function(Failed<StateType, ErrorType> data)? onFailure,
  }) {
    return switch (this) {
      Loading() => onLoading?.call(this as Loading<StateType>),
      Idle() => onIdle?.call(this as Idle<StateType>),
      Loaded() => onLoaded?.call(this as Loaded<StateType>),
      Failed() => onFailure?.call(this as Failed<StateType, ErrorType>),
      _ => null,
    };
  }
}
