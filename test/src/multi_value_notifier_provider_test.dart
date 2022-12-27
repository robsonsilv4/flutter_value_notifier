import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

class CounterNotifier extends ValueNotifier<int> {
  CounterNotifier({this.onDispose}) : super(0);

  final VoidCallback? onDispose;

  void increment() => value = value + 1;
  void decrement() => value = value - 1;

  @override
  void dispose() {
    onDispose?.call();
    super.dispose();
  }
}

class ThemeNotifier extends ValueNotifier<ThemeData> {
  ThemeNotifier({this.onDispose}) : super(ThemeData.light());

  final VoidCallback? onDispose;

  void toggle() {
    value = value == ThemeData.dark() ? ThemeData.light() : ThemeData.dark();
  }

  @override
  void dispose() {
    onDispose?.call();
    super.dispose();
  }
}

class MyAppWithNavigation extends MaterialApp {
  MyAppWithNavigation({super.key, required Widget child})
      : super(home: Scaffold(body: child));
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.onCounterNotifierDisposed,
    this.onThemeNotifierDisposed,
    this.counterNotifierValue,
    this.themeNotifierValue,
  });

  final VoidCallback? onCounterNotifierDisposed;
  final VoidCallback? onThemeNotifierDisposed;
  final CounterNotifier? counterNotifierValue;
  final ThemeNotifier? themeNotifierValue;

  @override
  Widget build(BuildContext context) {
    List<ValueNotifierProvider<ValueNotifier<Object?>>> getProviders() {
      final providers = <ValueNotifierProvider>[];
      if (counterNotifierValue != null) {
        providers.add(
          ValueNotifierProvider<CounterNotifier>.value(
            value: counterNotifierValue!,
          ),
        );
      } else {
        providers.add(
          ValueNotifierProvider<CounterNotifier>(
            create: (_) => CounterNotifier(
              onDispose: onCounterNotifierDisposed,
            ),
          ),
        );
      }

      if (themeNotifierValue != null) {
        providers.add(
          ValueNotifierProvider<ThemeNotifier>.value(
            value: themeNotifierValue!,
          ),
        );
      } else {
        providers.add(
          ValueNotifierProvider<ThemeNotifier>(
            create: (_) => ThemeNotifier(onDispose: onThemeNotifierDisposed),
          ),
        );
      }
      return providers;
    }

    return MultiValueNotifierProvider(
      providers: getProviders(),
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              ElevatedButton(
                key: const Key('pop_button'),
                child: const SizedBox(),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const SizedBox()),
                  );
                },
              ),
              ElevatedButton(
                key: const Key('increment_button'),
                child: const SizedBox(),
                onPressed: () =>
                    ValueNotifierProvider.of<CounterNotifier>(context)
                        .increment(),
              ),
              ElevatedButton(
                key: const Key('toggle_theme_button'),
                child: const SizedBox(),
                onPressed: () =>
                    ValueNotifierProvider.of<ThemeNotifier>(context).toggle(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueNotifierBuilder<ThemeNotifier, ThemeData>(
      notifier: ValueNotifierProvider.of<ThemeNotifier>(context),
      builder: (_, theme) {
        return MaterialApp(home: const CounterPage(), theme: theme);
      },
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final counterNotifier = ValueNotifierProvider.of<CounterNotifier>(context);

    return Scaffold(
      body: ValueNotifierBuilder<CounterNotifier, int>(
        notifier: counterNotifier,
        builder: (context, count) {
          return Center(
            child: Text('$count', key: const Key('counter_text')),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('pop_button'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

void main() {
  group('MultiValueNotifierProvider', () {
    testWidgets('passes notifiers to children', (tester) async {
      await tester.pumpWidget(
        MultiValueNotifierProvider(
          providers: [
            ValueNotifierProvider<CounterNotifier>(
              create: (_) => CounterNotifier(),
            ),
            ValueNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier())
          ],
          child: const TestApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.light());

      final counterFinder = find.byKey(const Key('counter_text'));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '0');
    });

    testWidgets('passes notifiers to children without explicit values',
        (tester) async {
      await tester.pumpWidget(
        MultiValueNotifierProvider(
          providers: [
            ValueNotifierProvider(create: (_) => CounterNotifier()),
            ValueNotifierProvider(create: (_) => ThemeNotifier())
          ],
          child: const TestApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.light());

      final counterFinder = find.byKey(const Key('counter_text'));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '0');
    });

    testWidgets('adds event to each notifier', (tester) async {
      await tester.pumpWidget(
        MultiValueNotifierProvider(
          providers: [
            ValueNotifierProvider<CounterNotifier>(
              create: (_) => CounterNotifier()..decrement(),
            ),
            ValueNotifierProvider<ThemeNotifier>(
              create: (_) => ThemeNotifier()..toggle(),
            ),
          ],
          child: const TestApp(),
        ),
      );

      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.dark());

      final counterFinder = find.byKey(const Key('counter_text'));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '-1');
    });

    testWidgets('close on counter notifier which was loaded (lazily)',
        (tester) async {
      var counterNotifierClosed = false;
      var themeNotifierClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterNotifierDisposed: () => counterNotifierClosed = true,
            onThemeNotifierDisposed: () => themeNotifierClosed = true,
          ),
        ),
      );

      expect(counterNotifierClosed, false);
      expect(themeNotifierClosed, false);

      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterNotifierClosed, true);
      expect(themeNotifierClosed, false);
    });

    testWidgets('close on theme notifier which was loaded (lazily)',
        (tester) async {
      var counterNotifierClosed = false;
      var themeNotifierClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterNotifierDisposed: () => counterNotifierClosed = true,
            onThemeNotifierDisposed: () => themeNotifierClosed = true,
          ),
        ),
      );

      expect(counterNotifierClosed, false);
      expect(themeNotifierClosed, false);

      await tester.tap(find.byKey(const Key('toggle_theme_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterNotifierClosed, false);
      expect(themeNotifierClosed, true);
    });

    testWidgets('close on all notifiers which were loaded (lazily)',
        (tester) async {
      var counterNotifierClosed = false;
      var themeNotifierClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterNotifierDisposed: () => counterNotifierClosed = true,
            onThemeNotifierDisposed: () => themeNotifierClosed = true,
          ),
        ),
      );

      expect(counterNotifierClosed, false);
      expect(themeNotifierClosed, false);
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('toggle_theme_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterNotifierClosed, true);
      expect(themeNotifierClosed, true);
    });

    testWidgets(
        'does not call close on notifiers if they were not loaded (lazily)',
        (tester) async {
      var counterNotifierClosed = false;
      var themeNotifierClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterNotifierDisposed: () => counterNotifierClosed = true,
            onThemeNotifierDisposed: () => themeNotifierClosed = true,
          ),
        ),
      );

      expect(counterNotifierClosed, false);
      expect(themeNotifierClosed, false);

      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterNotifierClosed, false);
      expect(themeNotifierClosed, false);
    });

    testWidgets('does not close when created using value', (tester) async {
      var counterNotifierClosed = false;
      var themeNotifierClosed = false;

      final counterNotifier = CounterNotifier(
        onDispose: () => counterNotifierClosed = true,
      );
      final themeNotifier = ThemeNotifier(
        onDispose: () => themeNotifierClosed = true,
      );

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            counterNotifierValue: counterNotifier,
            themeNotifierValue: themeNotifier,
          ),
        ),
      );

      expect(counterNotifierClosed, false);
      expect(themeNotifierClosed, false);

      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterNotifierClosed, false);
      expect(themeNotifierClosed, false);
    });
  });
}
