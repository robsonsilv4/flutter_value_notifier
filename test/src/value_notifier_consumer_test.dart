import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

class CounterNotifier extends ValueNotifier<int> {
  CounterNotifier({int seed = 0}) : super(seed);

  void increment() => value = value + 1;
}

void main() {
  group('ValueNotifierConsumer', () {
    testWidgets(
      'accesses the valueNotifier directly and passes initial value to builder '
      'and nothing to listener',
      (tester) async {
        final counterNotifier = CounterNotifier();
        final listenerValues = <int>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValueNotifierConsumer<CounterNotifier, int>(
                notifier: counterNotifier,
                builder: (context, value) {
                  return Text('Value: $value');
                },
                listener: (_, value) {
                  listenerValues.add(value);
                },
              ),
            ),
          ),
        );
        expect(find.text('Value: 0'), findsOneWidget);
        expect(listenerValues, isEmpty);
      },
    );

    testWidgets(
        'accesses the valueNotifier directly '
        'and passes multiple values to builder and listener', (tester) async {
      final counterNotifier = CounterNotifier();
      final listenerValues = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueNotifierConsumer<CounterNotifier, int>(
              notifier: counterNotifier,
              builder: (context, value) {
                return Text('Value: $value');
              },
              listener: (_, value) {
                listenerValues.add(value);
              },
            ),
          ),
        ),
      );
      expect(find.text('Value: 0'), findsOneWidget);
      expect(listenerValues, isEmpty);
      counterNotifier.increment();
      await tester.pump();
      expect(find.text('Value: 1'), findsOneWidget);
      expect(listenerValues, [1]);
    });

    testWidgets(
      'accesses the valueNotifier via context and passes initial value to '
      'builder',
      (tester) async {
        final counterNotifier = CounterNotifier();
        final listenerValues = <int>[];
        await tester.pumpWidget(
          ValueNotifierProvider<CounterNotifier>.value(
            value: counterNotifier,
            child: MaterialApp(
              home: Scaffold(
                body: ValueNotifierConsumer<CounterNotifier, int>(
                  notifier: counterNotifier,
                  builder: (_, value) {
                    return Text('Value: $value');
                  },
                  listener: (_, value) {
                    listenerValues.add(value);
                  },
                ),
              ),
            ),
          ),
        );
        expect(find.text('Value: 0'), findsOneWidget);
        expect(listenerValues, isEmpty);
      },
    );

    testWidgets(
      'accesses the valueNotifier via context and passes multiple values to '
      'builder',
      (tester) async {
        final counterNotifier = CounterNotifier();
        final listenerValues = <int>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValueNotifierConsumer<CounterNotifier, int>(
                notifier: counterNotifier,
                builder: (context, value) {
                  return Text('Value: $value');
                },
                listener: (_, value) {
                  listenerValues.add(value);
                },
              ),
            ),
          ),
        );
        expect(find.text('Value: 0'), findsOneWidget);
        expect(listenerValues, isEmpty);
        counterNotifier.increment();
        await tester.pump();
        expect(find.text('Value: 1'), findsOneWidget);
        expect(listenerValues, [1]);
      },
    );

    testWidgets('does not trigger rebuilds when buildWhen evaluates to false',
        (tester) async {
      final counterNotifier = CounterNotifier();
      final listenerValues = <int>[];
      final builderValues = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueNotifierConsumer<CounterNotifier, int>(
              notifier: counterNotifier,
              buildWhen: (previous, current) => (previous + current) % 3 == 0,
              builder: (context, value) {
                builderValues.add(value);
                return Text('Value: $value');
              },
              listener: (_, value) {
                listenerValues.add(value);
              },
            ),
          ),
        ),
      );
      expect(find.text('Value: 0'), findsOneWidget);
      expect(builderValues, [0]);
      expect(listenerValues, isEmpty);

      counterNotifier.increment();
      await tester.pump();

      expect(find.text('Value: 0'), findsOneWidget);
      expect(builderValues, [0]);
      expect(listenerValues, [1]);

      counterNotifier.increment();
      await tester.pumpAndSettle();

      expect(find.text('Value: 2'), findsOneWidget);
      expect(builderValues, [0, 2]);
      expect(listenerValues, [1, 2]);
    });

    testWidgets(
        'does not trigger rebuilds when '
        'buildWhen evaluates to false (inferred valueNotifier)',
        (tester) async {
      final counterNotifier = CounterNotifier();
      final listenerValues = <int>[];
      final builderValues = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueNotifierProvider.value(
              value: counterNotifier,
              child: ValueNotifierConsumer<CounterNotifier, int>(
                buildWhen: (previous, current) => (previous + current) % 3 == 0,
                builder: (context, value) {
                  builderValues.add(value);
                  return Text('Value: $value');
                },
                listener: (_, value) {
                  listenerValues.add(value);
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('Value: 0'), findsOneWidget);
      expect(builderValues, [0]);
      expect(listenerValues, isEmpty);

      counterNotifier.increment();
      await tester.pump();

      expect(find.text('Value: 0'), findsOneWidget);
      expect(builderValues, [0]);
      expect(listenerValues, [1]);

      counterNotifier.increment();
      await tester.pumpAndSettle();

      expect(find.text('Value: 2'), findsOneWidget);
      expect(builderValues, [0, 2]);
      expect(listenerValues, [1, 2]);
    });

    testWidgets('updates when valueNotifier reference has changed',
        (tester) async {
      const buttonKey = Key('__button__');
      var counterNotifier = CounterNotifier();
      final listenerValues = <int>[];
      final builderValues = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setValue) {
                return ValueNotifierConsumer<CounterNotifier, int>(
                  notifier: counterNotifier,
                  builder: (context, value) {
                    builderValues.add(value);
                    return TextButton(
                      key: buttonKey,
                      onPressed: () => setValue(() {}),
                      child: Text('Value: $value'),
                    );
                  },
                  listener: (_, value) {
                    listenerValues.add(value);
                  },
                );
              },
            ),
          ),
        ),
      );
      expect(find.text('Value: 0'), findsOneWidget);
      expect(builderValues, [0]);
      expect(listenerValues, isEmpty);

      counterNotifier.increment();
      await tester.pump();

      expect(find.text('Value: 1'), findsOneWidget);
      expect(builderValues, [0, 1]);
      expect(listenerValues, [1]);

      counterNotifier = CounterNotifier();
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(find.text('Value: 0'), findsOneWidget);
      expect(builderValues, [0, 1, 0]);
      expect(listenerValues, [1]);
    });

    testWidgets('does not trigger listen when listenWhen evaluates to false',
        (tester) async {
      final counterNotifier = CounterNotifier();
      final listenerValues = <int>[];
      final builderValues = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueNotifierConsumer<CounterNotifier, int>(
              notifier: counterNotifier,
              builder: (context, value) {
                builderValues.add(value);
                return Text('Value: $value');
              },
              listenWhen: (previous, current) => (previous + current) % 3 == 0,
              listener: (_, value) {
                listenerValues.add(value);
              },
            ),
          ),
        ),
      );
      expect(find.text('Value: 0'), findsOneWidget);
      expect(builderValues, [0]);
      expect(listenerValues, isEmpty);

      counterNotifier.increment();
      await tester.pump();

      expect(find.text('Value: 1'), findsOneWidget);
      expect(builderValues, [0, 1]);
      expect(listenerValues, isEmpty);

      counterNotifier.increment();
      await tester.pumpAndSettle();

      expect(find.text('Value: 2'), findsOneWidget);
      expect(builderValues, [0, 1, 2]);
      expect(listenerValues, [2]);
    });

    testWidgets(
        'calls buildWhen/listenWhen and builder/listener with correct values',
        (tester) async {
      final buildWhenPreviousValue = <int>[];
      final buildWhenCurrentValue = <int>[];
      final buildValues = <int>[];
      final listenWhenPreviousValue = <int>[];
      final listenWhenCurrentValue = <int>[];
      final listenValues = <int>[];
      final counterNotifier = CounterNotifier();
      await tester.pumpWidget(
        ValueNotifierConsumer<CounterNotifier, int>(
          notifier: counterNotifier,
          listenWhen: (previous, current) {
            if (current % 3 == 0) {
              listenWhenPreviousValue.add(previous);
              listenWhenCurrentValue.add(current);
              return true;
            }
            return false;
          },
          listener: (_, value) {
            listenValues.add(value);
          },
          buildWhen: (previous, current) {
            if (current.isEven) {
              buildWhenPreviousValue.add(previous);
              buildWhenCurrentValue.add(current);
              return true;
            }
            return false;
          },
          builder: (_, value) {
            buildValues.add(value);
            return const SizedBox();
          },
        ),
      );
      await tester.pump();
      counterNotifier
        ..increment()
        ..increment()
        ..increment();
      await tester.pumpAndSettle();

      expect(buildValues, [0, 2]);
      expect(buildWhenPreviousValue, [1]);
      expect(buildWhenCurrentValue, [2]);

      expect(listenValues, [3]);
      expect(listenWhenPreviousValue, [2]);
      expect(listenWhenCurrentValue, [3]);
    });

    testWidgets(
        'rebuilds and updates subscription '
        'when provided valueNotifier is changed', (tester) async {
      final firstCounterNotifier = CounterNotifier();
      final secondCounterNotifier = CounterNotifier(seed: 100);

      final values = <int>[];
      const expectedValues = [1, 101];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ValueNotifierProvider.value(
            value: firstCounterNotifier,
            child: ValueNotifierConsumer<CounterNotifier, int>(
              listener: (_, value) => values.add(value),
              builder: (context, value) => Text('Count $value'),
            ),
          ),
        ),
      );

      expect(find.text('Count 0'), findsOneWidget);

      firstCounterNotifier.increment();
      await tester.pumpAndSettle();

      expect(find.text('Count 1'), findsOneWidget);
      expect(find.text('Count 0'), findsNothing);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ValueNotifierProvider.value(
            value: secondCounterNotifier,
            child: ValueNotifierConsumer<CounterNotifier, int>(
              listener: (_, value) => values.add(value),
              builder: (context, value) => Text('Count $value'),
            ),
          ),
        ),
      );

      expect(find.text('Count 100'), findsOneWidget);
      expect(find.text('Count 1'), findsNothing);

      secondCounterNotifier.increment();
      await tester.pumpAndSettle();

      expect(find.text('Count 101'), findsOneWidget);
      expect(values, expectedValues);
    });

    testWidgets('overrides debugFillProperties', (tester) async {
      final builder = DiagnosticPropertiesBuilder();

      ValueNotifierConsumer(
        notifier: CounterNotifier(),
        buildWhen: (previous, current) => previous != current,
        builder: (context, value) => const SizedBox(),
        listener: (context, value) {},
        listenWhen: (previous, current) => previous != current,
      ).debugFillProperties(builder);

      final description = builder.properties
          .where((node) => !node.isFiltered(DiagnosticLevel.info))
          .map((node) => node.toString())
          .toList();

      expect(description, anyElement(contains('notifier: CounterNotifier')));
      expect(description, contains('has builder'));
      expect(description, contains('has listener'));
      expect(description, contains('has buildWhen'));
      expect(description, contains('has listenWhen'));
    });
  });
}
