import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

class MockValueNotifier<V> extends ValueNotifier<V> {
  MockValueNotifier(super.value);
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    CounterNotifier Function(BuildContext context)? create,
    CounterNotifier? value,
    required Widget child,
  })  : _create = create,
        _value = value,
        _child = child;

  final CounterNotifier Function(BuildContext context)? _create;
  final CounterNotifier? _value;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    if (_value != null) {
      return MaterialApp(
        home: ValueNotifierProvider<CounterNotifier>.value(
          value: _value!,
          child: _child,
        ),
      );
    }
    return MaterialApp(
      home: ValueNotifierProvider<CounterNotifier>(
        create: _create!,
        child: _child,
      ),
    );
  }
}

class MyStatefulApp extends StatefulWidget {
  const MyStatefulApp({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MyStatefulApp> createState() => _MyStatefulAppState();
}

class _MyStatefulAppState extends State<MyStatefulApp> {
  late CounterNotifier valueNotifier;

  @override
  void initState() {
    valueNotifier = CounterNotifier();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ValueNotifierProvider<CounterNotifier>(
        create: (context) => valueNotifier,
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                key: const Key('iconButtonKey'),
                icon: const Icon(Icons.edit),
                tooltip: 'Change State',
                onPressed: () {
                  setState(() => valueNotifier = CounterNotifier());
                },
              )
            ],
          ),
          body: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    super.dispose();
  }
}

class MyAppNoProvider extends MaterialApp {
  const MyAppNoProvider({
    super.key,
    required Widget super.home,
  });
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key, this.onBuild});

  final void Function()? onBuild;

  @override
  Widget build(BuildContext context) {
    final counterValueNotifier =
        ValueNotifierProvider.of<CounterNotifier>(context);

    return Scaffold(
      body: ValueNotifierBuilder<CounterNotifier, int>(
        notifier: counterValueNotifier,
        builder: (context, count) {
          onBuild?.call();
          return Text('$count', key: const Key('counter_text'));
        },
      ),
    );
  }
}

class RoutePage extends StatelessWidget {
  const RoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            key: const Key('route_button'),
            child: const SizedBox(),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<Widget>(
                  builder: (context) => const SizedBox(),
                ),
              );
            },
          ),
          ElevatedButton(
            key: const Key('increment_button'),
            child: const SizedBox(),
            onPressed: () {
              ValueNotifierProvider.of<CounterNotifier>(context).increment();
            },
          ),
        ],
      ),
    );
  }
}

class CounterNotifier extends ValueNotifier<int> {
  CounterNotifier({this.onDispose}) : super(0);

  final void Function()? onDispose;

  void increment() => value = value + 1;
  void decrement() => value = value - 1;

  @override
  void dispose() {
    onDispose?.call();
    super.dispose();
  }
}

