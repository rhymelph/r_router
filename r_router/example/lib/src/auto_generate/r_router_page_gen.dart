import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';
import 'package:example/src/auto_generate/detail_page.dart'
    as detail_page;
import 'package:example/src/auto_generate/home_page.dart' as home_page;

class RRouterPageGen {
  static const String homePage = '/';
  static const String detailPage = '/:id';

  static void mount() {
    RRouter.addRoute(
      NavigatorRoute(
        homePage,
        (context) => home_page.HomePage(
          name: context.body["name"] as String,
        ),
        responseProcessor: home_page.onProcessor,
        interceptors: [home_page.onInterceptor],
        defaultPageTransaction: CupertinoPageTransitionsBuilder(),
      ),
    );
    RRouter.addRoute(
      NavigatorRoute(
        detailPage,
        (context) => detail_page.DetailPage(
          id: context.pathParams.getInt('id'),
        ),
        pathRegEx: {'id': '[0-9]'},
        responseProcessor: detail_page.onProcessor,
        interceptors: [detail_page.onInterceptor],
        defaultPageTransaction: CupertinoPageTransitionsBuilder(),
      ),
    );
  }

  static Future<dynamic> toHomePage(
      {dynamic body,
      bool? replace,
      bool? clearTrace,
      bool? isSingleTop,
      dynamic result,
      PageTransitionsBuilder? pageTransitions}) {
    return RRouter.navigateTo(
      homePage,
      body: body,
      replace: replace,
      clearTrace: clearTrace,
      isSingleTop: isSingleTop,
      result: result,
      pageTransitions: pageTransitions,
    );
  }

  static Future<dynamic> toDetailPage(String id,
      {dynamic body,
      bool? replace,
      bool? clearTrace,
      bool? isSingleTop,
      dynamic result,
      PageTransitionsBuilder? pageTransitions}) {
    return RRouter.navigateTo(
      RRouter.formatPath(detailPage, pathParams: {'id': id}),
      body: body,
      replace: replace,
      clearTrace: clearTrace,
      isSingleTop: isSingleTop,
      result: result,
      pageTransitions: pageTransitions,
    );
  }
}
