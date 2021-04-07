# r_router
[![pub package](https://img.shields.io/pub/v/r_router.svg)](https://pub.dartlang.org/packages/r_router)

一个无需使用context导航的Flutter路由插件，支持dialog


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
/// [routerWidgetBuilder] 构建你的页面
/// [params] 你的参数，支持所有类型的值，类型为dynamic
/// [PageOne] 你的部件
RRouter.myRouter.addRouter(
    path: '/one',
    routerWidgetBuilder: (params) => PageOne(title:params["title"]),
  );

```

- 添加你的路由到app
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
      onGenerateRoute: RRouter.myRouter.routerGenerate,
      navigatorObservers: [
        RRouter.myRouter.observer,
      ],
      // add new
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

```
- 导航到注册的页面
```dart
    /// [path] 你注册的页面
    /// [arguments] 需要传递的参数
    /// [replace]  是否替换当前route
    /// [clearTrace] 跳转前是否清除所有route
    /// [isSingleTop] 当为true时，当前页面为需要路由的页面，无反应(避免重复跳转页面)
    RRouter.myRouter.navigateTo('/one', arguments: {'title': 'hello world!'});
```

## 3.注册路由
```dart

/// 注册未找到页面的路由
RRouter.myRouter.notFoundPage = (String path) => NoFoundPage(
        path: path,
      );

/// 注册带过渡动画的路由，默认为根据对应平台的过渡动画,ios:CupertinoPageRoute,android:MaterialPageRoute
RRouter.myRouter.addRouter(
      path: '/three',
      routerWidgetBuilder: (params) => PageThree(),
      routerPageBuilder: RRouterPageBuilderType.cupertino)
```

## 4. 注册带页面转换的路由
```dart
/// 注册为自定义的页面转换效果
  RRouter.myRouter.addRouter(
    path: '/four',
    routerWidgetBuilder: (params) => PageFour(),
    routerPageTransitions: ZoomPageTransitionsBuilder(),
  );
```

## 5. 无需context的展示对话框方法
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

## 6.默认的路由器
you can use
```dart
RRouter.navigator
```

## 7.添加拦截器,可重定向到另一个路由

```dart
  RRouter.myRouter.interceptors
      .add(RRouterInterceptorWrapper(onRequest: (settings) {
    if (settings.name == '/three') {
      return settings.copyWith(name: '/two');
    } else {
      return settings;
    }
  }));
```

##