void main() {
  group('ValueNotifierProvider', () {
    testWidgets(
        'throws AssertionError '
        'when child is not specified', (tester) async {
      const expected =
          '''ValueNotifierProvider<CounterNotifier> used outside of MultiValueNotifierProvider must specify a child''';
      await tester
          .pumpWidget(ValueNotifierProvider(create: (_) => CounterNotifier()));
      expect(
        tester.takeException(),
        isA<AssertionError>().having((e) => e.message, 'message', expected),
      );
    });

    testWidgets(
        '.value throws AssertionError '
        'when child is not specified', (tester) async {
      const expected =
          '''ValueNotifierProvider<CounterNotifier> used outside of MultiValueNotifierProvider must specify a child''';
      await tester
          .pumpWidget(ValueNotifierProvider.value(value: CounterNotifier()));
      expect(
        tester.takeException(),
        isA<AssertionError>().having((e) => e.message, 'message', expected),
      );
    });

    testWidgets('lazy is true by default', (tester) async {
      final valueNotifierProvider = ValueNotifierProvider(
        create: (_) => CounterNotifier(),
        child: const SizedBox(),
      );
      expect(valueNotifierProvider.lazy, isTrue);
    });

    testWidgets('.value lazy is true', (tester) async {
      final valueNotifierProvider = ValueNotifierProvider.value(
        value: CounterNotifier(),
        child: const SizedBox(),
      );
      expect(valueNotifierProvider.lazy, isTrue);
    });

    testWidgets('lazily loads valueNotifiers by default', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        ValueNotifierProvider(
          create: (_) {
            createCalled = true;
            return CounterNotifier();
          },
          child: const SizedBox(),
        ),
      );
      expect(createCalled, isFalse);
    });

    testWidgets('can override lazy loading', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        ValueNotifierProvider(
          lazy: false,
          create: (_) {
            createCalled = true;
            return CounterNotifier();
          },
          child: const SizedBox(),
        ),
      );
      expect(createCalled, isTrue);
    });

    testWidgets('can be provided without an explicit type', (tester) async {
      const key = Key('__text_count__');
      await tester.pumpWidget(
        MaterialApp(
          home: ValueNotifierProvider(
            create: (_) => CounterNotifier(),
            child: Builder(
              builder: (context) => Text(
                '${ValueNotifierProvider.of<CounterNotifier>(context).value}',
                key: key,
              ),
            ),
          ),
        ),
      );
      final text = tester.widget(find.byKey(key)) as Text;
      expect(text.data, '0');
    });

    testWidgets('passes valueNotifier to children', (tester) async {
      await tester.pumpWidget(
        MyApp(
          create: (_) => CounterNotifier(),
          child: const CounterPage(),
        ),
      );

      final counterText = tester.widget<Text>(
        find.byKey(const Key('counter_text')),
      );
      expect(counterText.data, '0');
    });

    testWidgets('passes valueNotifier to children within same build',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueNotifierProvider(
              create: (context) => CounterNotifier(),
              child: ValueNotifierBuilder<CounterNotifier, int>(
                builder: (context, value) => Text('value: $value'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('value: 0'), findsOneWidget);
    });

    testWidgets(
        'triggers updates in child with context.watch '
        'when provided valueNotifier instance changes,', (tester) async {
      const buttonKey = Key('__button__');
      var valueNotifier = CounterNotifier();
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: ValueNotifierProvider.value(
                value: valueNotifier,
                child: Builder(
                  builder: (context) {
                    final value = context.watch<CounterNotifier>().value;
                    return GestureDetector(
                      onTap: () => valueNotifier.increment(),
                      child: Text('value: $value'),
                    );
                  },
                ),
              ),
              floatingActionButton: FloatingActionButton(
                key: buttonKey,
                onPressed: () =>
                    setState(() => valueNotifier = CounterNotifier()),
              ),
            ),
          ),
        ),
      );
      expect(find.text('value: 0'), findsOneWidget);

      valueNotifier.increment();
      await tester.pump();

      expect(find.text('value: 1'), findsOneWidget);

      await tester.tap(find.byKey(buttonKey));
      await tester.pump();

      expect(find.text('value: 0'), findsOneWidget);
    });

    testWidgets('can access valueNotifier directly within builder',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueNotifierProvider(
              create: (_) => CounterNotifier(),
              child: ValueNotifierBuilder<CounterNotifier, int>(
                builder: (context, value) => Column(
                  children: [
                    Text('value: $value'),
                    ElevatedButton(
                      key: const Key('increment_button'),
                      child: const SizedBox(),
                      onPressed: () {
                        ValueNotifierProvider.of<CounterNotifier>(context)
                            .increment();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('value: 0'), findsOneWidget);
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('value: 1'), findsOneWidget);
    });

    testWidgets(
        'does not call close on valueNotifier if it was not loaded (lazily)',
        (tester) async {
      var closeCalled = false;
      await tester.pumpWidget(
        MyApp(
          create: (_) => CounterNotifier(onDispose: () => closeCalled = true),
          child: const RoutePage(),
        ),
      );

      final routeButtonFinder = find.byKey(const Key('route_button'));
      expect(routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, false);
    });

    testWidgets(
        'calls close on valueNotifier automatically when invoked (lazily)',
        (tester) async {
      var closeCalled = false;
      await tester.pumpWidget(
        MyApp(
          create: (_) => CounterNotifier(onDispose: () => closeCalled = true),
          child: const RoutePage(),
        ),
      );
      final incrementButtonFinder = find.byKey(const Key('increment_button'));
      expect(incrementButtonFinder, findsOneWidget);
      await tester.tap(incrementButtonFinder);
      final routeButtonFinder = find.byKey(const Key('route_button'));
      expect(routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, true);
    });

    testWidgets('does not close when created using value', (tester) async {
      var closeCalled = false;
      final value = CounterNotifier(onDispose: () => closeCalled = true);
      const Widget child = RoutePage();
      await tester.pumpWidget(MyApp(value: value, child: child));

      final routeButtonFinder = find.byKey(const Key('route_button'));
      expect(routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, false);
    });

    testWidgets(
      'should throw FlutterError if ValueNotifierProvider is not found in '
      'current context',
      (tester) async {
        await tester.pumpWidget(const MyAppNoProvider(home: CounterPage()));
        final dynamic exception = tester.takeException();
        const expectedMessage = '''
        ValueNotifierProvider.of() called with a context that does not contain a CounterNotifier.
        No ancestor could be found starting from the context that was passed to ValueNotifierProvider.of<CounterNotifier>().

        This can happen if the context you used comes from a widget above the ValueNotifierProvider.

        The context used was: CounterPage(dirty)
''';
        expect(exception is FlutterError, true);
        expect((exception as FlutterError).message, expectedMessage);
      },
    );

    testWidgets(
        'should throw StateError if internal '
        'exception is thrown', (tester) async {
      const expected = 'Tried to read a provider that threw '
          'during the creation of its value.\n'
          'The exception occurred during the creation of type CounterNotifier.';
      final onError = FlutterError.onError;
      final flutterErrors = <FlutterErrorDetails>[];
      FlutterError.onError = flutterErrors.add;
      await tester.pumpWidget(
        ValueNotifierProvider<CounterNotifier>(
          lazy: false,
          create: (_) => throw Exception('oops'),
          child: const SizedBox(),
        ),
      );
      FlutterError.onError = onError;
      expect(
        flutterErrors,
        contains(
          isA<FlutterErrorDetails>().having(
            (d) => d.exception,
            'exception',
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains(expected),
            ),
          ),
        ),
      );
    });

    testWidgets(
        'should throw StateError '
        'if exception is for different provider', (tester) async {
      const expected = 'Tried to read a provider that threw '
          'during the creation of its value.\n'
          'The exception occurred during the creation of type CounterNotifier.';
      final onError = FlutterError.onError;
      final flutterErrors = <FlutterErrorDetails>[];
      FlutterError.onError = flutterErrors.add;
      await tester.pumpWidget(
        ValueNotifierProvider<CounterNotifier>(
          lazy: false,
          create: (context) {
            context.read<int>();
            return CounterNotifier();
          },
          child: const SizedBox(),
        ),
      );
      FlutterError.onError = onError;
      expect(
        flutterErrors,
        contains(
          isA<FlutterErrorDetails>().having(
            (d) => d.exception,
            'exception',
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains(expected),
            ),
          ),
        ),
      );
    });

    testWidgets(
        'should not rebuild widgets that inherited the valueNotifier if the '
        'valueNotifier is changed', (tester) async {
      var numBuilds = 0;
      final Widget child = CounterPage(onBuild: () => numBuilds++);
      await tester.pumpWidget(
        MyStatefulApp(
          child: child,
        ),
      );
      await tester.tap(find.byKey(const Key('iconButtonKey')));
      await tester.pump();
      expect(numBuilds, 1);
    });

    testWidgets('listen: true registers context as dependent', (tester) async {
      const textKey = Key('__text__');
      const buttonKey = Key('__button__');
      var counterValueNotifierCreateCount = 0;
      var materialBuildCount = 0;
      var textBuildCount = 0;
      await tester.pumpWidget(
        ValueNotifierProvider(
          create: (_) {
            counterValueNotifierCreateCount++;
            return CounterNotifier();
          },
          child: Builder(
            builder: (context) {
              materialBuildCount++;
              return MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      textBuildCount++;
                      final count = ValueNotifierProvider.of<CounterNotifier>(
                        context,
                        listen: true,
                      ).value;
                      return Text('$count', key: textKey);
                    },
                  ),
                  floatingActionButton: FloatingActionButton(
                    key: buttonKey,
                    onPressed: () {
                      context.read<CounterNotifier>().increment();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
      var text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '0');
      expect(counterValueNotifierCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(1));

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '1');
      expect(counterValueNotifierCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(2));

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '2');
      expect(counterValueNotifierCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(3));
    });

    testWidgets('context.watch registers context as dependent', (tester) async {
      const textKey = Key('__text__');
      const buttonKey = Key('__button__');
      var counterValueNotifierCreateCount = 0;
      var materialBuildCount = 0;
      var textBuildCount = 0;
      await tester.pumpWidget(
        ValueNotifierProvider(
          create: (_) {
            counterValueNotifierCreateCount++;
            return CounterNotifier();
          },
          child: Builder(
            builder: (context) {
              materialBuildCount++;
              return MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      textBuildCount++;
                      final count = context.watch<CounterNotifier>().value;
                      return Text('$count', key: textKey);
                    },
                  ),
                  floatingActionButton: FloatingActionButton(
                    key: buttonKey,
                    onPressed: () {
                      context.read<CounterNotifier>().increment();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
      var text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '0');
      expect(counterValueNotifierCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(1));

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '1');
      expect(counterValueNotifierCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(2));

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '2');
      expect(counterValueNotifierCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(3));
    });

    testWidgets('context.select only rebuilds on changes to selected value',
        (tester) async {
      const textKey = Key('__text__');
      const incrementButtonKey = Key('__increment_button__');
      const decrementButtonKey = Key('__decrement_button__');
      var materialBuildCount = 0;
      var textBuildCount = 0;
      await tester.pumpWidget(
        ValueNotifierProvider(
          create: (_) => CounterNotifier(),
          child: Builder(
            builder: (context) {
              materialBuildCount++;
              return MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      textBuildCount++;
                      final isPositive = context.select(
                        (CounterNotifier c) => c.value >= 0,
                      );
                      return Text('$isPositive', key: textKey);
                    },
                  ),
                  floatingActionButton: Column(
                    children: [
                      FloatingActionButton(
                        key: incrementButtonKey,
                        onPressed: () {
                          context.read<CounterNotifier>().increment();
                        },
                      ),
                      FloatingActionButton(
                        key: decrementButtonKey,
                        onPressed: () {
                          context.read<CounterNotifier>().decrement();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      var text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, 'true');
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(1));

      await tester.tap(find.byKey(decrementButtonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, 'false');
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(2));

      await tester.tap(find.byKey(decrementButtonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, 'false');
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(2));
    });

    testWidgets('should not throw if listen returns null subscription',
        (tester) async {
      await tester.pumpWidget(
        ValueNotifierProvider(
          lazy: false,
          create: (_) => MockValueNotifier(0),
          child: const SizedBox(),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
