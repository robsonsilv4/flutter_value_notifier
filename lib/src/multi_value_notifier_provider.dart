import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:value_notifier_test/src/value_notifier_provider.dart';

class MultiValueNotifierProvider extends MultiProvider {
  MultiValueNotifierProvider({
    super.key,
    required List<ValueNotifierProviderSingleChildWidget> super.providers,
    required Widget super.child,
  });
}
