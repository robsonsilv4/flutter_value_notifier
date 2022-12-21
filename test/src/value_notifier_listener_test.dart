import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:value_notifier_test/flutter_value_notifier.dart';

class CounterNotifier extends ValueNotifier<int> {
  CounterNotifier({int seed = 0}) : super(seed);

  void increment() => value = value + 1;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.onListenerCalled});

  final ValueNotifierWidgetListener<int>? onListenerCalled;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CounterNotifier _counterNotifier;

  @override
  void initState() {
    super.initState();
    _counterNotifier = CounterNotifier();
  }

  @override
  void dispose() {
    _counterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: _counterNotifier,
          listener: (context, value) {
            widget.onListenerCalled?.call(context, value);
          },
          child: Column(
            children: [
              ElevatedButton(
                key: const Key('value_notifier_listener_reset_button'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _counterNotifier = CounterNotifier());
                },
              ),
              ElevatedButton(
                key: const Key('value_notifier_listener_noop_button'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _counterNotifier = _counterNotifier);
                },
              ),
              ElevatedButton(
                key: const Key('valueNotifier_listener_increment_button'),
                child: const SizedBox(),
                onPressed: () => _counterNotifier.increment(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('ValueNotifierListener', () {
    testWidgets(
        'throws AssertionError '
        'when child is not specified', (tester) async {
      const expected =
          '''ValueNotifierListener<CounterNotifier, int> used outside of MultiValueNotifierListener must specify a child''';
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: CounterNotifier(),
          listener: (context, value) {},
        ),
      );
      expect(
        tester.takeException(),
        isA<AssertionError>().having((e) => e.message, 'message', expected),
      );
    });

    testWidgets('renders child properly', (tester) async {
      const targetKey = Key('valueNotifier_listener_container');
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: CounterNotifier(),
          listener: (_, __) {},
          child: const SizedBox(key: targetKey),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets('calls listener on single value change', (tester) async {
      final counterNotifier = CounterNotifier();
      final values = <int>[];
      const expectedStates = [1];
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: counterNotifier,
          listener: (_, value) {
            values.add(value);
          },
          child: const SizedBox(),
        ),
      );
      counterNotifier.increment();
      await tester.pump();
      expect(values, expectedStates);
    });

    testWidgets('calls listener on multiple value change', (tester) async {
      final counterNotifier = CounterNotifier();
      final values = <int>[];
      const expectedStates = [1, 2];
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: counterNotifier,
          listener: (_, value) {
            values.add(value);
          },
          child: const SizedBox(),
        ),
      );
      counterNotifier.increment();
      await tester.pump();
      counterNotifier.increment();
      await tester.pump();
      expect(values, expectedStates);
    });

    testWidgets(
        'updates when the valueNotifier is changed at runtime to a different valueNotifier '
        'and unsubscribes from old valueNotifier', (tester) async {
      var listenerCallCount = 0;
      int? latestState;
      final incrementFinder = find.byKey(
        const Key('valueNotifier_listener_increment_button'),
      );
      final resetNotifierFinder = find.byKey(
        const Key('value_notifier_listener_reset_button'),
      );
      await tester.pumpWidget(MyApp(
        onListenerCalled: (_, value) {
          listenerCallCount++;
          latestState = value;
        },
      ));

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestState, 1);

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestState, 2);

      await tester.tap(resetNotifierFinder);
      await tester.pump();
      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestState, 1);
    });

    testWidgets(
        'does not update when the valueNotifier is changed at runtime to same valueNotifier '
        'and stays subscribed to current valueNotifier', (tester) async {
      var listenerCallCount = 0;
      int? latestState;
      final incrementFinder = find.byKey(
        const Key('valueNotifier_listener_increment_button'),
      );
      final noopNotifierFinder = find.byKey(
        const Key('value_notifier_listener_noop_button'),
      );
      await tester.pumpWidget(MyApp(
        onListenerCalled: (context, value) {
          listenerCallCount++;
          latestState = value;
        },
      ));

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestState, 1);

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestState, 2);

      await tester.tap(noopNotifierFinder);
      await tester.pump();
      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestState, 3);
    });

    testWidgets(
        'calls listenWhen on single value change with correct previous '
        'and current values', (tester) async {
      int? latestPreviousState;
      var listenWhenCallCount = 0;
      final values = <int>[];
      final counterNotifier = CounterNotifier();
      const expectedStates = [1];
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: counterNotifier,
          listenWhen: (previous, value) {
            listenWhenCallCount++;
            latestPreviousState = previous;
            values.add(value);
            return true;
          },
          listener: (_, __) {},
          child: const SizedBox(),
        ),
      );
      counterNotifier.increment();
      await tester.pump();

      expect(values, expectedStates);
      expect(listenWhenCallCount, 1);
      expect(latestPreviousState, 0);
    });

    testWidgets(
        'calls listenWhen with previous listener value and current valueNotifier value',
        (tester) async {
      int? latestPreviousState;
      var listenWhenCallCount = 0;
      final values = <int>[];
      final counterNotifier = CounterNotifier();
      const expectedStates = [2];
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: counterNotifier,
          listenWhen: (previous, value) {
            listenWhenCallCount++;
            if ((previous + value) % 3 == 0) {
              latestPreviousState = previous;
              values.add(value);
              return true;
            }
            return false;
          },
          listener: (_, __) {},
          child: const SizedBox(),
        ),
      );
      counterNotifier
        ..increment()
        ..increment()
        ..increment();
      await tester.pump();

      expect(values, expectedStates);
      expect(listenWhenCallCount, 3);
      expect(latestPreviousState, 1);
    });

    testWidgets('calls listenWhen and listener with correct value',
        (tester) async {
      final listenWhenPreviousState = <int>[];
      final listenWhenCurrentState = <int>[];
      final values = <int>[];
      final counterNotifier = CounterNotifier();
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: counterNotifier,
          listenWhen: (previous, current) {
            if (current % 3 == 0) {
              listenWhenPreviousState.add(previous);
              listenWhenCurrentState.add(current);
              return true;
            }
            return false;
          },
          listener: (_, value) => values.add(value),
          child: const SizedBox(),
        ),
      );
      counterNotifier
        ..increment()
        ..increment()
        ..increment();
      await tester.pump();

      expect(values, [3]);
      expect(listenWhenPreviousState, [2]);
      expect(listenWhenCurrentState, [3]);
    });

    testWidgets(
        'infers the valueNotifier from the context if the valueNotifier is not provided',
        (tester) async {
      int? latestPreviousState;
      var listenWhenCallCount = 0;
      final values = <int>[];
      final counterNotifier = CounterNotifier();
      const expectedStates = [1];
      await tester.pumpWidget(
        ValueNotifierProvider.value(
          value: counterNotifier,
          child: ValueNotifierListener<CounterNotifier, int>(
            listenWhen: (previous, value) {
              listenWhenCallCount++;
              latestPreviousState = previous;
              values.add(value);
              return true;
            },
            listener: (context, value) {},
            child: const SizedBox(),
          ),
        ),
      );
      counterNotifier.increment();
      await tester.pump();

      expect(values, expectedStates);
      expect(listenWhenCallCount, 1);
      expect(latestPreviousState, 0);
    });

    testWidgets(
        'calls listenWhen on multiple value change with correct previous '
        'and current values', (tester) async {
      int? latestPreviousState;
      var listenWhenCallCount = 0;
      final values = <int>[];
      final counterNotifier = CounterNotifier();
      const expectedStates = [1, 2];
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: counterNotifier,
          listenWhen: (previous, value) {
            listenWhenCallCount++;
            latestPreviousState = previous;
            values.add(value);
            return true;
          },
          listener: (_, __) {},
          child: const SizedBox(),
        ),
      );
      await tester.pump();
      counterNotifier.increment();
      await tester.pump();
      counterNotifier.increment();
      await tester.pump();

      expect(values, expectedStates);
      expect(listenWhenCallCount, 2);
      expect(latestPreviousState, 1);
    });

    testWidgets(
        'does not call listener when listenWhen returns false on single value '
        'change', (tester) async {
      final values = <int>[];
      final counterNotifier = CounterNotifier();
      const expectedStates = <int>[];
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: counterNotifier,
          listenWhen: (_, __) => false,
          listener: (_, value) => values.add(value),
          child: const SizedBox(),
        ),
      );
      counterNotifier.increment();
      await tester.pump();

      expect(values, expectedStates);
    });

    testWidgets(
        'calls listener when listenWhen returns true on single value change',
        (tester) async {
      final values = <int>[];
      final counterNotifier = CounterNotifier();
      const expectedStates = [1];
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: counterNotifier,
          listenWhen: (_, __) => true,
          listener: (_, value) => values.add(value),
          child: const SizedBox(),
        ),
      );
      counterNotifier.increment();
      await tester.pump();

      expect(values, expectedStates);
    });

    testWidgets(
        'does not call listener when listenWhen returns false '
        'on multiple value changes', (tester) async {
      final values = <int>[];
      final counterNotifier = CounterNotifier();
      const expectedStates = <int>[];
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: counterNotifier,
          listenWhen: (_, __) => false,
          listener: (_, value) => values.add(value),
          child: const SizedBox(),
        ),
      );
      counterNotifier.increment();
      await tester.pump();
      counterNotifier.increment();
      await tester.pump();
      counterNotifier.increment();
      await tester.pump();
      counterNotifier.increment();
      await tester.pump();

      expect(values, expectedStates);
    });

    testWidgets(
        'calls listener when listenWhen returns true on multiple value change',
        (tester) async {
      final values = <int>[];
      final counterNotifier = CounterNotifier();
      const expectedStates = [1, 2, 3, 4];
      await tester.pumpWidget(
        ValueNotifierListener<CounterNotifier, int>(
          valueNotifier: counterNotifier,
          listenWhen: (_, __) => true,
          listener: (_, value) => values.add(value),
          child: const SizedBox(),
        ),
      );
      counterNotifier.increment();
      await tester.pump();
      counterNotifier.increment();
      await tester.pump();
      counterNotifier.increment();
      await tester.pump();
      counterNotifier.increment();
      await tester.pump();

      expect(values, expectedStates);
    });

    testWidgets(
        'updates subscription '
        'when provided valueNotifier is changed', (tester) async {
      final firstCounterNotifier = CounterNotifier();
      final secondCounterNotifier = CounterNotifier(seed: 100);

      final values = <int>[];
      const expectedStates = [1, 101];

      await tester.pumpWidget(
        ValueNotifierProvider.value(
          value: firstCounterNotifier,
          child: ValueNotifierListener<CounterNotifier, int>(
            listener: (_, value) => values.add(value),
            child: const SizedBox(),
          ),
        ),
      );

      firstCounterNotifier.increment();

      await tester.pumpWidget(
        ValueNotifierProvider.value(
          value: secondCounterNotifier,
          child: ValueNotifierListener<CounterNotifier, int>(
            listener: (_, value) => values.add(value),
            child: const SizedBox(),
          ),
        ),
      );

      secondCounterNotifier.increment();
      await tester.pump();
      firstCounterNotifier.increment();
      await tester.pump();

      expect(values, expectedStates);
    });
  });
}
