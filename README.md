<p align="center">
<img src="https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/apple/325/high-voltage_26a1.png" height="100" alt="Flutter Value Notifier" />
</p>

<p align="center">
<a href="https://pub.dev/packages/flutter_value_notifier"><img src="https://img.shields.io/pub/v/flutter_value_notifier.svg" alt="Pub"></a>
<a href="https://github.com/robsonsilv4/flutter_value_notifier/actions"><img src="https://github.com/robsonsilv4/flutter_value_notifier/workflows/build/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/robsonsilv4/flutter_value_notifier"><img src="https://codecov.io/gh/robsonsilv4/flutter_value_notifier/branch/master/graph/badge.svg" alt="Codecov"></a>
<a href="https://github.com/robsonsilv4/bloc"><img src="https://img.shields.io/github/stars/robsonsilv4/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Stars on Github"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
</p>

---

Widgets that make it easy to use [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) ⚡. Built to work with Flutter only!

Based on [flutter_bloc](https://pub.dev/packages/flutter_bloc) from [bloc library](https://bloclibrary.dev/).

## Usage

Lets take a look at how to use `ValueNotifierProvider` to provide a `CounterNotifier` to a `CounterPage` and react to value changes with `ValueNotifierBuilder`.

### counter_notifier.dart

```dart
class CounterNotifier extends ValueNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => value = value + 1;
  void decrement() => value = value - 1;
}
```

### main.dart

```dart
void main() => runApp(CounterApp());

class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ValueNotifierProvider(
        create: (_) => CounterNotifier(),
        child: CounterPage(),
      ),
    );
  }
}
```

### counter_page.dart

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: ValueNotifierBuilder<CounterNotifier, int>(
        builder: (_, count) => Center(child: Text('$count')),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => context.read<CounterNotifier>().increment(),
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            child: const Icon(Icons.remove),
            onPressed: () => context.read<CounterNotifier>().decrement(),
          ),
        ],
      ),
    );
  }
}
```

At this point we have successfully separated our presentational layer from our business logic layer. Notice that the `CounterPage` widget knows nothing about what happens when a user taps the buttons. The widget simply notifies the `CounterNotifier` that the user has pressed either the increment or decrement button.

## ValueNotifier Widgets

### ValueNotifierProvider

**ValueNotifierProvider** is a Flutter widget which provides a notifier to its children via `ValueNotifierProvider.of<T>(context)`. It is used as a dependency injection (DI) widget so that a single instance of a notifier can be provided to multiple widgets within a subtree.

In most cases, `ValueNotifierProvider` should be used to create new notifiers which will be made available to the rest of the subtree. In this case, since `ValueNotifierProvider` is responsible for creating the notifier, it will automatically handle closing it.

```dart
ValueNotifierProvider(
  create: (_) => NotifierA(),
  child: ChildA(),
);
```

By default, ValueNotifierProvider will create the notifier lazily, meaning `create` will get executed when the notifier is looked up via `ValueNotifierProvider.of<NotifierA>(context)`.

To override this behavior and force `create` to be run immediately, `lazy` can be set to `false`.

```dart
ValueNotifierProvider(
  lazy: false,
  create: (_) => NotifierA(),
  child: ChildA(),
);
```

In some cases, `ValueNotifierProvider` can be used to provide an existing notifier to a new portion of the widget tree. This will be most commonly used when an existing `notifier` needs to be made available to a new route. In this case, `ValueNotifierProvider` will not automatically close the notifier since it did not create it.

```dart
ValueNotifierProvider.value(
  value: ValueNotifierProvider.of<NotifierA>(context),
  child: ScreenA(),
);
```

then from either `ChildA`, or `ScreenA` we can retrieve `NotifierA` with:

```dart
// with extensions
context.read<NotifierA>();

// without extensions
ValueNotifierProvider.of<NotifierA>(context);
```

The above snippets result in a one time lookup and the widget will not be notified of changes. To retrieve the instance and subscribe to subsequent value changes use:

```dart
// with extensions
context.watch<NotifierA>();

