# 1.2.0

- style: fix test lints and missing names
- feat: add example project
- refactor: fix package name and imports

# 1.1.0

- docs: add usage and widgets documentation

# 1.0.0

Initial version of the library 🎉, based on [flutter_bloc](https://pub.dev/packages/flutter_bloc) from [bloc library](https://bloclibrary.dev/) 🧊.

- **ValueNotifierProvider**: a Flutter widget which provides a `ValueNotifier` to its children via `ValueNotifierProvider.of<T>(context)`.

- **MultiValueNotifierProvider**: a Flutter widget that merges multiple `ValueNotifierProvider` widgets into one.

- **ValueNotifierBuilder**: a Flutter widget which requires a `ValueNotifier` and a builder function.

- **ValueNotifierSelector**: a Flutter widget that allows to filter updates by selecting a new value based on the current `ValueNotifier` value.

- **ValueNotifierListener**: a Flutter widget which takes a listener and invokes the listener in response to value changes in the `ValueNotifier`.

- **MultiValueNotifierListener**: a Flutter widget that merges multiple `ValueNotifierListener` widgets into one.

- **ValueNotifierConsumer**: a Flutter widget that exposes a builder and listener in order react to new values.

- **DependencyProvider**: a Flutter widget which provides a dependency to its children via `DependencyProvider.of<T>(context)`.

- **MultiDependencyProvider**: a Flutter widget that merges multiple `DependencyProvider` widgets into one.

Thanks to Felix Angelov ([@felangel](https://github.com/felangel)) and all [bloc library contributors](https://github.com/felangel/bloc/graphs/contributors).
