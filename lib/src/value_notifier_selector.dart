import 'package:flutter/widgets.dart';
import 'package:value_notifier_test/flutter_value_notifier.dart';

typedef ValueNotifierWidgetSelector<V, T> = T Function(V value);

class ValueNotifierSelector<VN extends ValueNotifier<V>, V, T>
    extends StatefulWidget {
  const ValueNotifierSelector({
    super.key,
    required this.selector,
    required this.builder,
    this.valueNotifier,
  });

  final VN? valueNotifier;
  final ValueNotifierWidgetBuilder<T> builder;
  final ValueNotifierWidgetSelector<V, T> selector;

  @override
  State<ValueNotifierSelector<VN, V, T>> createState() =>
      _ValueNotifierSelectorState<VN, V, T>();
}

class _ValueNotifierSelectorState<VN extends ValueNotifier<V>, V, T>
    extends State<ValueNotifierSelector<VN, V, T>> {
  late VN _valueNotifier;
  late T _value;

  @override
  void initState() {
    super.initState();
    _valueNotifier = widget.valueNotifier ?? context.read<VN>();
    _value = widget.selector(_valueNotifier.value);
  }

  @override
  void didUpdateWidget(ValueNotifierSelector<VN, V, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldValueNotifier = oldWidget.valueNotifier ?? context.read<VN>();
    final currentValueNotifier = widget.valueNotifier ?? oldValueNotifier;
    if (oldValueNotifier != currentValueNotifier) {
      _valueNotifier = currentValueNotifier;
      _value = widget.selector(_valueNotifier.value);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final valueNotifier = widget.valueNotifier ?? context.read<VN>();
    if (_valueNotifier != valueNotifier) {
      _valueNotifier = valueNotifier;
      _value = widget.selector(_valueNotifier.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.valueNotifier == null) {
      context.select<VN, bool>(
        (valueNotifier) => identical(_valueNotifier, valueNotifier),
      );
    }
    return ValueNotifierListener<VN, V>(
      valueNotifier: _valueNotifier,
      listener: (context, value) {
        final selectedState = widget.selector(value);
        if (_value != selectedState) setState(() => _value = selectedState);
      },
      child: widget.builder(context, _value),
    );
  }
}
