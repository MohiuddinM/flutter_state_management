import 'package:flutter/material.dart';
import 'package:flutter_state_management/flutter_state_management.dart';
import 'package:isar_key_value/isar_key_value.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends RStatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = counterResolver();

    counter.watch(context,  selector: (model) => model.state);

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You have pushed the button this many times:'),
              counter.builder(
                onLoaded: (context, data) => Text(
                  data.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: counter.increment,
        ),
      ),
    );
  }
}

final counterResolver = Resolver((arg) => Counter());

class Counter extends PersistedStateNotifier<int> {
  Counter() : super(IsarKeyValue(), startState: 0);

  void increment() => persistedState = Loaded(data: data + 1);
}
