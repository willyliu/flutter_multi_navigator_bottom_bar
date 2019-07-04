import 'package:flutter/material.dart';

/// Represents a tab in [MultiNavigatorBottomBar].
class BottomBarTab {
  /// Builds the initial page.
  final WidgetBuilder initialPageBuilder;

  /// Called when the tab is tapped and the navigator of the tab in on
  /// the first page.
  final VoidCallback initialPageTappedCallback;

  /// Name of the initial page.
  final String initialPageName;

  /// Builds the icon for the tab.
  ///
  /// You can return a widget like [Icon] here.
  final WidgetBuilder tabIconBuilder;

  /// Builds the active icon for the tab.
  ///
  /// You can return a widget like [Icon] here.
  final WidgetBuilder tabActiveIconBuilder;

  /// Builds the title for the tab.
  ///
  /// You can return a widget like [Text] here.
  final WidgetBuilder tabTitleBuilder;

  /// Builds the routes for the tab.
  final WidgetBuilder routePageBuilder;

  /// The observers for the navigator.
  final List<NavigatorObserver> observers;

  /// The key for the navigator within the tab.
  final GlobalKey<NavigatorState> navigatorKey;

  /// Creates a new instance.
  BottomBarTab({
    @required this.initialPageBuilder,
    @required this.tabIconBuilder,
    this.initialPageTappedCallback,
    this.tabActiveIconBuilder,
    this.initialPageName,
    this.tabTitleBuilder,
    this.routePageBuilder,
    this.observers,
    GlobalKey<NavigatorState> navigatorKey,
  }) : this.navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
}
