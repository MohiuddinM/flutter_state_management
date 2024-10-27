## Flutter State Management
Just a couple of utility classes to make it easier to use Flutter framework's built-in 
[ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) 
and [Listenable](https://api.flutter.dev/flutter/foundation/Listenable-class.html) for state management.

## Features
- No learning curve if you already know Flutter
- Simple package based on ChangeNotifier (No bloatware)


## Usage

Create your model class
```dart
class Counter extends StateNotifier<int, String> {
  Counter() : super(const Active(data: 0));

  void increment() async {
    setWaiting();

    await Future.delayed(const Duration(seconds: 2));

    if (data > 20) {
     setFailed('greater than 20');
    } else {
      setActive(data + 1);
    }
  }
}
```

Or if you want the state to persist across restarts
```dart
class Counter extends PersistedStateNotifier<int, String> {
  Counter() : super(IsarKeyValue(), startState: 0);

  void increment() async {
    setWaiting();

    await Future.delayed(const Duration(seconds: 2));

    if (data > 20) {
      setFailed('greater than 20');
    } else {
      setActive(data + 1);
    }
  }
}
```

## Handle State Changes in UI
#### To only rebuild specific parts:
1. Use [ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) from the Flutter framework:
```dart
final counter = Counter();

ValueListenableBuilder(
  valueListenable: counter,
  child: Text()
  builder: (context, state, child) => // return updated UI here (can also use counter.builderArg here)
  child: const Text('Hello'),
  ),
);
```
You can also use **builderArg** helper:
```dart
builder: counter.builderArg(
  onActive: ,
  onWaiting: ,
  onNone: ,
  onFailure: ,
),
```

2. Or use StateNotifierBuilder that comes with this package and is more user friendly:
```dart
final counter = Counter();

counter.builder(
  onActive: (context, data) => Text(data.toString()),
),
```

\
\

#### To rebuild whole widget
Convert your existing StatelessWidget to RStatelessWidget, and StatefulWidget to RStatefulWidget 
and and just watch the model inside the build method:
```dart
class CounterText extends RStatelessWidget {
  @override
  Widget build(BuildContext context) {
    counter.watch(context); // call watch inside the build method (do not use any if) 
    return Text(data.toString());
  }
}
```
