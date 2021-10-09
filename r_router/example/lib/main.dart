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
  // first setting
  RRouter.setPathStrategy(true)
      .setErrorPage(ErrorPageWrapper(
          error: (BuildContext context,
                  FlutterErrorDetails flutterErrorDetails) =>
              Center(
                child: Text(
                  'Exception Page (${flutterErrorDetails.exceptionAsString()})',
                ),
              ),
          notFound: (BuildContext context, Context ctx) => Material(
                child: Center(
                  child: Text('Page Not found:${ctx.path}'),
                ),
              )))
      .addRoute(NavigatorRoute(
          '/',
          (ctx) => MyHomePage(
                title: 'My Home',
              )))
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
      .addRoute(NavigatorRoute('/print', (ctx) async {
        return Future.value('调用函数');
      }, responseProcessor: (c, p) async {
        print(p);
        return 'hello';
      }))
      .addRoute(NavigatorRoute('/showDialog', (ctx) async {
        return null;
      }, responseProcessor: (c, p) async {
        await showRDialog(
            routeSettings: RouteSettings(name: c.path, arguments: c.body),
            builder: (context) => AlertDialog(
                  title: Text('title'),
                  content: Text('content'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('确定')),
                  ],
                ));
        return c.isDirectly == true ? Redirect(path: '/') : null;
      }))
      .setPageBuilder((ctx, builder, pageTransitionsBuilder) =>
          CustomPage<dynamic>(
              child: Builder(
                  builder: (BuildContext context) => builder.call(context)),
              pageTransitionsBuilder: pageTransitionsBuilder,
              key: ValueKey(ctx.at.microsecondsSinceEpoch),
              name: ctx.path,
              arguments: ctx.toJson(),
              transitionDuration: Duration(milliseconds: 100),
              restorationId: ctx.path));
  // or
  // RRouter.addRoutes([
  //   NavigatorRoute('/', (ctx) => MyHomePage(title: 'Flutter Demo Home Page')),
  //   NavigatorRoute('/one', (ctx) => PageOne()),
  //   NavigatorRoute(
  //       '/two',
  //       (ctx) => PageTwo(
  //             param: ctx?.body != null ? ctx.body['param'] : '',
  //           )),
  //   NavigatorRoute('/three', (ctx) => PageThree(),
  //       defaultPageTransaction: CupertinoPageTransitionsBuilder()),
  //   NavigatorRoute('/four', (ctx) => PageFour(),
  //       defaultPageTransaction: ZoomPageTransitionsBuilder()),
  //   NavigatorRoute('/five', (ctx) => PageFive()),
  //   NavigatorRoute('/five/:id', (ctx) => PageFive()),
  // ]).addInterceptor((ctx) async {
  //   if (ctx.path == '/other') {
  //     RRouter.navigateTo('/five', body: ctx.body);
  //     return true;
  //   }
  //   return false;
  // }).addInterceptor((ctx) async {
  //   if (ctx.path == '/two') {
  //     RRouter.navigateTo('/one', body: ctx.body);
  //     return true;
  //   }
  //   return false;
  // });
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
