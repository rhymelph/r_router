// Copyright 2020 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide DatePickerEntryMode;
import 'package:r_router/r_router.dart';
import 'custom_page_route.dart';
import 'interceptor.dart';
export 'interceptor.dart';
export 'custom_page_route.dart';

export 'plugin/r_router_provider.dart';

const _kMaterial = 'material';
const _kCupertino = 'cupertino';
const _kCustom = 'custom';

/// widget builder
typedef Widget RRouterWidgetBuilder(dynamic params);

/// not fount page widget
typedef Widget RRouterNotFountPage(String? path);

/// transform result
Future<dynamic> transResult(
    {String? path,
    Map<String, dynamic>? arguments,
    bool? replace,
    bool? clearTrace,
    bool? isSingleTop}) async {
  dynamic future;
  if (isSingleTop == true && RRouter.myRouter.observer.topPath == path) {
    return null;
  }
  if (clearTrace == true) {
    future = await RRouter.navigator!
        .pushNamedAndRemoveUntil(path!, (check) => false, arguments: arguments);
  } else {
    future = replace == true
        ? await RRouter.navigator!
            .pushReplacementNamed(path!, arguments: arguments)
        : await RRouter.navigator!.pushNamed(path!, arguments: arguments);
  }
  return future;
}

class RRouter {
  static final RRouter myRouter = RRouter();

  Map<String, RRouterWidgetBuilder> _routeMap = {};
  Map<String, RRouterPageBuilderType> _pageBuilderTypeMap = {};
  Map<String, PageTransitionsBuilder> _pageTransitionsMap = {};

  RRouterNotFountPage? notFoundPage;

  RRouterInterceptors _interceptors = RRouterInterceptors();

  RRouterInterceptors get interceptors => _interceptors;

  RRouterObserver observer = RRouterObserver();

  bool _isDebug = false;

  static NavigatorState? get navigator {
    assert(RRouter.myRouter.observer.navigator != null,
        'please add the observer into app');
    return myRouter.observer.navigator;
  }

  static BuildContext get context {
    assert(RRouter.myRouter.observer.navigator != null,
        'please add the observer into app');
    return myRouter.observer.navigator!.context;
  }

  void setEnableDebug() {
    _isDebug = true;
  }

  void _routePrint(data) {
    if (_isDebug == true) print(data);
  }

  void lock() {
    _interceptors.requestLock.lock();
  }

  void unLock() {
    _interceptors.requestLock.unlock();
  }

  void clear() {
    _interceptors.requestLock.clear();
  }

  /// generate a route ,you must add this to app.
  Route<dynamic> routerGenerate(RouteSettings settings) {
    RouteSettings routeSettings = settings;
    _interceptors.forEach((interceptor) {
      routeSettings = interceptor.onRequest(routeSettings);
    });
    Object? params = routeSettings.arguments;
    RRouterWidgetBuilder? builder = _routeMap[routeSettings.name!];
    if (builder != null) {
      return _pageGenerate(
          routeSettings, (BuildContext context) => builder(params));
    } else {
      try {
        assert(notFoundPage != null,
            "Please Setting Not Found page.such as:`RRouter.myRouter.notFoundPage = Text('')`");
        return _pageGenerate(routeSettings,
            (BuildContext context) => notFoundPage!.call(routeSettings.name));
      } catch (_) {
        String error =
            "No registered route was found to handle '${routeSettings.name}'.";
        throw RRouterNotFoundException(error, routeSettings.name);
      }
    }
  }

  /// you want to add a widget in the navigation , can use it.
  /// [path] your path
  /// [routerWidgetBuilder] widget builder.
  /// [routerPageBuilderType] page builder transaction type.
  /// [routerPageTransitions] page transitions style.
  /// [isReplaceRouter] you want to replace router when your register.
  void addRouter(
      {required String path,
      required RRouterWidgetBuilder routerWidgetBuilder,
      RRouterPageBuilderType? routerPageBuilderType,
      PageTransitionsBuilder? routerPageTransitions,
      bool? isReplaceRouter}) {
    if (!_routeMap.containsKey(path) || isReplaceRouter == true) {
      _routeMap[path] = routerWidgetBuilder;
      if (routerPageBuilderType != null) {
        _pageBuilderTypeMap[path] = routerPageBuilderType;
      }
      if (routerPageTransitions != null) {
        _pageTransitionsMap[path] = routerPageTransitions;
      }
    }
  }

  /// generate a page route.
  PageRoute<T> _pageGenerate<T>(RouteSettings settings, WidgetBuilder builder) {
    String? name = settings.name;
    RRouterPageBuilderType? pageBuilder = _pageBuilderTypeMap[name!];
    PageTransitionsBuilder? pageTransitions = _pageTransitionsMap[name];
    if (pageTransitions != null) {
      return CustomPageRoute(
          pageTransitionsBuilder: pageTransitions,
          builder: builder,
          settings: settings);
    }
    if (pageBuilder != null) {
      if (pageBuilder == RRouterPageBuilderType.cupertino) {
        return CupertinoPageRoute<T>(settings: settings, builder: builder);
      } else {
        return MaterialPageRoute<T>(settings: settings, builder: builder);
      }
    } else {
      return MaterialPageRoute<T>(settings: settings, builder: builder);
    }
  }

