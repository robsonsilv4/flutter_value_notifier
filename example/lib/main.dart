import 'package:flutter/material.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

/// {@template theme_notifier}
/// A simple [ValueNotifier] that manages the [ThemeData] as its state.
/// {@endtemplate}
class ThemeNotifier extends ValueNotifier<ThemeData> {
  /// {@macro theme_notifier}
  ThemeNotifier() : super(_lightTheme);

  static final _lightTheme = ThemeData(
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
    ),
    brightness: Brightness.light,
  );

  static final _darkTheme = ThemeData(
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.black,
    ),
    brightness: Brightness.dark,
  );

  /// Toggles the current brightness between light and dark.
  void toggleTheme() {
    value = value.brightness == Brightness.dark ? _lightTheme : _darkTheme;
  }
}

/// {@template counter_notifier}
/// A simple [ValueNotifier] that manages an `int` as its state.
/// {@endtemplate}
class CounterNotifier extends ValueNotifier<int> {
  /// {@macro counter_notifier}
  CounterNotifier() : super(0);

  /// Increments value and notify listeners.
  void increment() => value = value + 1;

  /// Decrements value and notify listeners.
  void decrement() => value = value - 1;
}

void main() {
  runApp(const App());
}

/// {@template app}
/// A [StatelessWidget] that:
/// * uses [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) and
/// [flutter_value_notifier](https://pub.dev/packages/flutter_value_notifier)
/// to manage the state of a counter and the app theme.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const AppView(),
    );
  }
}

/// {@template app_view}
/// A [StatelessWidget] that:
/// * reacts to value changes in the [ThemeNotifier]
/// and updates the theme of the [MaterialApp].
/// * renders the [CounterPage].
/// {@endtemplate}
class AppView extends StatelessWidget {
  /// {@macro app_view}
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueNotifierBuilder<ThemeNotifier, ThemeData>(
      builder: (_, theme) {
        return MaterialApp(
          theme: theme,
          home: const CounterPage(),
        );
      },
    );
  }
}

/// {@template counter_page}
/// A [StatelessWidget] that:
/// * provides a [CounterNotifier] to the [CounterView].
/// {@endtemplate}
class CounterPage extends StatelessWidget {
  /// {@macro counter_page}
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueNotifierProvider(
      create: (_) => CounterNotifier(),
      child: const CounterView(),
    );
  }
}

/// {@template counter_view}
/// A [StatelessWidget] that:
/// * demonstrates how to consume and interact with a [CounterNotifier].
/// {@endtemplate}
class CounterView extends StatelessWidget {
  /// {@macro counter_view}
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: ValueNotifierBuilder<CounterNotifier, int>(
          builder: (context, count) {
            return Text(
              '$count',
              style: Theme.of(context).textTheme.titleLarge,
            );
          },
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              context.read<CounterNotifier>().increment();
            },
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            child: const Icon(Icons.remove),
            onPressed: () {
              context.read<CounterNotifier>().decrement();
            },
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            child: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeNotifier>().toggleTheme();
            },
          ),
        ],
      ),
    );
  }
}
