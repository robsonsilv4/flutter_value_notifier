import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

class Dependency {
  const Dependency(this.data);

  final int data;
}

class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    required this.dependency,
    required this.child,
    this.useValueProvider = false,
  });

  final Dependency dependency;
  final Widget child;
  final bool useValueProvider;

  @override
  Widget build(BuildContext context) {
    if (useValueProvider == true) {
      return MaterialApp(
        home: DependencyProvider<Dependency>.value(
          value: dependency,
          child: child,
        ),
      );
    }
    return MaterialApp(
      home: DependencyProvider<Dependency>(
        create: (_) => dependency,
        child: child,
      ),
    );
  }
}

class TestStatefulApp extends StatefulWidget {
  const TestStatefulApp({super.key, required this.child});

  final Widget child;

  @override
  State<TestStatefulApp> createState() => _TestStatefulAppState();
}

class _TestStatefulAppState extends State<TestStatefulApp> {
  late Dependency _dependency;

  @override
  void initState() {
    _dependency = const Dependency(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DependencyProvider<Dependency>(
        create: (_) => _dependency,
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                key: const Key('iconButtonKey'),
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() => _dependency = const Dependency(0));
                },
              ),
            ],
          ),
          body: widget.child,
        ),
      ),
    );
  }
}

class TestAppNoProvider extends MaterialApp {
  const TestAppNoProvider({super.key, required Widget child})
      : super(home: child);
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key, this.onBuild});

  final VoidCallback? onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild?.call();
    final dependency = DependencyProvider.of<Dependency>(context);
    return Scaffold(
      body: Text('${dependency.data}', key: const Key('value_data')),
    );
  }
}

void main() {
  group('DependencyProvider', () {
    testWidgets('lazily loads dependencies by default', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        DependencyProvider(
          create: (_) {
            createCalled = true;
            return const Dependency(0);
          },
          child: const SizedBox(),
        ),
      );
      expect(createCalled, isFalse);
    });

    testWidgets('can override lazy loading', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        DependencyProvider(
          create: (_) {
            createCalled = true;
            return const Dependency(0);
          },
          lazy: false,
          child: const SizedBox(),
        ),
      );
      expect(createCalled, isTrue);
    });

    testWidgets('passes value to children via builder', (tester) async {
      const dependency = Dependency(0);
      const child = CounterPage();
      await tester.pumpWidget(
        const TestApp(dependency: dependency, child: child),
      );
      final counterFinder = find.byKey(const Key('value_data'));
      expect(counterFinder, findsOneWidget);
      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '0');
    });

    testWidgets('passes value to children via value', (tester) async {
      const dependency = Dependency(0);
      const child = CounterPage();
      await tester.pumpWidget(
        const TestApp(
          dependency: dependency,
          useValueProvider: true,
          child: child,
        ),
      );
      final counterFinder = find.byKey(const Key('value_data'));
      expect(counterFinder, findsOneWidget);
      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '0');
    });

    testWidgets(
      'should throw FlutterError if DependencyProvider is not found in current '
      'context',
      (tester) async {
        const child = CounterPage();
        await tester.pumpWidget(const TestAppNoProvider(child: child));
        final dynamic exception = tester.takeException();
        const expectedMessage = '''
        DependencyProvider.of() called with a context that does not contain a dependency of type Dependency.
        No ancestor could be found starting from the context that was passed to DependencyProvider.of<Dependency>().

        This can happen if the context you used comes from a widget above the DependencyProvider.

        The context used was: CounterPage(dirty)
        ''';
        expect(exception is FlutterError, true);
        expect(
          (exception as FlutterError).message.trim(),
          expectedMessage.trim(),
        );
      },
    );

    testWidgets(
      'should throw StateError if internal exception is thrown',
      (tester) async {
        const expected = 'Tried to read a provider that threw '
            'during the creation of its value.\n'
            'The exception occurred during the creation of type Dependency.';
        final onError = FlutterError.onError;
        final flutterErrors = <FlutterErrorDetails>[];
        FlutterError.onError = flutterErrors.add;
        await tester.pumpWidget(
          DependencyProvider<Dependency>(
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
      },
    );

    testWidgets(
        'should throw StateError '
        'if exception is for different provider', (tester) async {
      const expected = 'Tried to read a provider that threw '
          'during the creation of its value.\n'
          'The exception occurred during the creation of type Dependency.';
      final onError = FlutterError.onError;
      final flutterErrors = <FlutterErrorDetails>[];
      FlutterError.onError = flutterErrors.add;
      await tester.pumpWidget(
        DependencyProvider<Dependency>(
          lazy: false,
          create: (context) {
            context.read<int>();
            return const Dependency(0);
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
        'should not rebuild widgets that inherited the value if the value is '
        'changed', (tester) async {
      var numBuilds = 0;
      final child = CounterPage(onBuild: () => numBuilds++);
      await tester.pumpWidget(TestStatefulApp(child: child));
      await tester.tap(find.byKey(const Key('iconButtonKey')));
      await tester.pump();
      expect(numBuilds, 1);
    });

    testWidgets(
        'should rebuild widgets that inherited the value if the value is '
        'changed with context.watch', (tester) async {
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              var dependency = const Dependency(0);
              return DependencyProvider.value(
                value: dependency,
                child: StatefulBuilder(
                  builder: (context, _) {
                    numBuilds++;
                    final data = context.watch<Dependency>().data;
                    return TextButton(
                      child: Text('Data: $data'),
                      onPressed: () {
                        setState(() => dependency = const Dependency(1));
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(numBuilds, 2);
    });

    testWidgets(
        'should rebuild widgets that inherited the value if the value is '
        'changed with listen: true', (tester) async {
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              var dependency = const Dependency(0);
              return DependencyProvider.value(
                value: dependency,
                child: StatefulBuilder(
                  builder: (context, _) {
                    numBuilds++;
                    final data =
                        DependencyProvider.of<Dependency>(context, listen: true)
                            .data;
                    return TextButton(
                      child: Text('Data: $data'),
                      onPressed: () {
                        setState(() => dependency = const Dependency(1));
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(numBuilds, 2);
    });

    testWidgets(
      'should access dependency instance '
      'via context.read',
      (tester) async {
        await tester.pumpWidget(
          DependencyProvider(
            create: (_) => const Dependency(0),
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Builder(
                    builder: (context) => Text(
                      '${context.read<Dependency>().data}',
                      key: const Key('value_data'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final counterFinder = find.byKey(const Key('value_data'));
        expect(counterFinder, findsOneWidget);
        final counterText = counterFinder.evaluate().first.widget as Text;
        expect(counterText.data, '0');
      },
    );
  });
}
