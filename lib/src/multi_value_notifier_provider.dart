import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_value_notifier/src/value_notifier_provider.dart';

class MultiValueNotifierProvider extends MultiProvider {
  MultiValueNotifierProvider({
    super.key,
    required List<ValueNotifierProviderSingleChildWidget> super.providers,
    required Widget super.child,
  });
}
