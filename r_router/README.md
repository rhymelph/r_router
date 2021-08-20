# r_router
[![pub package](https://img.shields.io/pub/v/r_router.svg)](https://pub.dartlang.org/packages/r_router)

A Flutter router package,you can not need use context to navigate, support dialog/Path RegEx/navigate custom transaction/Navigator 2.0

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
/// [handler] handler Widget((ctx) => PageOne()))
/// [PageOne] your page.
/// [ctx] request data.
RRouter.addRoute(NavigatorRoute('/one', (ctx) => PageOne()));
```

- Navigator 1.0: add the route in app.
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

- Navigator 2.0: add the route in app.
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
- navigate to it.
```dart
    /// [path] you register path.
    /// [body] you want to give [path] arguments.
    /// [replace] will replace route
    /// [clearTrace] will clear all route and push [path].
    /// [isSingleTop] if [path] is top,There was no response.
    /// [pageTransitions] you navigate transition , if null will use default page transitions builder.
     RRouter.navigateTo('/one');
```

## 3.Register router
```dart

/// set error page.
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

/// set page build transform ,default platform page transitions
RRouter.addRoute(NavigatorRoute('/three', (ctx) => PageThree(),
    defaultPageTransaction: CupertinoPageTransitionsBuilder()))
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
  RRouter.addInterceptor((ctx) async {
    if (ctx.path == '/other') {
      RRouter.navigateTo('/five', body: ctx.body);
      return true;
    }
    return false;
  });
```

## 8. you can use (/user/:id) or (/user/*) registe route path.
```dart
  RRouter.addRoute(NavigatorRoute('/five/:id', (ctx) => PageFive(id:ctx.pathParams.getInt('id'))));
  RRouter.addRoute(NavigatorRoute('/five/*', (ctx) => PageFive()));
```

## 9. BuildContext get ctx
```dart
    Context ctx = context.readCtx;
```