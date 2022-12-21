import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:value_notifier_test/src/dependency_provider.dart';

class MultiDependencyProvider extends MultiProvider {
  MultiDependencyProvider({
    super.key,
    required List<DependencyProviderSingleChildWidget> super.providers,
    required Widget super.child,
  });
}
