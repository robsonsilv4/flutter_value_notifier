import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

class CounterNotifier extends ValueNotifier<int> {
  CounterNotifier({int seed = 0}) : super(seed);

  void increment() => value = value + 1;
}

void main() {
  group('ValueNotifierSelector', () {
    testWidgets('renders with correct value', (tester) async {
      final counterNotifier = CounterNotifier();
      var builderCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ValueNotifierSelector<CounterNotifier, int, bool>(
            valueNotifier: counterNotifier,
            selector: (value) => value.isEven,
            builder: (_, value) {
              builderCallCount++;
              return Text('isEven: $value');
            },
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(builderCallCount, equals(1));
    });

    testWidgets('only rebuilds when selected value changes', (tester) async {
      final counterNotifier = CounterNotifier();
      var builderCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ValueNotifierSelector<CounterNotifier, int, bool>(
            valueNotifier: counterNotifier,
            selector: (value) => value == 1,
            builder: (_, value) {
              builderCallCount++;
              return Text('equals 1: $value');
            },
          ),
        ),
      );

      expect(find.text('equals 1: false'), findsOneWidget);
      expect(builderCallCount, equals(1));

      counterNotifier.increment();
      await tester.pumpAndSettle();

      expect(find.text('equals 1: true'), findsOneWidget);
      expect(builderCallCount, equals(2));

      counterNotifier.increment();
      await tester.pumpAndSettle();

      expect(find.text('equals 1: false'), findsOneWidget);
      expect(builderCallCount, equals(3));

      counterNotifier.increment();
      await tester.pumpAndSettle();

      expect(find.text('equals 1: false'), findsOneWidget);
      expect(builderCallCount, equals(3));
    });

    testWidgets('infers valueNotifier from context', (tester) async {
      final counterNotifier = CounterNotifier();
      var builderCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ValueNotifierProvider.value(
            value: counterNotifier,
            child: ValueNotifierSelector<CounterNotifier, int, bool>(
              selector: (value) => value.isEven,
              builder: (_, value) {
                builderCallCount++;
                return Text('isEven: $value');
              },
            ),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(builderCallCount, equals(1));
    });

    testWidgets('rebuilds when provided valueNotifier is changed',
        (tester) async {
      final firstCounterNotifier = CounterNotifier();
      final secondCounterNotifier = CounterNotifier(seed: 100);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ValueNotifierProvider.value(
            value: firstCounterNotifier,
            child: ValueNotifierSelector<CounterNotifier, int, bool>(
              selector: (value) => value.isEven,
              builder: (_, value) => Text('isEven: $value'),
            ),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);

      firstCounterNotifier.increment();
      await tester.pumpAndSettle();
      expect(find.text('isEven: false'), findsOneWidget);
      expect(find.text('isEven: true'), findsNothing);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ValueNotifierProvider.value(
            value: secondCounterNotifier,
            child: ValueNotifierSelector<CounterNotifier, int, bool>(
              selector: (value) => value.isEven,
              builder: (_, value) => Text('isEven: $value'),
            ),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(find.text('isEven: false'), findsNothing);

      secondCounterNotifier.increment();
      await tester.pumpAndSettle();

      expect(find.text('isEven: false'), findsOneWidget);
      expect(find.text('isEven: true'), findsNothing);
    });

    testWidgets('rebuilds when valueNotifier is changed at runtime',
        (tester) async {
      final firstCounterNotifier = CounterNotifier();
      final secondCounterNotifier = CounterNotifier(seed: 100);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ValueNotifierSelector<CounterNotifier, int, bool>(
            valueNotifier: firstCounterNotifier,
            selector: (value) => value.isEven,
            builder: (_, value) => Text('isEven: $value'),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);

      firstCounterNotifier.increment();
      await tester.pumpAndSettle();
      expect(find.text('isEven: false'), findsOneWidget);
      expect(find.text('isEven: true'), findsNothing);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ValueNotifierSelector<CounterNotifier, int, bool>(
            valueNotifier: secondCounterNotifier,
            selector: (value) => value.isEven,
            builder: (_, value) => Text('isEven: $value'),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(find.text('isEven: false'), findsNothing);

      secondCounterNotifier.increment();
      await tester.pumpAndSettle();

      expect(find.text('isEven: false'), findsOneWidget);
      expect(find.text('isEven: true'), findsNothing);
    });
  });
}
