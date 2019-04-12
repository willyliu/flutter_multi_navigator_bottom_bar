import 'package:flutter/material.dart';
import 'tab_page_navigator.dart';

/// Represents a tab in [MultiNavigatorBottomBar].
class BottomBarTab {
  /// Builds the initial page.
  final WidgetBuilder initialPageBuilder;

  /// Name of the initial page.
  final String initialPageName;

  /// Builds the icon for the tab.
  final WidgetBuilder tabIconBuilder;

  /// Builds the title for the tab.
  final WidgetBuilder tabTitleBuilder;

  /// Builds the routes for the tab.
  final WidgetBuilder routePageBuilder;

  /// The navigator observers.
  final List<NavigatorObserver> observers;

  /// The key for the navigator within the tab.
  final GlobalKey<NavigatorState> _navigatorKey;

  /// Creates a new instance.
  BottomBarTab({
    @required this.initialPageBuilder,
    @required this.tabIconBuilder,
    this.initialPageName,
    this.tabTitleBuilder,
    this.routePageBuilder,
    this.observers,
    GlobalKey<NavigatorState> navigatorKey,
  }) : _navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
}

/// The controller for [MultiNavigatorBottomBar].
class MultiNavigatorBottomBarController {
  _MultiNavigatorBottomBarState bottomBarState;
  _BottomNavigationBarWrapperState bottomBarWrapperState;
  double _lastBarHeight;

  double get lastBarHeight => _lastBarHeight;

  /// Changes the height of the bottom bar of [MultiNavigatorBottomBar].
  setBarHeight(double height) {
    _lastBarHeight = height;
    bottomBarWrapperState?._update();
  }

  /// Pushes a [route] in the navigator in the current tab of
  /// [MultiNavigatorBottomBar].
  pushRouteAtCurrentTab(PageRoute route) {
    bottomBarState
        .widget.tabs[bottomBarState.currentIndex]._navigatorKey.currentState
        .push(route);
  }
}

class MultiNavigatorBottomBar extends StatefulWidget {
  final int initTabIndex;
  final List<BottomBarTab> tabs;
  final PageRoute pageRoute;
  final ValueChanged<int> onTap;
  final Widget Function(Widget) pageWidgetDecorator;
  final BottomNavigationBarType type;
  final Color fixedColor;
  final ValueGetter shouldHandlePop;
  final MultiNavigatorBottomBarController controller;
  final bool tapToPopToRoot;

  MultiNavigatorBottomBar({
    @required this.initTabIndex,
    @required this.tabs,
    this.onTap,
    this.pageRoute,
    this.pageWidgetDecorator,
    this.type,
    this.fixedColor,
    this.shouldHandlePop = _defaultShouldHandlePop,
    this.controller,
    this.tapToPopToRoot = false,
  });

  static bool _defaultShouldHandlePop() => true;

  @override
  State<StatefulWidget> createState() => _MultiNavigatorBottomBarState(
        initTabIndex,
        controller: controller,
      );
}

class _MultiNavigatorBottomBarState extends State<MultiNavigatorBottomBar> {
  int currentIndex;
  MultiNavigatorBottomBarController controller;

  _MultiNavigatorBottomBarState(this.currentIndex, {this.controller}) {
    this.controller.bottomBarState = this;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          return widget.shouldHandlePop()
              ? !await widget.tabs[currentIndex]._navigatorKey.currentState
                  .maybePop()
              : false;
        },
        child: Scaffold(
          body: widget.pageWidgetDecorator == null
              ? _buildPageBody()
              : widget.pageWidgetDecorator(_buildPageBody()),
          bottomNavigationBar: _buildBottomBar(),
        ),
      );

  Widget _buildPageBody() => Stack(
        children:
            widget.tabs.map((tab) => _buildOffstageNavigator(tab)).toList(),
      );

  Widget _buildOffstageNavigator(BottomBarTab tab) => Offstage(
        offstage: widget.tabs.indexOf(tab) != currentIndex,
        child: TabPageNavigator(
          navigatorKey: tab._navigatorKey,
          initialPageBuilder: tab.initialPageBuilder,
          observers: tab.observers,
          pageRoute: widget.pageRoute,
        ),
      );

  Widget _buildBottomBar() {
    return _BottomNavigationBarWrapper(
      tabs: widget.tabs,
      willSelect: widget.onTap,
      fixedColor: widget.fixedColor,
      type: widget.type,
      controller: widget.controller,
    );
  }
}

class _BottomNavigationBarWrapper extends StatefulWidget {
  final MultiNavigatorBottomBarController controller;
  final List<BottomBarTab> tabs;
  final ValueChanged<int> willSelect;
  final ValueChanged<int> didSelect;
  final BottomNavigationBarType type;
  final Color fixedColor;

  _BottomNavigationBarWrapper({
    Key key,
    @required this.tabs,
    this.type,
    this.fixedColor,
    this.willSelect,
    this.didSelect,
    this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _BottomNavigationBarWrapperState(controller: controller);
}

class _BottomNavigationBarWrapperState
    extends State<_BottomNavigationBarWrapper> {
  MultiNavigatorBottomBarController controller;

  _BottomNavigationBarWrapperState({this.controller}) {
    this.controller?.bottomBarWrapperState = this;
  }

  _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _MultiNavigatorBottomBarState state = context
        .ancestorStateOfType(TypeMatcher<_MultiNavigatorBottomBarState>());
    final bar = BottomNavigationBar(
      type: widget.type,
      fixedColor: widget.fixedColor,
      items: widget.tabs
          .map((tab) => BottomNavigationBarItem(
                icon: tab.tabIconBuilder(context),
                title: tab.tabTitleBuilder(context),
              ))
          .toList(),
      onTap: (index) {
        if (widget.willSelect != null) {
          widget.willSelect(index);
        }
        _MultiNavigatorBottomBarState state = context
            .ancestorStateOfType(TypeMatcher<_MultiNavigatorBottomBarState>());

        if (state.currentIndex == index) {
          if (state.widget.tapToPopToRoot) {
            final currentTab = state.widget.tabs[state.currentIndex];
            final currentState = currentTab._navigatorKey.currentState;
            if (currentState.canPop()) {
              currentState.popUntil((r) => r.isFirst);
              widget.didSelect(index);
            }
          }
          return;
        }
        if (widget.didSelect != null) {
          widget.didSelect(index);
        }

        state.setState(() {
          state.currentIndex = index;
        });
      },
      currentIndex: state.currentIndex,
    );
    var barHeight = this.controller?.lastBarHeight;

    if (barHeight != null) {
      return SizedOverflowBox(
          size: Size.fromHeight(barHeight),
          child: ClipRect(
              clipBehavior: Clip.antiAlias,
              child: Align(
                child: bar,
                alignment: Alignment.topCenter,
                heightFactor: barHeight /
                    (kBottomNavigationBarHeight +
                        MediaQuery.of(context).padding.bottom),
              )));
    }
    return bar;
  }
}
