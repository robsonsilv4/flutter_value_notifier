import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

class ThemeNotifier extends ValueNotifier<ThemeData> {
  ThemeNotifier() : super(ThemeData.light());

  void setDarkTheme() => value = ThemeData.dark();
  void setLightTheme() => value = ThemeData.light();
}

class DarkThemeNotifier extends ValueNotifier<ThemeData> {
  DarkThemeNotifier() : super(ThemeData.dark());

  void setDarkTheme() => value = ThemeData.dark();
  void setLightTheme() => value = ThemeData.light();
}

class ThemeApp extends StatefulWidget {
  const ThemeApp({
    super.key,
    required ValueNotifier<ThemeData> themeValueNotifier,
    required void Function() onBuild,
  })  : _themeValueNotifier = themeValueNotifier,
        _onBuild = onBuild;

  final ValueNotifier<ThemeData> _themeValueNotifier;
  final void Function() _onBuild;

  @override
  // ignore: no_logic_in_create_state
  State<ThemeApp> createState() => ThemeAppState(
        themeValueNotifier: _themeValueNotifier,
        onBuild: _onBuild,
      );
}

class ThemeAppState extends State<ThemeApp> {
  ThemeAppState({
    required ValueNotifier<ThemeData> themeValueNotifier,
    required void Function() onBuild,
  })  : _themeValueNotifier = themeValueNotifier,
        _onBuild = onBuild;

  ValueNotifier<ThemeData> _themeValueNotifier;
  final void Function() _onBuild;

