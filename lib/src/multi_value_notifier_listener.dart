import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart' show MultiProvider;
import 'package:value_notifier_test/src/value_notifier_listener.dart';

class MultiValueNotifierListener extends MultiProvider {
  MultiValueNotifierListener({
    super.key,
    required List<ValueNotifierListenerSingleChildWidget> listeners,
    required Widget super.child,
  }) : super(providers: listeners);
}
