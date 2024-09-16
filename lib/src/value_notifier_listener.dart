import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/flutter_value_notifier.dart';
import 'package:provider/single_child_widget.dart';

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
/// Takes a [ValueNotifierWidgetListener] and an optional [notifier] and
/// invokes the [listener] in response to `value` changes in the
/// [notifier].
/// It should be used for functionality that needs to occur only in response to
/// a `value` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `value` change
/// unlike the `builder` in `ValueNotifierBuilder`.
///
/// If the [notifier] parameter is omitted, [ValueNotifierListener] will
/// automatically perform a lookup using [ValueNotifierProvider] and the current
/// [BuildContext].
///
/// ```dart
/// ValueNotifierListener<NotifierA, NotifierAValue>(
///   listener: (context, value) {
///     // do stuff here based on NotifierA's value
///   },
///   child: Container(),
/// )
/// ```
///
/// Only specify the [notifier] if you wish to provide a [notifier]
/// that is otherwise not accessible via [ValueNotifierProvider] and the current
/// [BuildContext].
///
/// ```dart
/// ValueNotifierListener<NotifierA, NotifierAValue>(
///   notifier: notifierA,
///   listener: (context, state) {
///     // do stuff here based on NotifierA's value
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
///
/// {@template value_notifier_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each [notifier] `value` change.
/// [listenWhen] takes the previous `value` and current `value` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `value` will be initialized to the `value` of the
/// [notifier] when the [ValueNotifierListener] is initialized.
/// [listenWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// ValueNotifierListener<NotifierA, NotifierAValue>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with value
///   },
///   listener: (context, value) {
///     // do stuff here based on NotifierA's value
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
class ValueNotifierListener<VN extends ValueNotifier<V>, V>
    extends ValueNotifierListenerBase<VN, V> {
  /// {@macro value_notifier_listener}
  /// {@macro value_notifier_listener_listen_when}
  const ValueNotifierListener({
    super.key,
    required super.listener,
    super.notifier,
    super.listenWhen,
    super.child,
  });
}

/// {@template value_notifier_listener_base}
/// Base class for widgets that listen to value changes in a specified
/// [notifier].
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
    this.notifier,
    this.child,
    this.listenWhen,
  }) : super(child: child);

  /// The widget which will be rendered as a descendant of the
  /// [ValueNotifierListenerBase].
  final Widget? child;

  /// The [notifier] whose `value` will be listened to.
  /// Whenever the [notifier]'s `value` changes, [listener] will be
  /// invoked.
  final VN? notifier;

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
  late VN _notifier;
  late V _previousValue;

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? context.read<VN>();
    _previousValue = _notifier.value;
    _subscribe();
  }

  @override
  void didUpdateWidget(ValueNotifierListenerBase<VN, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldNotifier = oldWidget.notifier ?? context.read<VN>();
    final currentNotifier = widget.notifier ?? oldNotifier;
    if (oldNotifier != currentNotifier) {
      if (_subscription != null) {
        _unsubscribe();
        _notifier = currentNotifier;
        _previousValue = _notifier.value;
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = widget.notifier ?? context.read<VN>();
    if (_notifier != notifier) {
      if (_subscription != null) {
        _unsubscribe();
        _notifier = notifier;
        _previousValue = _notifier.value;
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
    if (widget.notifier == null) {
      context.select<VN, bool>((notifier) => identical(_notifier, notifier));
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
      if (widget.listenWhen?.call(_previousValue, _notifier.value) ?? true) {
        widget.listener(context, _notifier.value);
      }
      _previousValue = _notifier.value;
    };
    _notifier.addListener(_subscription!);
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _notifier.removeListener(_subscription!);
    }
    _subscription = null;
  }
}
