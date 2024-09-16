import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/src/value_notifier_listener.dart';
import 'package:provider/provider.dart' show MultiProvider;
import 'package:provider/single_child_widget.dart';

/// {@template multi_value_notifier_listener}
/// Merges multiple [ValueNotifierListener] widgets into one widget tree.
///
/// [MultiValueNotifierListener] improves the readability and eliminates the
/// need to nest multiple [ValueNotifierListener]s.
///
/// By using [MultiValueNotifierListener] we can go from:
///
/// ```dart
/// ValueNotifierListener<NotifierA, NotifierAValue>(
///   listener: (context, value) {},
///   child: ValueNotifierListener<NotifierB, NotifierBValue>(
///     listener: (context, value) {},
///     child: ValueNotifierListener<NotifierC, NotifierCValue>(
///       listener: (context, value) {},
///       child: ChildA(),
///     ),
///   ),
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiValueNotifierListener(
///   listeners: [
///     ValueNotifierListener<NotifierA, NotifierAValue>(
///       listener: (context, value) {},
///     ),
///     ValueNotifierListener<NotifierB, NotifierBValue>(
///       listener: (context, value) {},
///     ),
///     ValueNotifierListener<NotifierC, NotifierCValue>(
///       listener: (context, value) {},
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiValueNotifierListener] converts the [ValueNotifierListener] list into
/// a tree of nested [ValueNotifierListener] widgets.
/// As a result, the only advantage of using [MultiValueNotifierListener] is
/// improved readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiValueNotifierListener extends MultiProvider {
  /// {@macro multi_value_notifier_listener}
  MultiValueNotifierListener({
    super.key,
    required List<SingleChildWidget> listeners,
    required Widget super.child,
  }) : super(providers: listeners);
}
