import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/src/value_notifier_listener.dart';
import 'package:provider/provider.dart' show MultiProvider;

class MultiValueNotifierListener extends MultiProvider {
  MultiValueNotifierListener({
    super.key,
    required List<ValueNotifierListenerSingleChildWidget> listeners,
    required Widget super.child,
  }) : super(providers: listeners);
}
