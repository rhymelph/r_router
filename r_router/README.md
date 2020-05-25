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
    RRouter.myRouter.navigateTo('/one', arguments: {'title': 'hello world!'});
```

## 3.Register router
```dart

/// register not found page
RRouter.myRouter.notFoundPage = (String path) => NoFoundPage(
        path: path,
      );

/// set page build transform ,default platform page transform
RRouter.myRouter.addRouter(
      path: '/three',
      routerWidgetBuilder: (params) => PageThree(),
      routerPageBuilder: (RouteSettings setting, WidgetBuilder builder) =>
          CupertinoPageRoute(builder: builder, settings: setting))
```

## 4. Not context show dialog
support as follows method
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

## 5.Default Navigator
you can use
```dart
RRouter.navigator
```

## 6.Add Interceptor

```dart
  RRouter.myRouter.interceptor =
      RRouterInterceptorWrapper(onRequest: (settings) {
    if (settings.name == '/three') {
      return settings.copyWith(name: '/two');
    } else {
      return settings;
    }
  });
```