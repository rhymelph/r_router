library r_router;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_tree/path_tree.dart';
import 'package:r_router/src/screens/error_page.dart';
import 'package:r_router/src/utils/string.dart';

import '../screens/custom_page_route.dart';

part 'context.dart';

part 'navigator_route.dart';

part 'params.dart';

part 'r_router_delegate.dart';

part 'r_router_information_parse.dart';

part 'r_router_observer.dart';

part 'r_router_register.dart';

part 'redirect.dart';

RRouterBasic RRouter = RRouterBasic();

class RRouterBasic {
  final RRouterRegister _register = RRouterRegister();
  final RRouterObserver _observer = RRouterObserver();
  final RRouterDelegate _delegate = RRouterDelegate();
  final RRouterInformationParser _informationParser =
      RRouterInformationParser();
  PageTransitionsBuilder _defaultTransitionBuilder;
  final List<RouteInterceptor> _interceptor;

  NavigatorObserver get observer {
    isUseNavigator2 = false;
    addComplete();
    return _observer;
  }

  RRouterDelegate get delegate {
    isUseNavigator2 = true;
    addComplete();
    return _delegate;
  }

  RRouterInformationParser get informationParser {
    isUseNavigator2 = true;
    return _informationParser;
  }

  NavigatorState? get navigator {
    assert(_observer.navigator != null, 'please add the observer into app');
    return _observer.navigator;
  }

  BuildContext get context {
    assert(_observer.navigator != null, 'please add the observer into app');
    return navigator!.context;
  }

  ErrorPage _errorPage;

  bool isUseNavigator2;

  bool isDebugMode;

  RRouterBasic({
    ErrorPage? errorPage,
    this.isUseNavigator2 = false,
    List<RouteInterceptor>? interceptor,
    this.isDebugMode = true,
  })  : _errorPage = errorPage ?? DefaultErrorPage(),
        _defaultTransitionBuilder = const FadeUpwardsPageTransitionsBuilder(),
        _interceptor = interceptor ?? <RouteInterceptor>[];

  /// Debug Mode
  ///
  /// [isDebug] will print debug data.
  RRouterBasic setDebugMode(bool isDebug) {
    this.isDebugMode = isDebug;
    return this;
  }

  /// default transition builder
  ///
  /// [pageTransitionsBuilder] default page Transition builder
  RRouterBasic setDefaultTransitionBuilder(
      PageTransitionsBuilder pageTransitionsBuilder) {
    this._defaultTransitionBuilder = pageTransitionsBuilder;
    return this;
  }

  /// default print
  ///
  /// [msg] you want to print msg.
  void _print(Object msg) {
    if (isDebugMode == true) {
      print(msg);
    }
  }

  /// set Error Page
  ///
  /// [errorPage] found in ErrorPage Class
  RRouterBasic setErrorPage(ErrorPage errorPage) {
    this._errorPage = errorPage;
    return this;
  }

  /// add Routes
  ///
  /// [routes] You want to registe routes.
  RRouterBasic addRoutes(Iterable<NavigatorRoute> routes) {
    _register.add(routes);
    return this;
  }

  /// add Route
  ///
  /// [route] You want to add route
  /// [isReplaceRouter] if ture will replace route
  RRouterBasic addRoute(NavigatorRoute route, {bool? isReplaceRouter}) {
    _register.addRoute(route, isReplaceRouter: isReplaceRouter);
    return this;
  }

  /// add route observer
  ///
  /// [observer] Navigator Observer
  RRouterBasic addObserver(NavigatorObserver observer) {
    _delegate.addObserver(observer);
    return this;
  }

  /// add route observers
  ///
  /// [observers] Navigator Observer List
  RRouterBasic addObservers(Iterable<NavigatorObserver> observers) {
    _delegate.addObservers(observers);
    return this;
  }

  /// add interceptor
  ///
  /// [interceptor]  add interceptor.
  RRouterBasic addInterceptor(RouteInterceptor interceptor) {
    _interceptor.add(interceptor);
    return this;
  }

  /// add interceptors
  ///
  /// [interceptors]  add interceptor list.
  RRouterBasic addInterceptors(List<RouteInterceptor> interceptors) {
    _interceptor.addAll(interceptors);
    return this;
  }

