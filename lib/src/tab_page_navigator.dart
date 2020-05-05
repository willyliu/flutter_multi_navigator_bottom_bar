import 'package:flutter/material.dart';

/// The navigator with in a tab.
class TabPageNavigator extends StatelessWidget {
  TabPageNavigator({
    @required this.navigatorKey,
    @required this.initialPageBuilder,
    this.initialPageName,
    this.pageRoute,
    this.observers,
  });

  /// The key used in the navigator.
  final GlobalKey<NavigatorState> navigatorKey;

  /// The builder for the initial page.
  final WidgetBuilder initialPageBuilder;

  /// The name of the initial page.
  final String initialPageName;

  /// The routes used in the navigator.
  final PageRoute pageRoute;

  /// The observers
  final List<NavigatorObserver> observers;

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        observers: this.observers ?? [HeroController()],
        onGenerateRoute: (routeSettings) =>
            pageRoute ??
            MaterialPageRoute(
              settings: RouteSettings(name: initialPageName),
              builder: (context) =>
                  _defaultPageRouteBuilder(routeSettings.name)(context),
            ),
      );

  WidgetBuilder _defaultPageRouteBuilder(String routName, {String heroTag}) =>
      (context) => initialPageBuilder(context);
}