  @override
  Widget build(BuildContext context) {
    return ValueNotifierBuilder<ValueNotifier<ThemeData>, ThemeData>(
      notifier: _themeValueNotifier,
      // ignore: unnecessary_parenthesis
      builder: ((context, theme) {
        _onBuild();
        return MaterialApp(
          key: const Key('material_app'),
          theme: theme,
          home: Column(
            children: [
              ElevatedButton(
                key: const Key('elevated_button_1'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() {
                    _themeValueNotifier = DarkThemeNotifier();
                  });
                },
              ),
              ElevatedButton(
                key: const Key('elevated_button_2'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() {
                    _themeValueNotifier = _themeValueNotifier;
                  });
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

class CounterNotifier extends ValueNotifier<int> {
  CounterNotifier({int seed = 0}) : super(seed);

  void increment() => value = value + 1;
  void decrement() => value = value - 1;
}

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<StatefulWidget> createState() => CounterAppState();
}

class CounterAppState extends State<CounterApp> {
  final CounterNotifier _notifier = CounterNotifier();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: const Key('counterApp'),
        body: Column(
          children: <Widget>[
            ValueNotifierBuilder<CounterNotifier, int>(
              notifier: _notifier,
              buildWhen: (previousValue, value) {
                return (previousValue + value) % 3 == 0;
              },
              builder: (_, count) {
                return Text(
                  '$count',
                  key: const Key('counterAppTextCondition'),
                );
              },
            ),
            ValueNotifierBuilder<CounterNotifier, int>(
              notifier: _notifier,
              builder: (_, count) {
                return Text(
                  '$count',
                  key: const Key('counterAppText'),
                );
              },
            ),
            ElevatedButton(
              key: const Key('counterAppIncrementButton'),
              onPressed: _notifier.increment,
              child: const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class CounterValueNotifier extends ValueNotifier<int> {
  CounterValueNotifier({int seed = 0}) : super(seed);

  void increment() => value = value + 1;
  void decrement() => value = value - 1;
}

void main() {
  group('ValueNotifierBuilder', () {
    testWidgets(
      'passes initial value to widget',
      (tester) async {
        final themeValueNotifier = ThemeNotifier();
        var numBuilds = 0;
        await tester.pumpWidget(
          ThemeApp(
            themeValueNotifier: themeValueNotifier,
            onBuild: () => numBuilds++,
          ),
        );
        final materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.light());
        expect(numBuilds, 1);
      },
    );

    testWidgets(
      'receives events and sends value updates to widget',
      (tester) async {
        final themeValueNotifier = ThemeNotifier();
        var numBuilds = 0;
        await tester.pumpWidget(
          ThemeApp(
            themeValueNotifier: themeValueNotifier,
            onBuild: () => numBuilds++,
          ),
        );
        themeValueNotifier.setDarkTheme();
        await tester.pumpAndSettle();
        final materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.dark());
        expect(numBuilds, 2);
      },
    );

    testWidgets(
      'infers the valueNotifier from the context if the valueNotifier is '
      'not provided',
      (tester) async {
        final themeValueNotifier = ThemeNotifier();
        var numBuilds = 0;
        await tester.pumpWidget(
          ValueNotifierProvider.value(
            value: themeValueNotifier,
            child: ValueNotifierBuilder<ThemeNotifier, ThemeData>(
              builder: (_, theme) {
                numBuilds++;
                return MaterialApp(
                  key: const Key('material_app'),
                  theme: theme,
                  home: const SizedBox(),
                );
              },
            ),
          ),
        );
        themeValueNotifier.setDarkTheme();
        await tester.pumpAndSettle();
        var materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.dark());
        expect(numBuilds, 2);
        themeValueNotifier.setLightTheme();
        await tester.pumpAndSettle();
        materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.light());
        expect(numBuilds, 3);
      },
    );

    testWidgets(
      'updates valueNotifier and performs new lookup when widget is updated',
      (tester) async {
        final themeValueNotifier = ThemeNotifier();
        var numBuilds = 0;
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) => ValueNotifierProvider.value(
              value: themeValueNotifier,
              child: ValueNotifierBuilder<ThemeNotifier, ThemeData>(
                builder: (_, theme) {
                  numBuilds++;
                  return MaterialApp(
                    key: const Key('material_app'),
                    theme: theme,
                    home: ElevatedButton(
                      child: const SizedBox(),
                      onPressed: () => setState(() {}),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        final materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.light());
        expect(numBuilds, 2);
      },
    );

    testWidgets(
      'updates when the valueNotifier is changed at runtime to a different  '
      'valueNotifier and unsubscribes from old valueNotifier',
      (tester) async {
        final themeValueNotifier = ThemeNotifier();
        var numBuilds = 0;
        await tester.pumpWidget(
          ThemeApp(
            themeValueNotifier: themeValueNotifier,
            onBuild: () => numBuilds++,
          ),
        );
        await tester.pumpAndSettle();
        var materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.light());
        expect(numBuilds, 1);
        await tester.tap(find.byKey(const Key('elevated_button_1')));
        await tester.pumpAndSettle();
        materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.dark());
        expect(numBuilds, 2);
        themeValueNotifier.setLightTheme();
        await tester.pumpAndSettle();
        materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.dark());
        expect(numBuilds, 2);
      },
    );

    testWidgets(
      'does not update when the valueNotifier is changed at runtime to same '
      'valueNotifier and stays subscribed to current valueNotifier',
      (tester) async {
        final themeValueNotifier = DarkThemeNotifier();
        var numBuilds = 0;
        await tester.pumpWidget(
          ThemeApp(
            themeValueNotifier: themeValueNotifier,
            onBuild: () => numBuilds++,
          ),
        );
        await tester.pumpAndSettle();
        var materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.dark());
        expect(numBuilds, 1);
        await tester.tap(find.byKey(const Key('elevated_button_2')));
        await tester.pumpAndSettle();
        materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.dark());
        expect(numBuilds, 2);
        themeValueNotifier.setLightTheme();
        await tester.pumpAndSettle();
        materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.light());
        expect(numBuilds, 3);
      },
    );

    testWidgets(
      'shows latest value instead of initial value',
      (tester) async {
        final themeValueNotifier = ThemeNotifier()..setDarkTheme();
        await tester.pumpAndSettle();
        var numBuilds = 0;
        await tester.pumpWidget(
          ThemeApp(
            themeValueNotifier: themeValueNotifier,
            onBuild: () => numBuilds++,
          ),
        );
        await tester.pumpAndSettle();
        final materialApp = tester.widget<MaterialApp>(
          find.byKey(const Key('material_app')),
        );
        expect(materialApp.theme, ThemeData.dark());
        expect(numBuilds, 1);
      },
    );

    testWidgets(
      'with buildWhen only rebuilds when buildWhen evaluates to true',
      (tester) async {
        await tester.pumpWidget(const CounterApp());
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('counterApp')), findsOneWidget);
        final incrementButtonFinder =
            find.byKey(const Key('counterAppIncrementButton'));
        expect(incrementButtonFinder, findsOneWidget);
        final counterText1 =
            tester.widget<Text>(find.byKey(const Key('counterAppText')));
        expect(counterText1.data, '0');
        final conditionalCounterText1 = tester
            .widget<Text>(find.byKey(const Key('counterAppTextCondition')));
        expect(conditionalCounterText1.data, '0');
        await tester.tap(incrementButtonFinder);
        await tester.pumpAndSettle();
        final counterText2 =
            tester.widget<Text>(find.byKey(const Key('counterAppText')));
        expect(counterText2.data, '1');
        final conditionalCounterText2 = tester
            .widget<Text>(find.byKey(const Key('counterAppTextCondition')));
        expect(conditionalCounterText2.data, '0');
        await tester.tap(incrementButtonFinder);
        await tester.pumpAndSettle();
        final counterText3 =
            tester.widget<Text>(find.byKey(const Key('counterAppText')));
        expect(counterText3.data, '2');
        final conditionalCounterText3 = tester
            .widget<Text>(find.byKey(const Key('counterAppTextCondition')));
        expect(conditionalCounterText3.data, '2');
        await tester.tap(incrementButtonFinder);
        await tester.pumpAndSettle();
        final counterText4 =
            tester.widget<Text>(find.byKey(const Key('counterAppText')));
        expect(counterText4.data, '3');
        final conditionalCounterText4 = tester
            .widget<Text>(find.byKey(const Key('counterAppTextCondition')));
        expect(conditionalCounterText4.data, '2');
      },
    );

    testWidgets(
      'calls buildWhen and builder with correct value',
      (tester) async {
        final buildWhenPreviousValue = <int>[];
        final buildWhenCurrentValue = <int>[];
        final values = <int>[];
        final counterValueNotifier = CounterNotifier();
        await tester.pumpWidget(
          ValueNotifierBuilder<CounterNotifier, int>(
            notifier: counterValueNotifier,
            buildWhen: (previous, value) {
              if (value.isEven) {
                buildWhenPreviousValue.add(previous);
                buildWhenCurrentValue.add(value);
                return true;
              }
              return false;
            },
            builder: (_, value) {
              values.add(value);
              return const SizedBox();
            },
          ),
        );
        await tester.pump();
        counterValueNotifier
          ..increment()
          ..increment()
          ..increment();
        await tester.pumpAndSettle();
        expect(values, [0, 2]);
        expect(buildWhenPreviousValue, [1]);
        expect(buildWhenCurrentValue, [2]);
      },
    );

    testWidgets(
      'does not rebuild with latest value when buildWhen is false and widget '
      'is updated',
      (tester) async {
        const key = Key('__target__');
        final values = <int>[];
        final counterValueNotifier = CounterNotifier();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: StatefulBuilder(
              builder: (_, setState) =>
                  ValueNotifierBuilder<CounterNotifier, int>(
                notifier: counterValueNotifier,
                buildWhen: (_, value) => value.isEven,
                builder: (_, value) {
                  values.add(value);
                  return ElevatedButton(
                    key: key,
                    child: const SizedBox(),
                    onPressed: () => setState(() {}),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pump();
        counterValueNotifier
          ..increment()
          ..increment()
          ..increment();
        await tester.pumpAndSettle();
        expect(values, [0, 2]);
        await tester.tap(find.byKey(key));
        await tester.pumpAndSettle();
        expect(values, [0, 2, 2]);
      },
    );

    testWidgets(
      'rebuilds when provided valueNotifier is changed',
      (tester) async {
        final firstCounterValueNotifier = CounterNotifier();
        final secondCounterValueNotifier = CounterNotifier(seed: 100);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: ValueNotifierProvider.value(
              value: firstCounterValueNotifier,
              child: ValueNotifierBuilder<CounterNotifier, int>(
                builder: (_, value) => Text('Count $value'),
              ),
            ),
          ),
        );
        expect(find.text('Count 0'), findsOneWidget);
        firstCounterValueNotifier.increment();
        await tester.pumpAndSettle();
        expect(find.text('Count 1'), findsOneWidget);
        expect(find.text('Count 0'), findsNothing);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: ValueNotifierProvider.value(
              value: secondCounterValueNotifier,
              child: ValueNotifierBuilder<CounterNotifier, int>(
                builder: (_, value) => Text('Count $value'),
              ),
            ),
          ),
        );
        expect(find.text('Count 100'), findsOneWidget);
        expect(find.text('Count 1'), findsNothing);
        secondCounterValueNotifier.increment();
        await tester.pumpAndSettle();
        expect(find.text('Count 101'), findsOneWidget);
      },
    );

    testWidgets('overrides debugFillProperties', (tester) async {
      final builder = DiagnosticPropertiesBuilder();

      ValueNotifierBuilder(
        notifier: CounterNotifier(),
        builder: (context, state) => const SizedBox(),
        buildWhen: (previous, current) => previous != current,
      ).debugFillProperties(builder);

      final description = builder.properties
          .where((node) => !node.isFiltered(DiagnosticLevel.info))
          .map((node) => node.toString())
          .toList();

      expect(description, contains('has buildWhen'));
      expect(description, anyElement(contains('notifier: CounterNotifier')));
      expect(description, contains('has builder'));
    });
  });
}
