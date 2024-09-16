import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/src/value_notifier_provider.dart';
import 'package:provider/provider.dart';

/// {@template multi_value_notifier_provider}
/// Merges multiple [ValueNotifierProvider] widgets into one widget tree.
///
/// [MultiValueNotifierProvider] improves the readability and eliminates the
/// need to nest multiple [ValueNotifierProvider]s.
///
/// By using [MultiValueNotifierProvider] we can go from:
///
/// ```dart
/// ValueNotifierProvider<BlocA>(
///   create: (context) => NotifierA(),
///   child: ValueNotifierProvider<NotifierB>(
///     create: (context) => NotifierB(),
///     child: ValueNotifierProvider<NotifierC>(
///       create: (context) => NotifierC(),
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiValueNotifierProvider(
///   providers: [
///     ValueNotifierProvider<NotifierA>(
///       create: (context) => NotifierA(),
///     ),
///     ValueNotifierProvider<NotifierB>(
///       create: (context) => NotifierB(),
///     ),
///     ValueNotifierProvider<NotifierC>(
///       create: (context) => NotifierC(),
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiValueNotifierProvider] converts the [ValueNotifierProvider] list into
/// a tree of nested [ValueNotifierProvider] widgets.
/// As a result, the only advantage of using [MultiValueNotifierProvider] is
/// improved readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiValueNotifierProvider extends MultiProvider {
  /// {@macro multi_value_notifier_provider}
  MultiValueNotifierProvider({
    super.key,
    required super.providers,
    required Widget super.child,
  });
}
