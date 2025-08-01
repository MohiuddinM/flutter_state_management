import 'package:flutter/material.dart';
import 'package:flutter_state_management/flutter_state_management.dart';
import 'package:isar_key_value/isar_key_value.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have pushed the button this many times:'),
              counter.builder(
                selector: (counter) => counter.data,
                onActive: (context, data) => Text(
                  data.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                onWaiting: (_, __) => const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: counter.increment,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

final counter = Counter();

class Counter extends PersistedStateNotifier<int, int> {
  Counter() : super(IsarKeyValueStore(), startState: 0);

  // Overriding persistence key is useful for versioning or
  // for differentiating between models of the same type
  @override
  String get key => '$runtimeType.1';

  void increment() async {
    setWaiting();
    await Future.delayed(const Duration(seconds: 2));
    setActive(data + 1);
  }
}

class IntCounter extends StateNotifier<int, Error> {
  IntCounter() : super(const Active(data: 0));

  void increment() async {
    setActive(data);

    await Future.delayed(const Duration(seconds: 2));

    if (data > 20) {
      setFailed(StateError('greater than 20'));
    } else {
      setActive(data + 1);
    }
  }
}

class IsarKeyValueStore extends IsarKeyValue implements KeyValueStore {}
