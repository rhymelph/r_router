# r_router
[![pub package](https://img.shields.io/pub/v/r_router.svg)](https://pub.dartlang.org/packages/r_router)

一个无需使用context导航的Flutter路由插件，支持dialog、正则匹配、路由时自定义跳转动画、Navigator2.0


## 1.开始使用.

- `pubspec.yaml`文件添加依赖
```yaml
dependencies:
  r_router: last version
```
- 导入包
```dart
import 'package:r_router/r_router.dart';

```
## 2.简单使用

- 注册路由
```dart
/// [path] 你的路由路径
/// [handler] 构建你的页面((ctx) => PageOne()))
/// [ctx] 使用RRouter.navigateTo 时传递过来的参数
/// [PageOne] 你的部件
RRouter.addRoute(NavigatorRoute('/one', (ctx) => PageOne()));

```

- Navigator1.0方式添加你的路由到app
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // add new
      navigatorObservers: [
        RRouter.observer,
      ],
      // add new
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

```

- Navigator 2.0方式添加你的路由到app
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
```
- 导航到注册的页面
```dart
    /// [path] 你注册的页面，可以带查询参数和路径参数，例如：/user/1 , /user?id = 1
    /// [body] 需要传递的参数
    /// [replace]  是否替换当前route
    /// [clearTrace] 跳转前是否清除所有route
    /// [isSingleTop] 当为true时，当前页面为需要路由的页面，无反应(避免重复跳转页面)
    /// [pageTransitions] 跳转效果，如果不传，会默认使用注册时的跳转效果，如果没有设置注册的跳转效果，将会使用[RRouter.setDefaultTransitionBuilder]的
     RRouter.navigateTo('/one');
```

## 3.注册路由
```dart

/// 注册未找到页面和异常的路由
  RRouter.setErrorPage(ErrorPageWrapper(
      error: (BuildContext context, FlutterErrorDetails flutterErrorDetails) =>
          Center(
            child: Text(
              'Exception Page (${flutterErrorDetails.exceptionAsString()})',
            ),
          ),
      notFound: (BuildContext context, Context ctx) => Material(
            child: Center(
              child: Text('Page Not found:${ctx.path}'),
            ),
          )));

/// 注册带过渡动画的路由
RRouter.addRoute(NavigatorRoute('/three', (ctx) => PageThree(),
    defaultPageTransaction: CupertinoPageTransitionsBuilder()))
```

## 4. 无需context的展示对话框方法
支持下面的方法
- showRDialog
- showRCupertinoDialog
- showRCupertinoModalPopup
- showRAboutDialog
- showRMenu
- showRTimePicker
- showRGeneralDialog
- showRDatePicker
- showRDateRangePicker
- showRSearch
- showRModalBottomSheet
- showRLicensePage

## 5.默认的路由器
you can use
```dart
RRouter.navigator
```

## 6.添加拦截器,可重定向到另一个路由，返回true为拦截
```dart
  RRouter.addInterceptor((ctx) async {
    if (ctx.path == '/other') {
      RRouter.navigateTo('/five', body: ctx.body);
      return true;
    }
    return false;
  });
```

## 7. 你可以使用 (/user/:id) 或者 (/user/*) 匹配跳转的路由
```dart
  RRouter.addRoute(NavigatorRoute('/five/:id', (ctx) => PageFive(id:ctx.pathParams.getInt('id'))));
  RRouter.addRoute(NavigatorRoute('/five?id=1', (ctx) => PageFive(id:ctx.queryParams.getInt('id'))));
  RRouter.addRoute(NavigatorRoute('/five/*', (ctx) => PageFive()));
```

## 8. 你可以使用 (/user/:id) 加 `pathRegEx` 正则匹配跳转的路由
```dart
  // 当请求的id 为数值时才会跳转到该页面
  RRouter.addRoute(NavigatorRoute('/five/:id', (ctx) => PageFive(id:ctx.pathParams.getInt('id')))，pathRegEx:{'id':r'^[0-9]*$'});
```

## 9.通过Context 获取参数
```dart
    Context ctx = context.readCtx;
```

## 10.重定向
```dart
RRouter.addRoute(NavigatorRoute('/showDialog', (ctx) async {
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
      }));

// or
RRouter.addRoute(NavigatorRoute('/showDialog', (ctx) async {
        return Redirect(path: '/');
      }));
```