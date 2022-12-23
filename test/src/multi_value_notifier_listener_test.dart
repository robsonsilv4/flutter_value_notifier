import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

class CounterNotifier extends ValueNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => value = value + 1;
}

void main() {
  group('MultiValueNotifierListener', () {
    testWidgets('calls listeners on value changes', (tester) async {
      final valuesA = <int>[];
      const expectedValuesA = [1, 2];
      final counterNotifierA = CounterNotifier();

      final valuesB = <int>[];
      final expectedValuesB = [1];
      final counterNotifierB = CounterNotifier();

      await tester.pumpWidget(
        MultiValueNotifierListener(
          listeners: [
            ValueNotifierListener<CounterNotifier, int>(
              valueNotifier: counterNotifierA,
              listener: (_, value) => valuesA.add(value),
            ),
            ValueNotifierListener<CounterNotifier, int>(
              valueNotifier: counterNotifierB,
              listener: (_, value) => valuesB.add(value),
            ),
          ],
          child: const SizedBox(key: Key('multiValueNotifierListener_child')),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('multiValueNotifierListener_child')),
        findsOneWidget,
      );

      counterNotifierA.increment();
      await tester.pump();
      counterNotifierA.increment();
      await tester.pump();
      counterNotifierB.increment();
      await tester.pump();

      expect(valuesA, expectedValuesA);
      expect(valuesB, expectedValuesB);
    });

    testWidgets('calls listeners on value changes without explicit types',
        (tester) async {
      final valuesA = <int>[];
      const expectedValuesA = [1, 2];
      final counterNotifierA = CounterNotifier();

      final valuesB = <int>[];
      final expectedValuesB = [1];
      final counterNotifierB = CounterNotifier();

      await tester.pumpWidget(
        MultiValueNotifierListener(
          listeners: [
            ValueNotifierListener(
              valueNotifier: counterNotifierA,
              listener: (BuildContext context, int value) => valuesA.add(value),
            ),
            ValueNotifierListener(
              valueNotifier: counterNotifierB,
              listener: (BuildContext context, int value) => valuesB.add(value),
            ),
          ],
          child: const SizedBox(key: Key('multiValueNotifierListener_child')),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('multiValueNotifierListener_child')),
        findsOneWidget,
      );

      counterNotifierA.increment();
      await tester.pump();
      counterNotifierA.increment();
      await tester.pump();
      counterNotifierB.increment();
      await tester.pump();

      expect(valuesA, expectedValuesA);
      expect(valuesB, expectedValuesB);
    });
  });
}
