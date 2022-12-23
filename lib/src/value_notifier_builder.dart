import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';

typedef ValueNotifierWidgetBuilder<V> = Widget Function(
  BuildContext context,
  V state,
);

typedef ValueNotifierBuilderCondition<V> = bool Function(V previous, V current);

class ValueNotifierBuilder<VN extends ValueNotifier<V>, V>
    extends ValueNotifierBuilderBase<VN, V> {
  const ValueNotifierBuilder({
    super.key,
    required this.builder,
    super.valueNotifier,
    super.buildWhen,
  });

  final ValueNotifierWidgetBuilder<V> builder;

  @override
  Widget build(BuildContext context, V value) => builder(context, value);
}

abstract class ValueNotifierBuilderBase<VN extends ValueNotifier<V>, V>
    extends StatefulWidget {
  const ValueNotifierBuilderBase({
    super.key,
    this.valueNotifier,
    this.buildWhen,
  });

  final VN? valueNotifier;
  final ValueNotifierBuilderCondition<V>? buildWhen;

  Widget build(BuildContext context, V value);

  @override
  State<ValueNotifierBuilderBase<VN, V>> createState() =>
      _ValueNotifierBuilderBaseState<VN, V>();
}

class _ValueNotifierBuilderBaseState<VN extends ValueNotifier<V>, V>
    extends State<ValueNotifierBuilderBase<VN, V>> {
  late VN _valueNotifier;
  late V _value;

  @override
  void initState() {
    super.initState();
    _valueNotifier = widget.valueNotifier ?? context.read<VN>();
    _value = _valueNotifier.value;
  }

  @override
  void didUpdateWidget(ValueNotifierBuilderBase<VN, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldValueNotifier = oldWidget.valueNotifier ?? context.read<VN>();
    final currentValueNotifier = widget.valueNotifier ?? oldValueNotifier;
    if (oldValueNotifier != currentValueNotifier) {
      _valueNotifier = currentValueNotifier;
      _value = _valueNotifier.value;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final valueNotifier = widget.valueNotifier ?? context.read<VN>();
    if (_valueNotifier != valueNotifier) {
      _valueNotifier = valueNotifier;
      _value = _valueNotifier.value;
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
      listenWhen: widget.buildWhen,
      listener: (context, value) => setState(() => _value = value),
      child: widget.build(context, _value),
    );
  }
}
