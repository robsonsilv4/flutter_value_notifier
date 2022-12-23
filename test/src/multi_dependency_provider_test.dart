import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

class DependencyA {
  const DependencyA(this.data);

  final int data;
}

class DependencyB {
  const DependencyB(this.data);

  final int data;
}

class TestApp extends MaterialApp {
  const TestApp({super.key}) : super(home: const CounterPage());
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencyA = DependencyProvider.of<DependencyA>(context);
    final dependencyB = DependencyProvider.of<DependencyB>(context);

    return Scaffold(
      body: Column(
        children: [
          Text(
            '${dependencyA.data}',
            key: const Key('dependency_a_data'),
          ),
          Text(
            '${dependencyB.data}',
            key: const Key('dependency_b_data'),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('MultiDependencyProvider', () {
    testWidgets('passes values to children', (tester) async {
      await tester.pumpWidget(
        MultiDependencyProvider(
          providers: [
            DependencyProvider<DependencyA>(
              create: (_) => const DependencyA(0),
            ),
            DependencyProvider<DependencyB>(
              create: (_) => const DependencyB(1),
            ),
          ],
          child: const TestApp(),
        ),
      );
      final dependencyAFinder = find.byKey(const Key('dependency_a_data'));
      expect(dependencyAFinder, findsOneWidget);

      final dependencyAText = tester.widget<Text>(dependencyAFinder);
      expect(dependencyAText.data, '0');

      final dependencyBFinder = find.byKey(const Key('dependency_b_data'));
      expect(dependencyBFinder, findsOneWidget);

      final dependencyBText = tester.widget<Text>(dependencyBFinder);
      expect(dependencyBText.data, '1');
    });

    testWidgets('passes values to children without explicit types',
        (tester) async {
      await tester.pumpWidget(
        MultiDependencyProvider(
          providers: [
            DependencyProvider(
              create: (_) => const DependencyA(0),
            ),
            DependencyProvider(
              create: (_) => const DependencyB(1),
            ),
          ],
          child: const TestApp(),
        ),
      );

      final dependencyAFinder = find.byKey(const Key('dependency_a_data'));
      expect(dependencyAFinder, findsOneWidget);

      final dependencyAText = tester.widget<Text>(dependencyAFinder);
      expect(dependencyAText.data, '0');

      final dependencyBFinder = find.byKey(const Key('dependency_b_data'));
      expect(dependencyBFinder, findsOneWidget);

      final dependencyBText = tester.widget<Text>(dependencyBFinder);
      expect(dependencyBText.data, '1');
    });
  });
}
