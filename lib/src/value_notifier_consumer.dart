import 'package:flutter/widgets.dart';
import 'package:value_notifier_test/flutter_value_notifier.dart';

class ValueNotifierConsumer<VN extends ValueNotifier<V>, V>
    extends StatefulWidget {
  const ValueNotifierConsumer({
    super.key,
    required this.builder,
    required this.listener,
    this.valueNotifier,
    this.buildWhen,
    this.listenWhen,
  });

  final VN? valueNotifier;
  final ValueNotifierWidgetBuilder<V> builder;
  final ValueNotifierWidgetListener<V> listener;
  final ValueNotifierBuilderCondition<V>? buildWhen;
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
