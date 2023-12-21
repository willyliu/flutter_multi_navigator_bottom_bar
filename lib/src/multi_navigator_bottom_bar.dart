import 'package:flutter/material.dart';

import 'buttom_bar_tab.dart';

/// The controller for [MultiNavigatorBottomBar].
class MultiNavigatorBottomBarController {
  _MultiNavigatorBottomBarState? bottomBarState;
  _BottomNavigationBarWrapperState? bottomBarWrapperState;
  double _lastBarHeight = 0.0;

  double get lastBarHeight => _lastBarHeight;

  /// Changes the height of the bottom bar of [MultiNavigatorBottomBar].
  setBarHeight(double height) {
    _lastBarHeight = height;
    bottomBarWrapperState?._update();
  }

  /// Changes the height of the bottom bar of [MultiNavigatorBottomBar].
  setBarHeightWithoutSettingState(double height) {
    _lastBarHeight = height;
  }

  /// Pushes a [route] in the navigator in the current tab of
  /// [MultiNavigatorBottomBar].
  pushRouteAtCurrentTab(PageRoute route) {
    final state = bottomBarState
        ?.widget?.tabs[bottomBarState?._currentIndex ?? 0].navigatorKey.currentState;
    state?.push(route);
  }

  /// Pop the navigator to the initial route at current tab of
  /// [MultiNavigatorBottomBar].
  popToRootAtCurrentTab() {
    final state = bottomBarState
        ?.widget?.tabs[bottomBarState?._currentIndex ?? 0].navigatorKey.currentState;
    state?.popUntil((r) => r.isFirst);
  }

  selectTab(int tabIndex) => bottomBarState?._selectTab(tabIndex);
}

class MultiNavigatorBottomBar extends StatefulWidget {
  final int initTabIndex;
  final List<BottomBarTab> tabs;
  final PageRoute? pageRoute;
  final ValueChanged<int>? willSelect;
  final ValueChanged<int>? didSelect;
  final Widget Function(Widget)? pageWidgetDecorator;
  final BottomNavigationBarType? type;
  final Color? fixedColor;
  final ValueGetter shouldHandlePop;
  final MultiNavigatorBottomBarController? controller;
  final bool tapToPopToRoot;
  final Key? scaffoldKey;

  MultiNavigatorBottomBar({
    required this.initTabIndex,
    required this.tabs,
    this.willSelect,
    this.didSelect,
    this.pageRoute,
    this.pageWidgetDecorator,
    this.type,
    this.fixedColor,
    this.shouldHandlePop = _defaultShouldHandlePop,
    this.controller,
    this.tapToPopToRoot = true,
    this.scaffoldKey,
  });

  static bool _defaultShouldHandlePop() => true;

  @override
  State<StatefulWidget> createState() =>
      _MultiNavigatorBottomBarState(initTabIndex, controller: controller);
}

class _MultiNavigatorBottomBarState extends State<MultiNavigatorBottomBar> {
  int _currentIndex;
  MultiNavigatorBottomBarController? controller;

  _MultiNavigatorBottomBarState(this._currentIndex, {this.controller}) {
    this.controller?.bottomBarState = this;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          return widget.shouldHandlePop()
              ? !await widget.tabs[_currentIndex].navigatorKey.currentState!
                  .maybePop()
              : false;
        },
        child: Scaffold(
          key: widget.scaffoldKey,
          body: widget.pageWidgetDecorator == null
              ? _buildPageBody()
              : widget.pageWidgetDecorator!(_buildPageBody()),
          bottomNavigationBar: _buildBottomBar(),
        ),
      );

  Widget _buildPageBody() => Stack(
        children:
            widget.tabs.map((tab) => _buildOffstageNavigator(tab)).toList(),
      );

  WidgetBuilder _defaultPageRouteBuilder(BottomBarTab tab, String routeName,
          {String? heroTag}) =>
      (context) => tab.initialPageBuilder(context);

  Widget _buildOffstageNavigator(BottomBarTab tab) => Offstage(
        offstage: widget.tabs.indexOf(tab) != _currentIndex,
        child: Navigator(
          key: tab.navigatorKey,
          observers: tab.observers ?? [HeroController()],
          onGenerateRoute: (routeSettings) =>
              widget.pageRoute ??
              MaterialPageRoute(
                settings: RouteSettings(name: tab.initialPageName),
                builder: (context) =>
                    _defaultPageRouteBuilder(tab, routeSettings.name ?? '')(context),
              ),
        ),
      );

  Widget _buildBottomBar() {
    return _BottomNavigationBarWrapper(
      tabs: widget.tabs,
      willSelect: widget.willSelect,
      didSelect: widget.didSelect,
      fixedColor: widget.fixedColor,
      type: widget.type,
      controller: widget.controller,
    );
  }

  void _selectTab(int tabIndex) {
    setState(() => _currentIndex = tabIndex);
  }
}

class _BottomNavigationBarWrapper extends StatefulWidget {
  final MultiNavigatorBottomBarController? controller;
  final List<BottomBarTab> tabs;
  final ValueChanged<int>? willSelect;
  final ValueChanged<int>? didSelect;
  final BottomNavigationBarType? type;
  final Color? fixedColor;

  _BottomNavigationBarWrapper({
    Key? key,
    required this.tabs,
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
  MultiNavigatorBottomBarController? controller;

  _BottomNavigationBarWrapperState({this.controller}) {
    this.controller?.bottomBarWrapperState = this;
  }

  _update() => setState(() {});

  _selectTabWithPoppingToRoot(int index) {
    _MultiNavigatorBottomBarState? state = context
        .findAncestorStateOfType<_MultiNavigatorBottomBarState>();

    if (state != null && state._currentIndex == index) {
      if (state.widget.tapToPopToRoot) {
        final currentTab = state.widget.tabs[state._currentIndex];
        final currentState = currentTab.navigatorKey.currentState;
        if (currentState != null) {
          if (currentState.canPop()) {
            currentState.popUntil((r) => r.isFirst);
            if (widget.didSelect != null) {
              widget.didSelect!(index);
            }
          } else {
            if (currentTab.initialPageTappedCallback != null) {
              currentTab.initialPageTappedCallback!();
            }
            if (widget.didSelect != null) {
              widget.didSelect!(index);
            }
          }
        }
      }
      return;
    }

    if (widget.didSelect != null) {
      widget.didSelect!(index);
    }

    state?.setState(() => state._currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    _MultiNavigatorBottomBarState? state = context
        .findAncestorStateOfType<_MultiNavigatorBottomBarState>();
    final bar = BottomNavigationBar(
      type: widget.type,
      fixedColor: widget.fixedColor,
      items: widget.tabs
          .map((tab) => BottomNavigationBarItem(
                icon: tab.tabIconBuilder(context),
                activeIcon: tab.tabActiveIconBuilder == null
                    ? null
                    : tab.tabActiveIconBuilder!(context),
                label: tab.tabTitle,
              ))
          .toList(),
      onTap: _selectTabWithPoppingToRoot,
      currentIndex: state?._currentIndex ?? 0,
    );
    var barHeight = this.controller?.lastBarHeight;

    if (barHeight == null) {
      return bar;
    }
    var heightFactor = barHeight /
        (kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom);
    return SizedOverflowBox(
        size: Size.fromHeight(barHeight),
        child: ClipRect(
            clipBehavior: Clip.antiAlias,
            child: Align(
              child: bar,
              alignment: Alignment.topCenter,
              heightFactor: heightFactor,
            )));
  }
}
