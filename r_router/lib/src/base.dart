// Copyright 2020 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// widget builder
typedef Widget RRouterWidgetBuilder(dynamic params);

/// page builder
typedef PageRoute<T> RRouterPageBuilder<T>(
    RouteSettings setting, WidgetBuilder builder);

/// not fount page widget
typedef Widget RRouterNotFountPage(String path);

/// transform result
Future<dynamic> transResult(
    {String path,
    Map<String, dynamic> arguments,
    bool replace,
    bool clearTrace}) async {
  dynamic future;
  if (clearTrace == true) {
    future = await RRouter.navigator
        .pushNamedAndRemoveUntil(path, (check) => false, arguments: arguments);
  } else {
    future = replace == true
        ? await RRouter.navigator
            .pushReplacementNamed(path, arguments: arguments)
        : await RRouter.navigator.pushNamed(path, arguments: arguments);
  }
  return future;
}

class RRouter {
  static final RRouter myRouter = RRouter();

  Map<String, RRouterWidgetBuilder> _routeMap = {};
  Map<String, RRouterPageBuilder> _pageMap = {};

  RRouterNotFountPage notFoundPage;

  RRouterObserver observer = RRouterObserver();

  static NavigatorState get navigator {
    assert(RRouter.myRouter.observer.navigator != null,
        'please add the observer into app');
    return myRouter.observer.navigator;
  }

  static BuildContext get context {
    assert(RRouter.myRouter.observer.navigator != null,
        'please add the observer into app');
    return myRouter.observer.navigator.context;
  }

  /// generate a route ,you must add this to app.
  Route<dynamic> routerGenerate(RouteSettings settings) {
    Object params = settings.arguments;
    RRouterWidgetBuilder builder = _routeMap[settings.name];
    if (builder != null) {
      return _pageGenerate(settings, (BuildContext context) => builder(params));
    } else {
      try {
        return _pageGenerate(settings,
            (BuildContext context) => notFoundPage?.call(settings.name));
      } catch (_) {
        String error =
            "No registered route was found to handle '${settings.name}'.";
        throw RRouterNotFoundException(error, settings.name);
      }
    }
  }

  /// you want to add a widget in the navigation , can use it.
  void addRouter(
      {@required String path,
      @required RRouterWidgetBuilder routerWidgetBuilder,
      RRouterPageBuilder routerPageBuilder,
      bool isReplaceRouter}) {
    if (!_routeMap.containsKey(path) || isReplaceRouter == true) {
      _routeMap[path] = routerWidgetBuilder;
      if (routerPageBuilder != null) {
        _pageMap[path] = routerPageBuilder;
      }
    }
  }

  /// generate a page route.
  PageRoute<T> _pageGenerate<T>(RouteSettings settings, WidgetBuilder builder) {
    String name = settings.name;
    RRouterPageBuilder<T> pageBuilder = _pageMap[name];
    if (pageBuilder != null) {
      return pageBuilder(settings, builder);
    } else {
      if (Platform.isAndroid) {
        return MaterialPageRoute<T>(settings: settings, builder: builder);
      } else {
        return CupertinoPageRoute<T>(settings: settings, builder: builder);
      }
    }
  }

  /// Push the given route onto the navigator.
  Future<void> navigateTo(
    String path, {
    Map<String, dynamic> arguments,
    bool replace,
    bool clearTrace,
  }) =>
      transResult(
          path: path,
          arguments: arguments,
          replace: replace,
          clearTrace: clearTrace);

  /// Pop the top-most route off the navigator.
  pop<T>([T result]) {
    return navigator.pop<T>(result);
  }

  /// Pop the current route off the navigator and push a named route in its
  /// place.
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
    String routeName, {
    TO result,
    Object arguments,
  }) {
    return navigator.popAndPushNamed<T, TO>(routeName,
        result: result, arguments: arguments);
  }

  /// Calls [pop] repeatedly until the predicate returns true.
  void popUntil(RoutePredicate predicate) {
    navigator.popUntil(predicate);
  }

  bool canPop() => navigator.canPop();

  /// Tries to pop the current route, while honoring the route's [Route.willPop]
  /// state.
  Future<bool> maybePop<T extends Object>([T result]) {
    return navigator.maybePop<T>(result);
  }
}

/// route observer
class RRouterObserver extends NavigatorObserver {}

/// not found route exception
class RRouterNotFoundException implements Exception {
  final String message;
  final String path;

  RRouterNotFoundException(this.message, this.path);

  @override
  String toString() {
    return message;
  }
}
