import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';
import 'package:r_router_example/src/page/404_page.dart';
import 'src/page/my_page.dart';
import 'src/page/page_one.dart';
import 'src/page/page_three.dart';
import 'src/page/page_two.dart';

void main() {
  initRouter();
  runApp(MyApp());
}

void initRouter() {
  // add new
  RRouter.myRouter.addRouter(
    path: '/one',
    routerWidgetBuilder: (params) => PageOne(),
  );
  RRouter.myRouter.addRouter(
    path: '/two',
    routerWidgetBuilder: (params) => PageTwo(
      param: params['param'],
    ),
  );
  RRouter.myRouter.addRouter(
      path: '/three',
      routerWidgetBuilder: (params) => PageThree(),
      routerPageBuilder: (RouteSettings setting, WidgetBuilder builder) =>
          CupertinoPageRoute(builder: builder, settings: setting));
  RRouter.myRouter.notFoundPage = (String path) => NoFoundPage(
        path: path,
      );

//  RRouter.myRouter.interceptor =
//      RRouterInterceptorWrapper(onRequest: (settings) {
//    if (settings.name == '/three') {
//      return settings.copyWith(name: '/two');
//    } else {
//      return settings;
//    }
//  });
  // add new
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // add new
      onGenerateRoute: RRouter.myRouter.routerGenerate,
      navigatorObservers: [
        RRouter.myRouter.observer,
      ],
      // add new
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
// use navigate
// RRouter.myRouter.navigateTo('/three', arguments: {'pageThree': 'hello world!'});
