import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

mixin ValueNotifierProviderSingleChildWidget on SingleChildWidget {}

class ValueNotifierProvider<T extends ValueNotifier<Object?>>
    extends SingleChildStatelessWidget
    with ValueNotifierProviderSingleChildWidget {
  const ValueNotifierProvider({
    super.key,
    required Create<T> create,
    this.child,
    this.lazy = true,
  })  : _create = create,
        _value = null,
        super(child: child);

  const ValueNotifierProvider.value({
    super.key,
    required T value,
    this.child,
  })  : _value = value,
        _create = null,
        lazy = true,
        super(child: child);

  final Widget? child;
  final bool lazy;
  final Create<T>? _create;
  final T? _value;

  static T of<T extends ValueNotifier<Object?>>(
    BuildContext context, {
    bool listen = false,
  }) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
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
            dispose: (_, valueNotifier) => valueNotifier.dispose(),
            startListening: _startListening,
            lazy: lazy,
            child: child,
          );
  }

  static VoidCallback _startListening(
    InheritedContext<ValueNotifier<Object?>?> e,
    ValueNotifier<Object?> value,
  ) {
    void subscription() => e.markNeedsNotifyDependents();
    value.addListener(subscription);
    return () => value.removeListener(subscription);
  }
}
