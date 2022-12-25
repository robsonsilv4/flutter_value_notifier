import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

/// {@template value_notifier_consumer}
/// [ValueNotifierConsumer] exposes a [builder] and [listener] in order react
/// to new values.
/// [ValueNotifierConsumer] is analogous to a nested `ValueNotifierListener`
/// and `ValueNotifierBuilder` but reduces the amount of boilerplate needed.
/// [ValueNotifierConsumer] should only be used when it is necessary to both
/// rebuild UI and execute other reactions to value changes in the
/// [valueNotifier].
///
/// [ValueNotifierConsumer] takes a required `ValueNotifierWidgetBuilder`
/// and `ValueNotifierWidgetListener` and an optional [valueNotifier],
/// `ValueNotifierBuilderCondition`, and `ValueNotifierListenerCondition`.
///
/// If the [valueNotifier] parameter is omitted, [ValueNotifierConsumer] will
/// automatically perform a lookup using `ValueNotifierProvider` and the current
/// `BuildContext`.
///
/// An optional [listenWhen] and [buildWhen] can be implemented for more
/// granular control over when [listener] and [builder] are called.
/// The [listenWhen] and [buildWhen] will be invoked on each [valueNotifier]
/// `value` change.
/// They each take the previous `value` and current `value` and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous `value` will be initialized to the `value` of the
/// [valueNotifier] when the [ValueNotifierConsumer] is initialized.
/// [listenWhen] and [buildWhen] are optional and if they aren't implemented,
/// they will default to `true`.
/// {@endtemplate}
class ValueNotifierConsumer<VN extends ValueNotifier<V>, V>
    extends StatefulWidget {
  /// {@macro value_notifier_consumer}
  const ValueNotifierConsumer({
    super.key,
    required this.builder,
    required this.listener,
    this.valueNotifier,
    this.buildWhen,
    this.listenWhen,
  });

  /// The [valueNotifier] that the [ValueNotifierConsumer] will interact with.
  /// If omitted, [ValueNotifierConsumer] will automatically perform a lookup
  /// using `ValueNotifierProvider` and the current `BuildContext`.
  final VN? valueNotifier;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `value` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final ValueNotifierWidgetBuilder<V> builder;

  /// Takes the `BuildContext` along with the [valueNotifier] `value`
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
}

class _ValueNotifierConsumerState<VN extends ValueNotifier<V>, V>
    extends State<ValueNotifierConsumer<VN, V>> {
  late VN _valueNotifier;

  @override
  void initState() {
    super.initState();
    _valueNotifier = widget.valueNotifier ?? context.read<VN>();
  }

  @override
  void didUpdateWidget(ValueNotifierConsumer<VN, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldValueNotifier = oldWidget.valueNotifier ?? context.read<VN>();
    final currentValueNotifier = widget.valueNotifier ?? oldValueNotifier;
    if (oldValueNotifier != currentValueNotifier) {
      _valueNotifier = currentValueNotifier;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final valueNotifier = widget.valueNotifier ?? context.read<VN>();
    if (_valueNotifier != valueNotifier) _valueNotifier = valueNotifier;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.valueNotifier == null) {
      context.select<VN, bool>(
        (valueNotifier) => identical(_valueNotifier, valueNotifier),
      );
    }
    return ValueNotifierBuilder<VN, V>(
      valueNotifier: _valueNotifier,
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
