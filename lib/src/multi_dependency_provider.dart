import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/src/dependency_provider.dart';
import 'package:provider/provider.dart';

/// {@template multi_dependency_provider}
/// Merges multiple [DependencyProvider] widgets into one widget tree.
///
/// [MultiDependencyProvider] improves the readability and eliminates the need
/// to nest multiple [DependencyProvider]s.
///
/// By using [MultiDependencyProvider] we can go from:
///
/// ```dart
/// DependencyProvider<DependencyA>(
///   create: (context) => DependencyA(),
///   child: DependencyProvider<DependencyB>(
///     create: (context) => DependencyB(),
///     child: DependencyProvider<DependencyC>(
///       create: (context) => DependencyC(),
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiDependencyProvider(
///   providers: [
///     DependencyProvider<DependencyA>(create: (context) => DependencyA()),
///     DependencyProvider<DependencyB>(create: (context) => DependencyB()),
///     DependencyProvider<DependencyC>(create: (context) => DependencyC()),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiDependencyProvider] converts the [DependencyProvider] list into a tree
/// of nested [DependencyProvider] widgets.
/// As a result, the only advantage of using [MultiDependencyProvider] is
/// improved readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiDependencyProvider extends MultiProvider {
  /// {@macro multi_dependency_provider}
  MultiDependencyProvider({
    super.key,
    required super.providers,
    required Widget super.child,
  });
}
