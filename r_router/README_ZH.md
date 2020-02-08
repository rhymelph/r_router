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
      routerPageBuilder: (RouteSettings setting, WidgetBuilder builder) =>
          CupertinoPageRoute(builder: builder, settings: setting))
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
- showRSearch
- showRModalBottomSheet
- showRLicensePage

## 5.默认的路由器
you can use
```dart
RRouter.navigator
```