// without extensions
ValueNotifierProvider.of<NotifierA>(context, listen: true);
```

In addition, `context.select` can be used to retrieve part of a value and react to changes only when the selected part changes.

```dart
final isPositive = context.select<CounterNotifier>((notifier) => notifier.value >= 0);
```

The snippet above will only rebuild if the value of the `CounterNotifier` changes from positive to negative or vice versa and is functionally identical to using a `ValueNotifierSelector`.

### MultiValueNotifierProvider

**MultiValueNotifierProvider** is a Flutter widget that merges multiple `ValueNotifierProvider` widgets into one.
`MultiValueNotifierProvider` improves the readability and eliminates the need to nest multiple `ValueNotifierProviders`.
By using `MultiValueNotifierProvider` we can go from:

```dart
ValueNotifierProvider<NotifierA>(
  create: (_) => NotifierA(),
  child: ValueNotifierProvider<NotifierB>(
    create: (_) => NotifierB(),
    child: ValueNotifierProvider<NotifierC>(
      create: (_) => NotifierC(),
      child: ChildA(),
    )
  )
)
```

to:

```dart
MultiValueNotifierProvider(
  providers: [
    ValueNotifierProvider<NotifierA>(
      create: (_) => NotifierA(),
    ),
    ValueNotifierProvider<NotifierB>(
      create: (_) => NotifierB(),
    ),
    ValueNotifierProvider<NotifierC>(
      create: (_) => NotifierC(),
    ),
  ],
  child: ChildA(),
)
```

### ValueNotifierBuilder

**ValueNotifierBuilder** is a Flutter widget which requires a `ValueNotifier` and a `builder` function. `ValueNotifierBuilder` handles building the widget in response to new values. `ValueNotifierBuilder` is very similar to `ValueListenableBuilder` but has a more simple API to reduce the amount of boilerplate code needed. The `builder` function will potentially be called many times and should be a [pure function](https://en.wikipedia.org/wiki/Pure_function) that returns a widget in response to the value.

See `ValueNotifierListener` if you want to "do" anything in response to value changes such as navigation, showing a dialog, etc...

If the `notifier` parameter is omitted, `ValueNotifierBuilder` will automatically perform a lookup using `ValueNotifierProvider` and the current `BuildContext`.

```dart
ValueNotifierBuilder<NotifierA, NotifierAState>(
  builder: (_, value) {
    // return widget here based on NotifierA's value
  }
)
```

Only specify the notifier if you wish to provide a ValueNotifier that will be scoped to a single widget and isn't accessible via a parent `ValueNotifierProvider` and the current `BuildContext`.

```dart
ValueNotifierBuilder<NotifierA, NotifierAState>(
  notifier: notifier, // provide the local ValueNotifier instance
  builder: (_, value) {
    // return widget here based on NotifierA's value
  }
)
```

For fine-grained control over when the `builder` function is called an optional `buildWhen` can be provided. `buildWhen` takes the previous ValueNotifier value and current ValueNotifier value and returns a boolean. If `buildWhen` returns true, `builder` will be called with `value` and the widget will rebuild. If `buildWhen` returns false, `builder` will not be called with `value` and no rebuild will occur.

```dart
ValueNotifierBuilder<NotifierA, NotifierAState>(
  buildWhen: (previousValue, value) {
    // return true/false to determine whether or not
    // to rebuild the widget with value
  },
  builder: (_, value) {
    // return widget here based on NotifierA's value
  }
)
```

### ValueNotifierSelector

**ValueNotifierSelector** is a Flutter widget which is analogous to `ValueNotifierBuilder` but allows developers to filter updates by selecting a new value based on the current notifier value. Unnecessary builds are prevented if the selected value does not change. The selected value must be immutable in order for `ValueNotifierSelector` to accurately determine whether `builder` should be called again.

If the `notifier` parameter is omitted, `ValueNotifierSelector` will automatically perform a lookup using `ValueNotifierProvider` and the current `BuildContext`.

```dart
ValueNotifierSelector<NotifierA, NotifierAState, SelectedState>(
  selector: (value) {
    // return selected value based on the provided value.
  },
  builder: (_, value) {
    // return widget here based on the selected value.
  },
)
```

### ValueNotifierListener

**ValueNotifierListener** is a Flutter widget which takes a `ValueNotifierWidgetListener` and an optional `notifier` and invokes the `listener` in response to value changes in the notifier. It should be used for functionality that needs to occur once per value change such as navigation, showing a `SnackBar`, showing a `Dialog`, etc...

`listener` is only called once for each value change (**NOT** including the initial value) unlike `builder` in `ValueNotifierBuilder` and is a `void` function.

If the notifier parameter is omitted, `ValueNotifierListener` will automatically perform a lookup using `ValueNotifierProvider` and the current `BuildContext`.

```dart
ValueNotifierListener<NotifierA, NotifierAState>(
  listener: (context, value) {
    // do stuff here based on NotifierA's value
  },
  child: Container(),
)
```

Only specify the notifier if you wish to provide a notifier that is otherwise not accessible via `ValueNotifierProvider` and the current `BuildContext`.

```dart
ValueNotifierListener<NotifierA, NotifierAState>(
  notifier: notifier,
  listener: (context, value) {
    // do stuff here based on NotifierA's value
  }
)
```

For fine-grained control over when the `listener` function is called an optional `listenWhen` can be provided. `listenWhen` takes the previous notifier value and current notifier value and returns a boolean. If `listenWhen` returns true, `listener` will be called with `value`. If `listenWhen` returns false, `listener` will not be called with `value`.

```dart
ValueNotifierListener<NotifierA, NotifierAState>(
  listenWhen: (previousValue, value) {
    // return true/false to determine whether or not
    // to call listener with value
  },
  listener: (context, value) {
    // do stuff here based on NotifierA's value
  },
  child: Container(),
)
```

### MultiValueNotifierListener

**MultiValueNotifierListener** is a Flutter widget that merges multiple `ValueNotifierListener` widgets into one.
`MultiValueNotifierListener` improves the readability and eliminates the need to nest multiple `ValueNotifierListeners`.
By using `MultiValueNotifierListener` we can go from:

```dart
ValueNotifierListener<NotifierA, NotifierAState>(
  listener: (context, value) {},
  child: ValueNotifierListener<NotifierB, NotifierBState>(
    listener: (context, value) {},
    child: ValueNotifierListener<NotifierC, NotifierCState>(
      listener: (context, value) {},
      child: ChildA(),
    ),
  ),
)
```

to:

```dart
MultiValueNotifierListener(
  listeners: [
    ValueNotifierListener<NotifierA, NotifierAState>(
      listener: (context, value) {},
    ),
    ValueNotifierListener<NotifierB, NotifierBState>(
      listener: (context, value) {},
    ),
    ValueNotifierListener<NotifierC, NotifierCState>(
      listener: (context, value) {},
    ),
  ],
  child: ChildA(),
)
```

### ValueNotifierConsumer

**ValueNotifierConsumer** exposes a `builder` and `listener` in order react to new values. `ValueNotifierConsumer` is analogous to a nested `ValueNotifierListener` and `ValueNotifierBuilder` but reduces the amount of boilerplate needed. `ValueNotifierConsumer` should only be used when it is necessary to both rebuild UI and execute other reactions to value changes in the `notifier`. `ValueNotifierConsumer` takes a required `ValueNotifierWidgetBuilder` and `ValueNotifierWidgetListener` and an optional `notifier`, `ValueNotifierBuilderCondition`, and `ValueNotifierListenerCondition`.

If the `notifier` parameter is omitted, `ValueNotifierConsumer` will automatically perform a lookup using
`ValueNotifierProvider` and the current `BuildContext`.

```dart
ValueNotifierConsumer<NotifierA, NotifierAState>(
  listener: (context, value) {
    // do stuff here based on NotifierA's value
  },
  builder: (_, value) {
    // return widget here based on NotifierA's value
  }
)
```

An optional `listenWhen` and `buildWhen` can be implemented for more granular control over when `listener` and `builder` are called. The `listenWhen` and `buildWhen` will be invoked on each `notifier` `value` change. They each take the previous `value` and current `value` and must return a `bool` which determines whether or not the `builder` and/or `listener` function will be invoked. The previous `value` will be initialized to the `value` of the `notifier` when the `ValueNotifierConsumer` is initialized. `listenWhen` and `buildWhen` are optional and if they aren't implemented, they will default to `true`.

```dart
ValueNotifierConsumer<NotifierA, NotifierAState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether or not
    // to invoke listener with value
  },
  listener: (context, value) {
    // do stuff here based on NotifierA's value
  },
  buildWhen: (previous, current) {
    // return true/false to determine whether or not
    // to rebuild the widget with value
  },
  builder: (_, value) {
    // return widget here based on NotifierA's value
  }
)
```

### DependencyProvider

**DependencyProvider** is a Flutter widget which provides a dependency to its children via `DependencyProvider.of<T>(context)`. It is used as a dependency injection (DI) widget so that a single instance of a dependency can be provided to multiple widgets within a subtree. `ValueNotifierProvider` should be used to provide notifier whereas `DependencyProvider` should only be used for dependencies.

```dart
DependencyProvider(
  create: (_) => DependencyA(),
  child: ChildA(),
);
```

then from `ChildA` we can retrieve the `Dependency` instance with:

```dart
// with extensions
context.read<DependencyA>();

