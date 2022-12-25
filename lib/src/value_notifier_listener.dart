import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart' show ReadContext, SelectContext;
import 'package:provider/single_child_widget.dart';

/// Mixin which allows `MultiValueNotifierListener` to infer the types
/// of multiple [ValueNotifierListener]s.
mixin ValueNotifierListenerSingleChildWidget on SingleChildWidget {}

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `value` and is responsible for executing in response to
/// `value` changes.
typedef ValueNotifierWidgetListener<V> = void Function(
  BuildContext context,
  V value,
);

/// Signature for the `listenWhen` function which takes the previous `value`
/// and the current `value` and is responsible for returning a [bool] which
/// determines whether or not to call [ValueNotifierWidgetListener] of
/// [ValueNotifierListener] with the current `value`.
typedef ValueNotifierListenerCondition<V> = bool Function(
  V previous,
  V current,
);

/// {@template value_notifier_listener}
/// Takes a [ValueNotifierWidgetListener] and an optional [valueNotifier] and
/// invokes the [listener] in response to `value` changes in the
/// [valueNotifier].
/// It should be used for functionality that needs to occur only in response to
/// a `value` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `value` change
/// unlike the `builder` in `ValueNotifierBuilder`.
///
/// If the [valueNotifier] parameter is omitted, [ValueNotifierListener] will
/// automatically perform a lookup using `ValueNotifierProvider` and the current
/// `BuildContext`.
///
/// Only specify the [valueNotifier] if you wish to provide a [valueNotifier]
/// that is otherwise not accessible via `ValueNotifierProvider` and the current
/// `BuildContext`.
/// {@endtemplate}
///
/// {@template value_notifier_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each [valueNotifier] `value` change.
/// [listenWhen] takes the previous `value` and current `value` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `value` will be initialized to the `value` of the
/// [valueNotifier] when the [ValueNotifierListener] is initialized.
/// [listenWhen] is optional and if omitted, it will default to `true`.
/// {@endtemplate}
class ValueNotifierListener<VN extends ValueNotifier<V>, V>
    extends ValueNotifierListenerBase<VN, V>
    with ValueNotifierListenerSingleChildWidget {
  /// {@macro value_notifier_listener}
  /// {@macro value_notifier_listener_listen_when}
  const ValueNotifierListener({
    super.key,
    required super.listener,
    super.valueNotifier,
    super.listenWhen,
    super.child,
  });
}

/// {@template value_notifier_listener_base}
/// Base class for widgets that listen to value changes in a specified
/// [valueNotifier].
///
/// A [ValueNotifierListenerBase] is stateful and maintains the value
/// subscription.
/// The type of the value and what happens with each value change
/// is defined by sub-classes.
/// {@endtemplate}
abstract class ValueNotifierListenerBase<VN extends ValueNotifier<V>, V>
    extends SingleChildStatefulWidget {
  /// {@macro value_notifier_listener_base}
  const ValueNotifierListenerBase({
    super.key,
    required this.listener,
    this.valueNotifier,
    this.child,
    this.listenWhen,
  }) : super(child: child);

  /// The widget which will be rendered as a descendant of the
  /// [ValueNotifierListenerBase].
  final Widget? child;

  /// The [valueNotifier] whose `value` will be listened to.
  /// Whenever the [valueNotifier]'s `value` changes, [listener] will be
  /// invoked.
  final VN? valueNotifier;

  /// The [ValueNotifierWidgetListener] which will be called on every `value`
  /// change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `value` change.
  final ValueNotifierWidgetListener<V> listener;

  /// {@macro value_notifier_listener_listen_when}
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
