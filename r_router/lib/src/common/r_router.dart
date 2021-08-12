library r_router;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_tree/path_tree.dart';
import 'package:r_router/src/screens/error_page.dart';
import 'package:r_router/src/utils/string.dart';

import '../screens/custom_page_route.dart';

part 'r_router_information_parse.dart';

part 'context.dart';

part 'params.dart';

part 'navigator_route.dart';

part 'r_router_register.dart';

part 'r_router_delegate.dart';

part 'r_router_observer.dart';

_RRouter RRouter = _RRouter();

class _RRouter {
  final RRouterRegister _register = RRouterRegister();
  final RRouterObserver observer = RRouterObserver();
  final RRouterDelegate delegate = RRouterDelegate();
  final RRouterInformationParser informationParser = RRouterInformationParser();
  final PageTransitionsBuilder defaultTransitionBuilder;

  NavigatorState? get navigator {
    assert(observer.navigator != null, 'please add the observer into app');
    return observer.navigator;
  }

  BuildContext get context {
    assert(observer.navigator != null, 'please add the observer into app');
    return navigator!.context;
  }

  ErrorPage _errorPage;

  bool isUseNavigator2;

  bool isDebugMode;

  final FutureOr<void> Function(Context ctx)? onRouteServed;

  _RRouter({
    ErrorPage? errorPage,
    this.isUseNavigator2 = false,
    this.onRouteServed,
    this.isDebugMode = false,
  })  : _errorPage = errorPage ?? DefaultErrorPage(),
        defaultTransitionBuilder = const FadeUpwardsPageTransitionsBuilder();

  _RRouter setNavigator2() {
    this.isUseNavigator2 = true;
    return this;
  }

  _RRouter setDebugMode(bool isDebug) {
    this.isDebugMode = isDebug;
    return this;
  }

  void _print(Object msg) {
    if (isDebugMode == true) {
      print(msg);
    }
  }

  /// add Error Page
  /// [errorPage] found in ErrorPage Class
  _RRouter addErrorPage(ErrorPage errorPage) {
    this._errorPage = errorPage;
    return this;
  }

  /// add Routes
  ///
  /// [routes] You want to registe routes.
  _RRouter add(Iterable<NavigatorRoute> routes) {
    _register.add(routes);
    return this;
  }

  /// add Route
  /// [route] You want to add route
  /// [isReplaceRouter] if ture will replace route
  _RRouter addRoute(NavigatorRoute route, {bool? isReplaceRouter}) {
    _register.addRoute(route, isReplaceRouter: isReplaceRouter);
    return this;
  }

  void addComplete() {
    _register.build();
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
      return Material(
        child: Builder(
            builder: (BuildContext context) =>
                _errorPage.errorPage(context, flutterErrorDetails)),
      );
    };
  }

  /// Navigate to Route
  ///
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
    NavigatorRoute? handler = _register.match(ctx.uri);
    if (handler != null) {
      builder = await handler(ctx);
      _pageTransitions = pageTransitions ?? handler.defaultPageTransaction;
    }
    _pageTransitions ??= defaultTransitionBuilder;

    builder ??= (BuildContext context) => _errorPage.notFoundPage(context, ctx);
    dynamic navigateResult;

    if (isSingleTop == true && observer.topPath == path) {
      return null;
    }

    if (isUseNavigator2 == true) {
      if (clearTrace == true) {
        navigateResult = await delegate
            .clearTracePush(_pageNamed(ctx, builder, _pageTransitions));
      } else if (replace == true) {
        navigateResult = await delegate.replacePush<T, TO>(
            _pageNamed(ctx, builder, _pageTransitions), result);
      } else {
        navigateResult =
            await delegate.push(_pageNamed(ctx, builder, _pageTransitions));
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
        key: ValueKey(ctx.path),
        name: ctx.path,
        arguments: ctx.toJson(),
        restorationId: ctx.path);
  }

  /// Pop the top-most route off the navigator.
  pop<T extends Object?>([T? result]) {
    if (isUseNavigator2 == true) {
      return delegate.pop<T>(result);
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
      return delegate.canPop();
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
      return delegate.maybePop<T>(result);
    } else {
      return navigator!.maybePop<T>(result);
    }
  }
}

extension RRouterBuildContextExtension on BuildContext {
  Context get readCtx {
    final modal = ModalRoute.of(this);
    assert(modal != null, 'Please use RRoute navigateTo');
    assert(modal!.settings.arguments is Map, 'Please use RRoute navigateTo');

    return Context.fromJson(modal!.settings.arguments as Map);
  }
}