// without extensions
DependencyProvider.of<DependencyA>(context)
```

### MultiDependencyProvider

**MultiDependencyProvider** is a Flutter widget that merges multiple `DependencyProvider` widgets into one.
`MultiDependencyProvider` improves the readability and eliminates the need to nest multiple `DependencyProvider`.
By using `MultiDependencyProvider` we can go from:

```dart
DependencyProvider<DependencyA>(
  create: (_) => DependencyA(),
  child: DependencyProvider<DependencyB>(
    create: (_) => DependencyB(),
    child: DependencyProvider<DependencyC>(
      create: (_) => DependencyC(),
      child: ChildA(),
    )
  )
)
```

to:

```dart
MultiDependencyProvider(
  providers: [
    DependencyProvider<DependencyA>(
      create: (_) => DependencyA(),
    ),
    DependencyProvider<DependencyB>(
      create: (_) => DependencyB(),
    ),
    DependencyProvider<DependencyC>(
      create: (_) => DependencyC(),
    ),
  ],
  child: ChildA(),
)
```

## Dart Versions

- Dart 2: >=2.17.0
- Flutter 3: >=3.0.0

## Maintainers

- [Robson Silva](https://github.com/robsonsilv4)

Thanks to Felix Angelov ([@felangel](https://github.com/felangel)) and all [bloc library contributors](https://github.com/felangel/bloc/graphs/contributors).