  /// Push the given route onto the navigator.
  /// [path] you register path.
  /// [arguments] you want to give [path] arguments.
  /// [replace] will replace route
  /// [clearTrace] will clear all route and push [path].
  /// [isSingleTop] if [path] is top,There was no response.
  Future<dynamic> navigateTo(
    String path, {
    Map<String, dynamic>? arguments,
    bool? replace,
    bool? clearTrace,
    bool? isSingleTop,
  }) =>
      transResult(
          path: path,
          arguments: arguments,
          replace: replace,
          clearTrace: clearTrace,
          isSingleTop: isSingleTop);

  /// Pop the top-most route off the navigator.
  pop<T extends Object>([T? result]) {
    return navigator!.pop<T>(result);
  }

  /// Pop the current route off the navigator and push a named route in its
  /// place.
  Future<T?> popAndPushNamed<T extends Object, TO extends Object>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigator!.popAndPushNamed<T, TO>(routeName,
        result: result, arguments: arguments);
  }

  /// Calls [pop] repeatedly until the predicate returns true.
  void popUntil(RoutePredicate predicate) {
    navigator!.popUntil(predicate);
  }

  /// Immediately remove `route` from the navigator, and [Route.dispose] it.
  void removeRoute(Route<dynamic> route) {
    navigator!.removeRoute(route);
  }

  /// Immediately remove a route from the navigator, and [Route.dispose] it. The
  /// route to be removed is the one below the given `anchorRoute`.
  void removeRouteBelow(Route<dynamic> anchorRoute) {
    navigator!.removeRouteBelow(anchorRoute);
  }

  /// Complete the lifecycle for a route that has been popped off the navigator.
  ///
  /// When the navigator pops a route, the navigator retains a reference to the
  /// route in order to call [Route.dispose] if the navigator itself is removed
  /// from the tree. When the route is finished with any exit animation, the
  /// route should call this function to complete its lifecycle (e.g., to
  /// receive a call to [Route.dispose]).
  ///
  /// The given `route` must have already received a call to [Route.didPop].
  /// This function may be called directly from [Route.didPop] if [Route.didPop]
  /// will return true.
  void finalizeRoute(Route<dynamic> route) {
    navigator!.finalizeRoute(route);
  }

  bool canPop() => navigator!.canPop();

  /// Tries to pop the current route, while honoring the route's [Route.willPop]
  /// state.
  Future<bool> maybePop<T extends Object>([T? result]) {
    return navigator!.maybePop<T>(result);
  }

  /// build your router widget
  /// use in [animations] packages
  Widget getRouteWidget(String path, [Map<String, dynamic>? arguments]) {
    RRouterWidgetBuilder? builder = _routeMap[path];
    assert(builder != null, "The path get router widget is not null");
    return builder!(arguments);
  }
}

/// route observer
class RRouterObserver extends NavigatorObserver {
  List<String> _routeList = [];

  String get topPath => _routeList.length > 0 ? _routeList.last : '';

  @override
  void didPush(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    String? path = route?.settings.name;
    String? previousPath = previousRoute?.settings.name;
    if (path != null && path != '') {
      if (!_routeList.contains(path)) {
        _routeList.add(path);
      }
    }
    RRouter.myRouter._routePrint(
        'RRoute --> did push $path , previous $previousPath , current top $topPath');
  }

  @override
  void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    String? path = route?.settings.name;
    String? previousPath = previousRoute?.settings.name;
    if (path != null && path != '') {
      if (_routeList.contains(path)) {
        _routeList.remove(path);
      }
    }
    if (previousPath != null && previousPath != '') {
      if (!_routeList.contains(previousPath)) {
        _routeList.add(previousPath);
      }
    }
    RRouter.myRouter._routePrint(
        'RRoute --> did pop $path , previous $previousPath , current top $topPath');
  }

  @override
  void didRemove(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    String? path = route?.settings.name;
    String? previousPath = previousRoute?.settings.name;
    if (path != null && path != '') {
      if (_routeList.contains(path)) {
        _routeList.remove(path);
      }
    }
    if (previousPath != null && previousPath != '') {
      if (!_routeList.contains(previousPath)) {
        _routeList.add(previousPath);
      }
    }
    RRouter.myRouter._routePrint(
        'RRoute --> did remove $path , previous $previousPath , current top $topPath');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    String? path = newRoute?.settings.name;
    String? oldPath = oldRoute?.settings.name;
    if (oldPath != null && oldPath != '') {
      if (_routeList.contains(oldPath)) {
        _routeList.remove(oldPath);
      }
    }
    if (path != null && path != '') {
      if (!_routeList.contains(path)) {
        _routeList.add(path);
      }
    }
    RRouter.myRouter._routePrint(
        'RRoute --> did replace $path , old $oldPath , current top $topPath');
  }
}

/// not found route exception
class RRouterNotFoundException implements Exception {
  final String message;
  final String? path;

  RRouterNotFoundException(this.message, this.path);

  @override
  String toString() {
    return message;
  }
}

class RRouterPageBuilderType {
  final String _pageBuilderType;

  const RRouterPageBuilderType(this._pageBuilderType);

  /// material design
  static const RRouterPageBuilderType material =
      RRouterPageBuilderType(_kMaterial);

  /// cupertino design
  static const RRouterPageBuilderType cupertino =
      RRouterPageBuilderType(_kCupertino);

  /// custom design
  static const RRouterPageBuilderType custom = RRouterPageBuilderType(_kCustom);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RRouterPageBuilderType &&
          runtimeType == other.runtimeType &&
          _pageBuilderType == other._pageBuilderType;

  @override
  int get hashCode => _pageBuilderType.hashCode;
}
