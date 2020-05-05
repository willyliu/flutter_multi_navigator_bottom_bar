import 'package:flutter/material.dart';

/// The navigator with in a tab.
class TabPageNavigator extends StatefulWidget {
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
  _TabPageNavigatorState createState() => _TabPageNavigatorState();
}

class _TabPageNavigatorState extends State<TabPageNavigator> {
  Navigator _navigator;

  @override
  Widget build(BuildContext context) {
    _navigator ??= Navigator(
      key: widget.navigatorKey,
      observers: this.widget.observers ?? [HeroController()],
      onGenerateRoute: (routeSettings) =>
          widget.pageRoute ??
          MaterialPageRoute(
            settings: RouteSettings(name: widget.initialPageName),
            builder: (context) =>
                _defaultPageRouteBuilder(routeSettings.name)(context),
          ),
    );
    return _navigator;
  }

  WidgetBuilder _defaultPageRouteBuilder(String routName, {String heroTag}) =>
      (context) => widget.initialPageBuilder(context);
}
