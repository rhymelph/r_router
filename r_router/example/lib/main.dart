import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';
import 'package:r_router_example/src/page/404_page.dart';
import 'package:r_router_example/src/page/page_five.dart';
import 'package:r_router_example/src/page/page_four.dart';
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
    routerPageBuilderType: RRouterPageBuilderType.cupertino,
  );

  RRouter.myRouter.addRouter(
    path: '/four',
    routerWidgetBuilder: (params) => PageFour(),
    routerPageTransitions: ZoomPageTransitionsBuilder(),
  );

  RRouter.myRouter.addRouter(
    path: '/five',
    routerWidgetBuilder: (params) => PageFive(),
  );

  RRouter.myRouter.notFoundPage = (String path) => NoFoundPage(
        path: path,
      );

  RRouter.myRouter.interceptors
      .add(RRouterInterceptorWrapper(onRequest: (settings) {
    if (settings.name == '/other') {
      return settings.copyWith(name: '/five');
    } else {
      return settings;
    }
  }));
  // RRouter.myRouter.interceptors
  //     .add(RRouterInterceptorWrapper(onRequest: (settings) {
  //   if (settings.name == '/two') {
  //     return settings.copyWith(name: '/one');
  //   } else {
  //     return settings;
  //   }
  // }));

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
