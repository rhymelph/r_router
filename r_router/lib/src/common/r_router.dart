import 'dart:async';

import 'package:flutter/material.dart';
import 'package:r_router/src/screens/error_page.dart';

import 'context.dart';
import 'navigator_route.dart';
import 'r_router_register.dart';

class RRouter {
  final RRouterRegister register = RRouterRegister();

  ErrorPage errorPage;
  bool isUseNavigator2;

  final before = <RouteInterceptor>[];

  final after = <RouteInterceptor>[];

  final FutureOr<void> Function(Context ctx)? onRouteServed;

  RRouter({
    ErrorPage? errorPage,
    this.isUseNavigator2 = false,
    this.onRouteServed,
  }) : errorPage = errorPage ?? DefaultErrorPage();

  ///Registe Routes
  /// [routes] You want to registe routes.
  void registe(Iterable<NavigatorRoute> routes) {
    register.registe(routes);
  }

  /// Registe Route
  /// [route] You want to registe route.
  void registeRoute(NavigatorRoute route, {bool? isReplaceRouter}) {
    register.registeRoute(route);
  }

  Future<dynamic> navigateTo(String path,
      {dynamic params,
      bool? replace,
      bool? clearTrace,
      bool? isSingleTop,
      PageTransitionsBuilder? pageTransitions}) async {
    final uri = Uri.parse(path);
    PageTransitionsBuilder? _pageTransitions;

    final ctx = Context(
      uri,
      before: before.toList(),
      after: after.toList(),
      body: params,
    );

    NavigatorRoute? handler = register.match(uri);
    if (handler != null) {
      await handler(ctx);
      _pageTransitions = pageTransitions ?? handler.defaultPageTransaction;
    }
    _pageTransitions ??= const OpenUpwardsPageTransitionsBuilder();

    ctx.builder ??=
        (BuildContext context) => errorPage.notFoundPage(context, ctx);
    if (isUseNavigator2 == true) {

    } else {

    }
  }
}
