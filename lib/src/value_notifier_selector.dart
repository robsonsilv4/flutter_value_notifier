import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

/// Signature for the `selector` function which
/// is responsible for returning a selected value, [T], based on [value].
typedef ValueNotifierWidgetSelector<V, T> = T Function(V value);

/// {@template value_notifier_selector}
/// [ValueNotifierSelector] is analogous to [ValueNotifierBuilder] but allows
/// developers to filter updates by selecting a new value based on the notifier
/// value. Unnecessary builds are prevented if the selected value does not
/// change.
///
/// **Note**: the selected value must be immutable in order for
/// [ValueNotifierSelector] to accurately determine whether [builder] should
/// be called again.
/// {@endtemplate}
class ValueNotifierSelector<VN extends ValueNotifier<V>, V, T>
    extends StatefulWidget {
  /// {@macro value_notifier_selector}
  const ValueNotifierSelector({
    super.key,
    required this.selector,
    required this.builder,
    this.notifier,
  });

  /// The [notifier] that the [ValueNotifierSelector] will interact with.
  /// If omitted, [ValueNotifierSelector] will automatically perform a lookup
  /// using [ValueNotifierProvider] and the current [BuildContext].
  final VN? notifier;

  /// The [builder] function which will be invoked
  /// when the selected value changes.
  /// The [builder] takes the [BuildContext] and selected `value` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [ValueNotifierBuilder].
  final ValueNotifierWidgetBuilder<T> builder;

  /// The [selector] function which will be invoked on each widget build
  /// and is responsible for returning a selected value of type [T] based on
  /// the current value.
  final ValueNotifierWidgetSelector<V, T> selector;

  @override
  State<ValueNotifierSelector<VN, V, T>> createState() =>
      _ValueNotifierSelectorState<VN, V, T>();
}

class _ValueNotifierSelectorState<VN extends ValueNotifier<V>, V, T>
    extends State<ValueNotifierSelector<VN, V, T>> {
  late VN _notifier;
  late T _value;

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? context.read<VN>();
    _value = widget.selector(_notifier.value);
  }

  @override
  void didUpdateWidget(ValueNotifierSelector<VN, V, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldNotifier = oldWidget.notifier ?? context.read<VN>();
    final currentNotifier = widget.notifier ?? oldNotifier;
    if (oldNotifier != currentNotifier) {
      _notifier = currentNotifier;
      _value = widget.selector(_notifier.value);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = widget.notifier ?? context.read<VN>();
    if (_notifier != notifier) {
      _notifier = notifier;
      _value = widget.selector(_notifier.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notifier == null) {
      context.select<VN, bool>((notifier) => identical(_notifier, notifier));
    }
    return ValueNotifierListener<VN, V>(
      notifier: _notifier,
      listener: (_, value) {
        final selectedValue = widget.selector(value);
        if (_value != selectedValue) setState(() => _value = selectedValue);
      },
      child: widget.builder(context, _value),
    );
  }
}
