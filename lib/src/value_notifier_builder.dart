import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

/// Signature for the `builder` function which takes the `BuildContext` and
/// [value] and is responsible for returning a widget which is to be rendered.
/// This is analogous to the `builder` function in [ValueListenableBuilder].
typedef ValueNotifierWidgetBuilder<V> = Widget Function(
  BuildContext context,
  V value,
);

/// Signature for the `buildWhen` function which takes the previous `value` and
/// the current `value` and is responsible for returning a [bool] which
/// determines whether to rebuild [ValueNotifierBuilder] with the current
/// `value`.
typedef ValueNotifierBuilderCondition<V> = bool Function(V previous, V current);

/// {@template value_notifier_builder}
/// [ValueNotifierBuilder] handles building a widget in response to new
/// `values`.
/// [ValueNotifierBuilder] is analogous to [ValueListenableBuilder] but has
/// simplified API to reduce the amount of boilerplate code needed as well as
/// [notifier]-specific performance improvements.
/// Please refer to [ValueNotifierListener] if you want to "do" anything in
/// response to `value` changes such as navigation, showing a dialog, etc...
///
/// If the [notifier] parameter is omitted, [ValueNotifierBuilder] will
/// automatically perform a lookup using [ValueNotifierProvider] and the current
/// [BuildContext].
///
/// ```dart
/// ValueNotifierBuilder<NotifierA, NotifierAValue>(
///   builder: (context, value) {
///   // return widget here based on NotifierA's value
///   }
/// )
/// ```
///
/// Only specify the [notifier] if you wish to provide a [notifier]
/// that is otherwise not accessible via [ValueNotifierProvider] and the current
/// [BuildContext].
///
/// ```dart
/// ValueNotifierBuilder<NotifierA, NotifierAValue>(
///   notifier: blocA,
///   builder: (context, value) {
///   // return widget here based on NotifierA's value
///   }
/// )
/// ```
/// {@endtemplate}
///
/// {@template value_notifier_builder_build_when}
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [ValueNotifierBuilder] rebuilds.
/// [buildWhen] should only be used for performance optimizations as it
/// provides no security about the value passed to the [builder] function.
/// [buildWhen] will be invoked on each [notifier] `value` change.
/// [buildWhen] takes the previous `value` and current `value` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `value` will be initialized to the `value` of the [notifier]
/// when the [ValueNotifierBuilder] is initialized.
/// [buildWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// ValueNotifierBuilder<NotifierA, NotifierAValue>(
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with value
///   },
///   builder: (context, value) {
///     // return widget here based on NotifierA's value
///   }
/// )
/// ```
/// {@endtemplate}
class ValueNotifierBuilder<VN extends ValueNotifier<V>, V>
    extends ValueNotifierBuilderBase<VN, V> {
  /// {@macro value_notifier_builder}
  /// {@macro value_notifier_builder_build_when}
  const ValueNotifierBuilder({
    super.key,
    required this.builder,
    super.notifier,
    super.buildWhen,
  });

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `value` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [ValueListenableBuilder].
  final ValueNotifierWidgetBuilder<V> builder;

  @override
  Widget build(BuildContext context, V value) => builder(context, value);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<ValueNotifierWidgetBuilder<V>>.has('builder', builder),
    );
  }
}

/// {@template value_notifier_builder_base}
/// Base class for widgets that build themselves based on interaction with
/// a specified [notifier].
///
/// A [ValueNotifierBuilderBase] is stateful and maintains the value of the
/// interaction so far. The type of the value and how it is updated with each
/// interaction is defined by sub-classes.
/// {@endtemplate}
abstract class ValueNotifierBuilderBase<VN extends ValueNotifier<V>, V>
    extends StatefulWidget {
  /// {@macro value_notifier_builder_base}
  const ValueNotifierBuilderBase({
    super.key,
    this.notifier,
    this.buildWhen,
  });

  /// The [notifier] that the [ValueNotifierBuilderBase] will interact with.
  /// If omitted, [ValueNotifierBuilderBase] will automatically perform a lookup
  /// using [ValueNotifierProvider] and the current [BuildContext].
  final VN? notifier;

  /// {@macro value_notifier_builder_build_when}
  final ValueNotifierBuilderCondition<V>? buildWhen;

  /// Returns a widget based on the `BuildContext` and current [value].
  Widget build(BuildContext context, V value);

  @override
  State<ValueNotifierBuilderBase<VN, V>> createState() =>
      _ValueNotifierBuilderBaseState<VN, V>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ObjectFlagProperty<ValueNotifierBuilderCondition<V>?>.has(
          'buildWhen',
          buildWhen,
        ),
      )
      ..add(DiagnosticsProperty<VN?>('notifier', notifier));
  }
}

class _ValueNotifierBuilderBaseState<VN extends ValueNotifier<V>, V>
    extends State<ValueNotifierBuilderBase<VN, V>> {
  late VN _notifier;
  late V _value;

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? context.read<VN>();
    _value = _notifier.value;
  }

  @override
  void didUpdateWidget(ValueNotifierBuilderBase<VN, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldNotifier = oldWidget.notifier ?? context.read<VN>();
    final currentNotifier = widget.notifier ?? oldNotifier;
    if (oldNotifier != currentNotifier) {
      _notifier = currentNotifier;
      _value = _notifier.value;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = widget.notifier ?? context.read<VN>();
    if (_notifier != notifier) {
      _notifier = notifier;
      _value = _notifier.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notifier == null) {
      context.select<VN, bool>((notifier) => identical(_notifier, notifier));
    }
    return ValueNotifierListener<VN, V>(
      notifier: _notifier,
      listenWhen: widget.buildWhen,
      listener: (_, value) => setState(() => _value = value),
      child: widget.build(context, _value),
    );
  }
}