  /// When you add Route complete ,you should use it
  void addComplete() {
    _register._build();
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
      return Material(
        child: Builder(
            builder: (BuildContext context) =>
                _errorPage.errorPage(context, flutterErrorDetails)),
      );
    };
  }

  /// Navigate to Route
  /// [path]  page path
  /// [body] page require arguments
  /// [replace] if ture will replace current page to navigate new page.
  /// [clearTrace] if ture will clear all page  to navigate new page.
  /// [isSingleTop] if ture will only path is not current path navigate.
  /// [result] went replace is true, this will able.
  /// [pageTransitions] you navigate transition , if null will use default page transitions builder.
  Future<dynamic> navigateTo<T extends Object?, TO extends Object?>(String path,
      {dynamic body,
      bool? replace,
      bool? clearTrace,
      bool? isSingleTop,
      TO? result,
      PageTransitionsBuilder? pageTransitions}) async {
    PageTransitionsBuilder? _pageTransitions;
    WidgetBuilder? builder;
    final ctx = Context(
      path,
      body: body,
    );
    if (_interceptor.length > 0) {
      dynamic result;
      for (final interceptor in _interceptor) {
        result = await interceptor(ctx);
        if (result == true) {
          return;
        }
      }
    }
    NavigatorRoute? handler = _register.match(ctx.uri);
    if (handler != null) {
      final interceptor = handler.getInterceptor();
      if (interceptor.length > 0) {
        dynamic result;
        for (final interceptor in interceptor) {
          result = await interceptor(ctx);
          if (result == true) {
            return;
          }
        }
      }
      final result = await handler(ctx);
      if (result is WidgetBuilder) {
        builder = result;
        _pageTransitions = pageTransitions ?? handler.defaultPageTransaction;
      } else if (result is Redirect) {
        return await navigateTo(result.path,
            body: body,
            replace: replace,
            clearTrace: clearTrace,
            isSingleTop: isSingleTop,
            result: result,
            pageTransitions: pageTransitions);
      } else {
        return SynchronousFuture(result);
      }
    } else {
      builder = (BuildContext context) => _errorPage.notFoundPage(context, ctx);
    }

    _pageTransitions ??= _defaultTransitionBuilder;

    dynamic navigateResult;

    if (isSingleTop == true && _observer.topPath == path) {
      return null;
    }

    if (isUseNavigator2 == true) {
      if (clearTrace == true) {
        navigateResult = await _delegate
            .clearTracePush(_pageNamed(ctx, builder, _pageTransitions));
      } else if (replace == true) {
        navigateResult = await _delegate.replacePush<T, TO>(
            _pageNamed(ctx, builder, _pageTransitions), result);
      } else {
        navigateResult =
            await _delegate.push(_pageNamed(ctx, builder, _pageTransitions));
      }
    } else {
      if (clearTrace == true) {
        navigateResult = await navigator!.pushAndRemoveUntil<T>(
            _routeNamed<T>(ctx, builder, _pageTransitions), (check) => false);
      } else {
        navigateResult = replace == true
            ? await navigator!.pushReplacement<T?, TO>(
                _routeNamed<T>(ctx, builder, _pageTransitions),
                result: result)
            : await navigator!
                .push<T>(_routeNamed<T>(ctx, builder, _pageTransitions));
      }
    }
    return SynchronousFuture(navigateResult);
  }

  PageRoute<T> _routeNamed<T extends Object?>(Context ctx,
      WidgetBuilder builder, PageTransitionsBuilder pageTransitionsBuilder) {
    return CustomPageRoute<T>(
        pageTransitionsBuilder: pageTransitionsBuilder,
        builder: builder,
        settings: RouteSettings(name: ctx.path, arguments: ctx.toJson()));
  }

  Page<dynamic> _pageNamed(Context ctx, WidgetBuilder builder,
      PageTransitionsBuilder pageTransitionsBuilder) {
    return CustomPage<dynamic>(
        child:
            Builder(builder: (BuildContext context) => builder.call(context)),
        pageTransitionsBuilder: pageTransitionsBuilder,
        key: ValueKey(ctx.at.microsecondsSinceEpoch),
        name: ctx.path,
        arguments: ctx.toJson(),
        restorationId: ctx.path);
  }

  /// Pop the top-most route off the navigator.
  ///
  /// [result] you want to pop value.
  pop<T extends Object?>([T? result]) {
    if (isUseNavigator2 == true) {
      return _delegate.pop<T>(result);
    } else {
      return navigator!.pop<T>(result);
    }
  }

  /// Whether the navigator can be popped.
  ///
  /// {@macro flutter.widgets.navigator.canPop}
  ///
  /// See also:
  ///
  ///  * [Route.isFirst], which returns true for routes for which [canPop]
  ///    returns false.
  bool canPop() {
    if (isUseNavigator2 == true) {
      return _delegate.canPop();
    } else {
      return navigator!.canPop();
    }
  }

  /// Consults the current route's [Route.willPop] method, and acts accordingly,
  /// potentially popping the route as a result; returns whether the pop request
  /// should be considered handled.
  ///
  /// {@macro flutter.widgets.navigator.maybePop}
  ///
  /// See also:
  ///
  ///  * [Form], which provides an `onWillPop` callback that enables the form
  ///    to veto a [pop] initiated by the app's back button.
  ///  * [ModalRoute], which provides a `scopedWillPopCallback` that can be used
  ///    to define the route's `willPop` method.
  Future<bool> maybePop<T extends Object?>([T? result]) {
    if (isUseNavigator2 == true) {
      return _delegate.maybePop<T>(result);
    } else {
      return navigator!.maybePop<T>(result);
    }
  }

  Future<WidgetBuilder?> runRoute(String path, dynamic body) async {
    final ctx = Context(
      path,
      body: body,
    );
    NavigatorRoute? handler = _register.match(ctx.uri);
    if (handler != null) {
      final result = await handler(ctx);
      if (result is WidgetBuilder) {
        return result;
      } else if (result is Redirect) {
        return runRoute(result.path, body);
      }
    }
    return null;
  }
}

extension RRouterBuildContextExtension on BuildContext {
  /// get ctx from route
  Context get readCtx {
    final modal = ModalRoute.of(this);
    assert(modal != null, 'Please use RRoute navigateTo');
    assert(modal!.settings.arguments is Map, 'Please use RRoute navigateTo');

    return Context.fromJson(modal!.settings.arguments as Map);
  }
}
