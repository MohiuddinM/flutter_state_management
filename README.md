## Flutter State Management
This is not a new state management solution. It is just a couple of utility classes to make it 
easier to use the Flutter framework's built-in ChangeNotifier and Listenable.

## Features

- No learning curve if you already know Flutter
- Simple package based on ChangeNotifier (No bloatware)


## Usage

Create your model class
```dart
class Counter extends StateNotifier<int, Error> {
  Counter() : super(const Loaded(data: 0));

  void increment() async {
    state = Loading(data: data);

    await Future.delayed(const Duration(seconds: 2));

    if (data > 20) {
      state = Failed(error: StateError('greater than 20'), data: data);
    } else {
      state = Loaded(data: data + 1);
    }
  }
}
```

Or if you want the state to persist across restarts
```dart
class Counter extends PersistedStateNotifier<int, int> {
  Counter() : super(IsarKeyValue(), startState: 0);

  void increment() async {
    persistedState = Loading(data: data);

    await Future.delayed(const Duration(seconds: 2));

    if (data > 20) {
      persistedState = Failed(error: StateError('greater than 20'), data: data);
    } else {
      persistedState = Loaded(data: data + 1);
    }
  }
}
```
\
\
Use builder to handle state changes in the UI
```dart
final counter = Counter();

counter.builder(
  onLoaded: (context, data) => Text(data.toString()),
),
```

Or convert your existing StatelessWidget to RStatelessWidget, and StatefulWidget to RStatefulWidget
and just watch the model inside the build method

```dart
class CounterText extends RStatelessWidget {
  @override
  Widget build(BuildContext context) {
    counter.watch(context); // watch must be called inside the build method
    return Text(data.toString());
  }
}
```