import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';
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
  RRouter.addRoute(NavigatorRoute(
          '/', (ctx) => MyHomePage(title: 'Flutter Demo Home Page')))
      .addRoute(NavigatorRoute('/one', (ctx) => PageOne()))
      .addRoute(NavigatorRoute(
          '/two',
          (ctx) => PageTwo(
                param: ctx?.body != null ? ctx.body['param'] : '',
              )))
      .addRoute(NavigatorRoute('/three', (ctx) => PageThree(),
          defaultPageTransaction: CupertinoPageTransitionsBuilder()))
      .addRoute(NavigatorRoute('/four', (ctx) => PageFour(),
          defaultPageTransaction: ZoomPageTransitionsBuilder()))
      .addRoute(NavigatorRoute('/five', (ctx) => PageFive()))
      .addRoute(NavigatorRoute('/five/:id', (ctx) => PageFive()))
      .setNavigator2()
      // .setDebugMode(true)
      .addComplete();
  // RRouter.myRouter.interceptors
  //     .add(RRouterInterceptorWrapper(onRequest: (settings) {
  //   if (settings.name == '/other') {
  //     return settings.copyWith(name: '/five');
  //   } else {
  //     return settings;
  //   }
  // }));
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
    //Navigator1.0
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   navigatorObservers: [
    //     RRouter.observer,
    //   ],
    //   home: MyHomePage(title: 'Flutter Demo Home Page'),
    // );
    //Navigator2.0
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: RRouter.delegate,
      routeInformationParser: RRouter.informationParser,
    );
  }
}
// use navigate
// RRouter.navigateTo('/three', arguments: {'pageThree': 'hello world!'});
