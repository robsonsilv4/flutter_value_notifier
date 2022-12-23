import 'package:flutter/widgets.dart';
import 'package:flutter_value_notifier/src/dependency_provider.dart';
import 'package:provider/provider.dart';

class MultiDependencyProvider extends MultiProvider {
  MultiDependencyProvider({
    super.key,
    required List<DependencyProviderSingleChildWidget> super.providers,
    required Widget super.child,
  });
}
