// Copyright 2020 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';
import 'custom_page_route.dart';
import 'interceptor.dart';
export 'interceptor.dart';
export 'custom_page_route.dart';

const _kMaterial = 'material';
const _kCupertino = 'cupertino';
const _kCustom = 'custom';

/// widget builder
typedef Widget RRouterWidgetBuilder(dynamic params);

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
  Map<String, RRouterPageBuilderType> _pageBuilderTypeMap = {};
  Map<String, PageTransitionsBuilder> _pageTransitionsMap = {};

  RRouterNotFountPage notFoundPage;

  RRouterInterceptor interceptor;

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
    if (interceptor != null) {
      RouteSettings _interceptorSetting = interceptor.onRequest(settings);
      if (_interceptorSetting != null) {
        settings = _interceptorSetting;
      }
    }
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
      RRouterPageBuilderType routerPageBuilderType,
      PageTransitionsBuilder routerPageTransitions,
      bool isReplaceRouter}) {
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
    String name = settings.name;
    RRouterPageBuilderType pageBuilder = _pageBuilderTypeMap[name];
    PageTransitionsBuilder pageTransitions = _pageTransitionsMap[name];
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

class RRouterProvider {
  final String paramName;
  final RRouterPageBuilderType pageBuilderType;
  final PageTransitionsBuilder pageTransitions;
  final String path;
  final String describe;

  const RRouterProvider(
      {@required this.paramName,
      this.pageTransitions,
      this.pageBuilderType,
      this.path,
      this.describe});
}
