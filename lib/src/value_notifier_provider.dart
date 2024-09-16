import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// {@template value_notifier_provider}
/// Takes a [Create] function that is responsible for
/// creating the [ValueNotifier] and a [child] which will have access
/// to the instance via `ValueNotifierProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a [ValueNotifier] can be provided to multiple widgets within a subtree.
///
/// ```dart
/// ValueNotifierProvider(
///   create: (context) => NotifierA(),
///   child: ChildA(),
/// );
/// ```
/// It automatically handles closing the instance when used with [Create].
/// By default, [Create] is called only when the instance is accessed.
/// To override this behavior, set [lazy] to `false`.
///
/// ```dart
/// ValueNotifierProvider(
///   lazy: false,
///   create: (context) => NotifierA(),
///   child: ChildA(),
/// );
/// ```
/// {@endtemplate}
class ValueNotifierProvider<T extends ValueNotifier<Object?>>
    extends SingleChildStatelessWidget {
  /// {@macro value_notifier_provider}
  const ValueNotifierProvider({
    super.key,
    required Create<T> create,
    this.child,
    this.lazy = true,
  })  : _create = create,
        _value = null,
        super(child: child);

  /// Takes a [value] and a [child] which will have access to the [value] via
  /// `ValueNotifierProvider.of(context)`.
  /// When `ValueNotifierProvider.value` is used, the [ValueNotifier]
  /// will not be automatically closed.
  /// As a result, `ValueNotifierProvider.value` should only be used for
  /// providing existing instances to new subtrees.
  ///
  /// A new [ValueNotifier] should not be created in
  /// `ValueNotifierProvider.value`.
  /// New instances should always be created using the
  /// default constructor within the [Create] function.
  ///
  /// ```dart
  /// ValueNotifierProvider.value(
  ///   value: ValueNotifierProvider.of<NotifierA>(context),
  ///   child: ScreenA(),
  /// );
  /// ```
  const ValueNotifierProvider.value({
    super.key,
    required T value,
    this.child,
  })  : _value = value,
        _create = null,
        lazy = true,
        super(child: child);

  /// Widget which will have access to the [ValueNotifier].
  final Widget? child;

  /// Whether the [ValueNotifier] should be created lazily.
  /// Defaults to `true`.
  final bool lazy;

  final Create<T>? _create;
  final T? _value;

  /// Method that allows widgets to access a [ValueNotifier] instance
  /// as long as their `BuildContext` contains a [ValueNotifierProvider]
  /// instance.
  ///
  /// If we want to access an instance of `ValueNotifierA` which was provided
  /// higher up in the widget tree we can do so via:
  ///
  /// ```dart
  /// ValueNotifierProvider.of<ValueNotifierA>(context);
  /// ```
  static T of<T extends ValueNotifier<Object?>>(
    BuildContext context, {
    bool listen = false,
  }) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (exception) {
      if (exception.valueType != T) rethrow;
      throw FlutterError(
        '''
        ValueNotifierProvider.of() called with a context that does not contain a $T.
        No ancestor could be found starting from the context that was passed to ValueNotifierProvider.of<$T>().

        This can happen if the context you used comes from a widget above the ValueNotifierProvider.

        The context used was: $context
        ''',
      );
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(
      child != null,
      '''$runtimeType used outside of MultiValueNotifierProvider must specify a child''',
    );
    final value = _value;
    return value != null
        ? InheritedProvider<T>.value(
            value: value,
            startListening: _startListening,
            lazy: lazy,
            child: child,
          )
        : InheritedProvider<T>(
            create: _create,
            dispose: (_, notifier) => notifier.dispose(),
            startListening: _startListening,
            lazy: lazy,
            child: child,
          );
  }

  static VoidCallback _startListening(
    InheritedContext<ValueNotifier<Object?>?> element,
    ValueNotifier<Object?> value,
  ) {
    void subscription() => element.markNeedsNotifyDependents();
    value.addListener(subscription);
    return () => value.removeListener(subscription);
  }
}
