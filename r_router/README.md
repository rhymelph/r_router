# r_router
[![pub package](https://img.shields.io/pub/v/r_router.svg)](https://pub.dartlang.org/packages/r_router)

A Flutter router package,you can not need use context to navigate,and support dialog.

## [中文点此](README_ZH.md)

## 1.Getting Started.

- use plugin:
add this code in `pubspec.yaml`
```yaml
dependencies:
  r_router: last version
```
- add the packages to your file.
```dart
import 'package:r_router/r_router.dart';

```
## 2.Simple use

- register router
```dart
/// [path] your router path.
/// [routerWidgetBuilder] build your widget.
/// [params] your params , support all value.
/// [PageOne] your page.
RRouter.myRouter.addRouter(
    path: '/one',
    routerWidgetBuilder: (params) => PageOne(title:params["title"]),
  );

```

- add the router in app.
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
- navigate to it.
```dart
    /// [path] you register path.
    /// [arguments] you want to give [path] arguments.
    /// [replace] will replace route
    /// [clearTrace] will clear all route and push [path].
    /// [isSingleTop] if [path] is top,There was no response.
    RRouter.myRouter.navigateTo('/one', arguments: {'title': 'hello world!'});
```

## 3.Register router
```dart

/// register not found page
RRouter.myRouter.notFoundPage = (String path) => NoFoundPage(
        path: path,
      );

/// set page build transform ,default platform page transitions
RRouter.myRouter.addRouter(
      path: '/three',
      routerWidgetBuilder: (params) => PageThree(),
      routerPageBuilder: RRouterPageBuilderType.cupertino,)
```
## 4. Custom Page Transitions
```dart
/// set page build transitions
  RRouter.myRouter.addRouter(
    path: '/four',
    routerWidgetBuilder: (params) => PageFour(),
    routerPageTransitions: ZoomPageTransitionsBuilder(),
  );
```

## 5. Not context show dialog
support as follows method
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

## 6.Default Navigator
you can use
```dart
RRouter.navigator
```

## 7.Add Interceptor

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

