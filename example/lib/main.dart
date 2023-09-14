import 'package:flutter/material.dart';
import 'package:flutter_state_management/flutter_state_management.dart';
import 'package:isar_key_value/isar_key_value.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends RStatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = counterResolver();

    counter.watch(context, selector: (model) => model.state);

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have pushed the button this many times:'),
              counter.builder(
                onLoaded: (context, data) => Text(
                  data.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                onLoading: (_, __) => const CircularProgressIndicator(),
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

final counterResolver = Resolver((arg) => Counter());

class Counter extends PersistedStateNotifier<int, int> {
  Counter() : super(IsarKeyValue(), startState: 0);

  // Overriding persistence key is useful for versioning or
  // for differentiating between models of the same type
  @override
  String get key => '$runtimeType.1';

  void increment() async {
    persistedState = Loading(data: data);
    await Future.delayed(const Duration(seconds: 2));
    persistedState = Loaded(data: data + 1);
  }
}

class _Counter extends StateNotifier<int, Error> {
  _Counter() : super(const Loaded(data: 0));

  void increment() async {
    setLoaded(data);

    await Future.delayed(const Duration(seconds: 2));

    if (data > 20) {
      setFailure(StateError('greater than 20'));
    } else {
      setLoaded(data + 1);
    }
  }
}
