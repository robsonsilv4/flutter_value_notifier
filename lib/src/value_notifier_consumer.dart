import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

/// {@template value_notifier_consumer}
/// [ValueNotifierConsumer] exposes a [builder] and [listener] in order react
/// to new values.
/// [ValueNotifierConsumer] is analogous to a nested [ValueNotifierListener]
/// and [ValueNotifierBuilder] but reduces the amount of boilerplate needed.
/// [ValueNotifierConsumer] should only be used when it is necessary to both
/// rebuild UI and execute other reactions to value changes in the
/// [notifier].
///
/// [ValueNotifierConsumer] takes a required `ValueNotifierWidgetBuilder`
/// and [ValueNotifierWidgetListener] and an optional [notifier],
/// `ValueNotifierBuilderCondition`, and `ValueNotifierListenerCondition`.
///
/// If the [notifier] parameter is omitted, [ValueNotifierConsumer] will
/// automatically perform a lookup using `ValueNotifierProvider` and the current
/// [BuildContext].
///
/// ```dart
/// ValueNotifierConsumer<NotifierA, NotifierAValue>(
///   listener: (context, value) {
///     // do stuff here based on NotifierA's value
///   },
///   builder: (context, value) {
///     // return widget here based on NotifierA's value
///   }
/// )
/// ```
///
/// An optional [listenWhen] and [buildWhen] can be implemented for more
/// granular control over when [listener] and [builder] are called.
/// The [listenWhen] and [buildWhen] will be invoked on each [notifier]
/// `value` change.
/// They each take the previous `value` and current `value` and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous `value` will be initialized to the `value` of the
/// [notifier] when the [ValueNotifierConsumer] is initialized.
/// [listenWhen] and [buildWhen] are optional and if they aren't implemented,
/// they will default to `true`.
///
/// ```dart
/// ValueNotifierConsumer<NotifierA, NotifierAValue>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with value
///   },
///   listener: (context, value) {
///     // do stuff here based on NotifierA's value
///   },
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
class ValueNotifierConsumer<VN extends ValueNotifier<V>, V>
    extends StatefulWidget {
  /// {@macro value_notifier_consumer}
  const ValueNotifierConsumer({
    super.key,
    required this.builder,
    required this.listener,
    this.notifier,
    this.buildWhen,
    this.listenWhen,
  });

  /// The [notifier] that the [ValueNotifierConsumer] will interact with.
  /// If omitted, [ValueNotifierConsumer] will automatically perform a lookup
  /// using [ValueNotifierProvider] and the current `BuildContext`.
  final VN? notifier;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `value` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [ValueListenableBuilder].
  final ValueNotifierWidgetBuilder<V> builder;

  /// Takes the `BuildContext` along with the [notifier] `value`
  /// and is responsible for executing in response to `value` changes.
  final ValueNotifierWidgetListener<V> listener;

  /// Takes the previous `value` and the current `value` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `value`.
  final ValueNotifierBuilderCondition<V>? buildWhen;

  /// Takes the previous `value` and the current `value` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener] of
  /// [ValueNotifierConsumer] with the current `value`.
  final ValueNotifierListenerCondition<V>? listenWhen;

  @override
  State<ValueNotifierConsumer<VN, V>> createState() =>
      _ValueNotifierConsumerState<VN, V>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<VN?>('notifier', notifier))
      ..add(
        ObjectFlagProperty<ValueNotifierWidgetBuilder<V>>.has(
          'builder',
          builder,
        ),
      )
      ..add(
        ObjectFlagProperty<ValueNotifierWidgetListener<V>>.has(
          'listener',
          listener,
        ),
      )
      ..add(
        ObjectFlagProperty<ValueNotifierBuilderCondition<V>?>.has(
          'buildWhen',
          buildWhen,
        ),
      )
      ..add(
        ObjectFlagProperty<ValueNotifierListenerCondition<V>?>.has(
          'listenWhen',
          listenWhen,
        ),
      );
  }
}

class _ValueNotifierConsumerState<VN extends ValueNotifier<V>, V>
    extends State<ValueNotifierConsumer<VN, V>> {
  late VN _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? context.read<VN>();
  }

  @override
  void didUpdateWidget(ValueNotifierConsumer<VN, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldNotifier = oldWidget.notifier ?? context.read<VN>();
    final currentNotifier = widget.notifier ?? oldNotifier;
    if (oldNotifier != currentNotifier) {
      _notifier = currentNotifier;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = widget.notifier ?? context.read<VN>();
    if (_notifier != notifier) _notifier = notifier;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notifier == null) {
      context.select<VN, bool>((notifier) => identical(_notifier, notifier));
    }
    return ValueNotifierBuilder<VN, V>(
      notifier: _notifier,
      builder: widget.builder,
      buildWhen: (previous, current) {
        if (widget.listenWhen?.call(previous, current) ?? true) {
          widget.listener(context, current);
        }
        return widget.buildWhen?.call(previous, current) ?? true;
      },
    );
  }
}
