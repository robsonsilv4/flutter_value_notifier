import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart' show ReadContext, SelectContext;
import 'package:provider/single_child_widget.dart';

mixin ValueNotifierListenerSingleChildWidget on SingleChildWidget {}

typedef ValueNotifierWidgetListener<V> = void Function(
  BuildContext context,
  V value,
);

typedef ValueNotifierListenerCondition<V> = bool Function(
  V previous,
  V current,
);

class ValueNotifierListener<VN extends ValueNotifier<V>, V>
    extends ValueNotifierListenerBase<VN, V>
    with ValueNotifierListenerSingleChildWidget {
  const ValueNotifierListener({
    super.key,
    required super.listener,
    super.valueNotifier,
    super.listenWhen,
    super.child,
  });
}

abstract class ValueNotifierListenerBase<VN extends ValueNotifier<V>, V>
    extends SingleChildStatefulWidget {
  const ValueNotifierListenerBase({
    super.key,
    required this.listener,
    this.valueNotifier,
    this.child,
    this.listenWhen,
  }) : super(child: child);

  final Widget? child;
  final VN? valueNotifier;
  final ValueNotifierWidgetListener<V> listener;
  final ValueNotifierListenerCondition<V>? listenWhen;

  @override
  SingleChildState<ValueNotifierListenerBase<VN, V>> createState() =>
      _ValueNotifierListenerBaseState<VN, V>();
}

class _ValueNotifierListenerBaseState<VN extends ValueNotifier<V>, V>
    extends SingleChildState<ValueNotifierListenerBase<VN, V>> {
  void Function()? _subscription;
  late VN _valueNotifier;
  late V _previousValue;

  @override
  void initState() {
    super.initState();
    _valueNotifier = widget.valueNotifier ?? context.read<VN>();
    _previousValue = _valueNotifier.value;
    _subscribe();
  }

  @override
  void didUpdateWidget(ValueNotifierListenerBase<VN, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldValueNotifier = oldWidget.valueNotifier ?? context.read<VN>();
    final currentValueNotifier = widget.valueNotifier ?? oldValueNotifier;
    if (oldValueNotifier != currentValueNotifier) {
      if (_subscription != null) {
        _unsubscribe();
        _valueNotifier = currentValueNotifier;
        _previousValue = _valueNotifier.value;
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final valueNotifier = widget.valueNotifier ?? context.read<VN>();
    if (_valueNotifier != valueNotifier) {
      if (_subscription != null) {
        _unsubscribe();
        _valueNotifier = valueNotifier;
        _previousValue = _valueNotifier.value;
      }
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(
      child != null,
      '''${widget.runtimeType} used outside of MultiValueNotifierListener must specify a child''',
    );
    if (widget.valueNotifier == null) {
      context.select<VN, bool>(
        (valueNotifier) => identical(_valueNotifier, valueNotifier),
      );
    }
    return child!;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = () {
      if (widget.listenWhen?.call(_previousValue, _valueNotifier.value) ??
          true) {
        widget.listener(context, _valueNotifier.value);
      }
      _previousValue = _valueNotifier.value;
    };
    _valueNotifier.addListener(_subscription!);
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _valueNotifier.removeListener(_subscription!);
    }
    _subscription = null;
  }
}
