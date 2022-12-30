import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Mixin which allows `MultiDependencyProvider` to infer the types
/// of multiple [DependencyProvider]s.
mixin DependencyProviderSingleChildWidget on SingleChildWidget {}

/// {@template dependency_provider}
/// Takes a [Create] function that is responsible for creating the dependency
/// and a `child` which will have access to the dependency via
/// `DependencyProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a dependency can be provided to multiple widgets within a subtree.
///
/// ```dart
/// DependencyProvider(
///   create: (context) => DependencyA(),
///   child: ChildA(),
/// );
/// ```
///
/// Lazily creates the dependency unless `lazy` is set to `false`.
///
/// ```dart
/// DependencyProvider(
///   lazy: false,`
///   create: (context) => DependencyA(),
///   child: ChildA(),
/// );
/// ```
/// {@endtemplate}
class DependencyProvider<T> extends Provider<T>
    with DependencyProviderSingleChildWidget {
  /// {@macro dependency_provider}
  DependencyProvider({
    super.key,
    required super.create,
    super.child,
    super.lazy,
  }) : super(dispose: (_, __) {});

  /// Takes a dependency and a child which will have access to the dependency.
  /// A new dependency should not be created in `DependencyProvider.value`.
  /// Dependencies should always be created using the default constructor
  /// within the [Create] function.
  DependencyProvider.value({
    super.key,
    required super.value,
    super.child,
  }) : super.value();

  /// Method that allows widgets to access a dependency instance as long as
  /// their `BuildContext` contains a [DependencyProvider] instance.
  static T of<T>(BuildContext context, {bool listen = false}) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (exception) {
      if (exception.valueType != T) rethrow;
      throw FlutterError(
        '''
        DependencyProvider.of() called with a context that does not contain a dependency of type $T.
        No ancestor could be found starting from the context that was passed to DependencyProvider.of<$T>().

        This can happen if the context you used comes from a widget above the DependencyProvider.

        The context used was: $context
        ''',
      );
    }
  }
}
