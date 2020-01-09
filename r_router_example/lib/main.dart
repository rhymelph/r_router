import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';
import 'package:r_router_example/src/page/my_page.dart';
import 'package:r_router_example/src/page/page_one.dart';
import 'package:r_router_example/src/page/page_three.dart';
import 'package:r_router_example/src/page/page_two.dart';

void main() {
  // add new
  RRouter.myRouter.addRouter(
    path: '/one',
    routerWidgetBuilder: (params) => PageOne(),
  );
  RRouter.myRouter.notFountPage =(path) => PageTwo();
  RRouter.myRouter.addRouter(
      path: '/three',
      routerWidgetBuilder: (params) => PageThree(
            pageThree: params['pageThree'],
          ),
      routerPageBuilder: (RouteSettings setting, WidgetBuilder builder) =>
          CupertinoPageRoute(builder: builder, settings: setting));
  // add new
  runApp(MyApp());
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
