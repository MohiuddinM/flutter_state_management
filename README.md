## Flutter State Management
This is not a new state management solution. It is just a couple of utility classes to make it 
easier to use the Flutter framework's built-in ChangeNotifier and Listenable.

## Features

- No learning curve if you already know Flutter
- Simple package based on ChangeNotifier (No bloatware)


## Usage

Create your model class
```dart
class Counter extends PersistedStateNotifier<int> {
  Counter() : super(IsarKeyValue(), startState: 0);

  void increment() => persistedState = Loaded(data: data + 1);
}
```
\
\
Use builder to handle state changes in the UI
```dart

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