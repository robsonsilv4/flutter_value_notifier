import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

mixin DependencyProviderSingleChildWidget on SingleChildWidget {}

class DependencyProvider<T> extends Provider<T>
    with DependencyProviderSingleChildWidget {
  DependencyProvider({
    super.key,
    required super.create,
    super.child,
    super.lazy,
  }) : super(dispose: (_, __) {});

  DependencyProvider.value({
    super.key,
    required super.value,
    super.child,
  }) : super.value();

  static T of<T>(BuildContext context, {bool listen = false}) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (exception) {
      if (exception.valueType != T) rethrow;
      throw FlutterError(
        '''
        DependencyProvider.of() called with a context that does not contain a dependency of type $T.
        No ancestor could be found starting from the context that was passed to DependencyProvider.of<$T>().

        This can happen if the context you used comes from a widget above the DependencyProvider.

        The context used was: $context
        ''',
      );
    }
  }
}
