import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/src/value_notifier_provider.dart';
import 'package:provider/provider.dart';

/// {@template multi_value_notifier_provider}
/// Merges multiple [ValueNotifierProvider] widgets into one widget tree.
///
/// [MultiValueNotifierProvider] improves the readability and eliminates the
/// need to nest multiple [ValueNotifierProvider]s.
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
    required List<ValueNotifierProviderSingleChildWidget> super.providers,
    required Widget super.child,
  });
}
