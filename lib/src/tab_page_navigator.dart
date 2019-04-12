import 'package:flutter/material.dart';

/// The navigator with in a tab.
class TabPageNavigator extends StatelessWidget {
  TabPageNavigator({
    /// The key used in the navigator.
    @required this.navigatorKey,

    /// The builder for the initial page.
    @required this.initialPageBuilder,

    /// The routes used in the navigator.
    this.pageRoute,

    /// The observers
    this.observers,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final WidgetBuilder initialPageBuilder;
  final PageRoute pageRoute;
  final List<NavigatorObserver> observers;

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        observers: this.observers ?? [HeroController()],
        onGenerateRoute: (routeSettings) =>
            pageRoute ??
            MaterialPageRoute(
              settings: RouteSettings(isInitialRoute: true),
              builder: (context) =>
                  _defaultPageRouteBuilder(routeSettings.name)(context),
            ),
      );

  WidgetBuilder _defaultPageRouteBuilder(String routName, {String heroTag}) =>
      (context) => initialPageBuilder(context);
}
