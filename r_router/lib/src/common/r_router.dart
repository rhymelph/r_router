library r_router;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SearchDelegate;
import 'package:path_tree/path_tree.dart';
import 'package:r_router/r_router.dart';
import 'package:r_router/src/screens/bottom_sheet.dart';
import 'package:r_router/src/screens/popup_menu.dart';
import 'package:r_router/src/screens/search.dart';
import 'package:r_router/src/utils/string.dart';

import 'web_config/path_strategy_io.dart'
    if (dart.library.html) 'web_config/path_strategy_web.dart';

part 'context.dart';

part 'navigator_route.dart';

part 'params.dart';

part 'r_router_delegate.dart';

part 'r_router_information_parse.dart';

part 'r_router_observer.dart';

part 'r_router_register.dart';

part 'redirect.dart';

RRouterBasic RRouter = RRouterBasic();

typedef PopHome = Future<bool> Function();

typedef Page<dynamic> PageBuilder(Context ctx, WidgetBuilder builder,
    PageTransitionsBuilder pageTransitionsBuilder);

//Custom Page Builder
PageBuilder _kDefaultCustomPageBuilder = (Context ctx, WidgetBuilder builder,
        PageTransitionsBuilder pageTransitionsBuilder) =>
    CustomPage<dynamic>(
        child:
            Builder(builder: (BuildContext context) => builder.call(context)),
        buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) =>
            PageBasedCustomPageRoute(
                page: page, pageTransitionsBuilder: pageTransitionsBuilder),
        key: ValueKey(ctx.at.microsecondsSinceEpoch),
        name: ctx.path,
        arguments: ctx.toJson(),
        restorationId: ctx.path);

Future<bool> Function() _kDefaultPopHome = () => Future.value(false);

class RRouterBasic {
  final RRouterRegister _register = RRouterRegister();
  final RRouterObserver _observer = RRouterObserver();
  final RRouterDelegate _delegate = RRouterDelegate();

  late final RRouterInformationParser _informationParser =
      RRouterInformationParser();

  PageTransitionsBuilder _defaultTransitionBuilder;
  final List<RouteInterceptor> _interceptor;

  BuildContext? get overlayContext => _delegate.overlayContext;

  NavigatorObserver get observer {
    isUseNavigator2 = false;
    addComplete();
    return _observer;
  }

  RRouterDelegate get delegate {
    isUseNavigator2 = true;
    addComplete();
    return _delegate;
  }

  RRouterInformationParser get informationParser {
    isUseNavigator2 = true;
    return _informationParser;
  }

  NavigatorState get navigator {
    assert(_observer.navigator != null, 'please add the observer into app');
    return _observer.navigator!;
  }

  BuildContext get context {
    assert(_observer.navigator != null, 'please add the observer into app');
    return navigator.context;
  }

  ErrorPage _errorPage;

  bool isUseNavigator2;

  bool isDebugMode;

  PageBuilder _pageBuilder;

  PopHome _popHome;

  RRouterBasic(
      {ErrorPage? errorPage,
      this.isUseNavigator2 = false,
      List<RouteInterceptor>? interceptor,
      this.isDebugMode = true,
      PageBuilder? pageBuilder,
      PopHome? popHome})
      : _errorPage = errorPage ?? DefaultErrorPage(),
        _defaultTransitionBuilder = const ZoomPageTransitionsBuilder(),
        _interceptor = interceptor ?? <RouteInterceptor>[],
        _pageBuilder = pageBuilder ?? _kDefaultCustomPageBuilder,
        _popHome = popHome ?? _kDefaultPopHome;

  /// Debug Mode
  ///
  /// [isDebug] will print debug data.
  RRouterBasic setDebugMode(bool isDebug) {
    this.isDebugMode = isDebug;
    return this;
  }

  /// path strategy mode
  ///
  /// if true ? will use http://localhost:8080/index.html
  /// if false ? will use http://localhost:8080/#/index.html
  RRouterBasic setPathStrategy(bool isUsePath) {
    setUrlPathStrategy(isUsePath);
    return this;
  }

  /// default transition builder
  ///
  /// [pageTransitionsBuilder] default page Transition builder
  RRouterBasic setDefaultTransitionBuilder(
      PageTransitionsBuilder pageTransitionsBuilder) {
    this._defaultTransitionBuilder = pageTransitionsBuilder;
    return this;
  }

  /// default print
  ///
  /// [msg] you want to print msg.
  void _print(Object msg) {
    if (isDebugMode == true) {
      print(msg);
    }
  }

  /// set Error Page
  ///
  /// [errorPage] found in ErrorPage Class
  RRouterBasic setErrorPage(ErrorPage errorPage) {
    this._errorPage = errorPage;
    return this;
  }

  /// set default page builder
  ///
  /// [pageBuilder] generate page.
  RRouterBasic setPageBuilder(PageBuilder pageBuilder) {
    this._pageBuilder = pageBuilder;
    return this;
  }

  /// set pop home method
  ///
  /// [popHome] if return false will did pop home.
  ///           or if true will hold.
  RRouterBasic setPopHome(PopHome popHome) {
    this._popHome = popHome;
    return this;
  }

  /// add Routes
  ///
  /// [routes] You want to add routes.
  RRouterBasic addRoutes(Iterable<NavigatorRoute> routes) {
    _register.add(routes);
    return this;
  }

  /// add Route
  ///
  /// [route] You want to add route
  /// [isReplaceRouter] if ture will replace route
  RRouterBasic addRoute(NavigatorRoute route, {bool? isReplaceRouter}) {
    _register.addRoute(route, isReplaceRouter: isReplaceRouter);
    return this;
  }

  /// add route observer
  ///
  /// [observer] Navigator Observer
  RRouterBasic addObserver(NavigatorObserver observer) {
    _delegate.addObserver(observer);
    return this;
  }

  /// add route observers
  ///
  /// [observers] Navigator Observer List
  RRouterBasic addObservers(Iterable<NavigatorObserver> observers) {
    _delegate.addObservers(observers);
    return this;
  }

  /// add interceptor
  ///
  /// [interceptor]  add interceptor.
  RRouterBasic addInterceptor(RouteInterceptor interceptor) {
    _interceptor.add(interceptor);
    return this;
  }

  /// add interceptors
  ///
  /// [interceptors]  add interceptor list.
  RRouterBasic addInterceptors(List<RouteInterceptor> interceptors) {
    _interceptor.addAll(interceptors);
    return this;
  }

  /// When you add Route complete ,you should use it
  void addComplete() {
    _register._build();
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
      return Material(
        child: Builder(
            builder: (BuildContext context) =>
                _errorPage.errorPage(context, flutterErrorDetails)),
      );
    };
  }

  /// Navigate to Route
  /// [path]  page path
  /// [body] page require arguments
  /// [replace] if ture will replace current page to navigate new page.
  /// [clearTrace] if ture will clear all page  to navigate new page.
  /// [isSingleTop] if ture will only path is not current path navigate.
  /// [result] went replace is true, this will able.
  /// [pageTransitions] you navigate transition , if null will use default page transitions builder.
  Future<dynamic> navigateTo<T extends Object?, TO extends Object?>(String path,
      {dynamic body,
      bool? replace,
      bool? clearTrace,
      bool? isSingleTop,
      TO? result,
      PageTransitionsBuilder? pageTransitions}) async {
    PageTransitionsBuilder? _pageTransitions;
    WidgetBuilder? builder;
    final ctx = Context(
      path,
      body: body,
    );
    if (_interceptor.length > 0) {
      dynamic result;
      for (final interceptor in _interceptor) {
        result = await interceptor(ctx);
        if (result == true) {
          return;
        }
      }
    }
    NavigatorRoute? handler = _register.match(ctx.uri);
    if (handler != null) {
      final interceptor = handler.getInterceptor();
      if (interceptor.length > 0) {
        dynamic result;
        for (final interceptor in interceptor) {
          result = await interceptor(ctx);
          if (result == true) {
            return;
          }
        }
      }
      final result = await handler(ctx);
      if (result is WidgetBuilder) {
        builder = result;
        _pageTransitions = pageTransitions ?? handler.defaultPageTransaction;
      } else if (result is Redirect) {
        return await navigateTo(result.path,
            body: body,
            replace: replace,
            clearTrace: clearTrace,
            isSingleTop: isSingleTop,
            result: result,
            pageTransitions: pageTransitions);
      } else {
        return SynchronousFuture(result);
      }
    } else {
      builder = (BuildContext context) => _errorPage.notFoundPage(context, ctx);
    }

    _pageTransitions ??= _defaultTransitionBuilder;

    dynamic navigateResult;

    if (isSingleTop == true && _observer.topPath == path) {
      return null;
    }

    if (isUseNavigator2 == true) {
      if (clearTrace == true) {
        navigateResult = await _delegate
            .clearTracePush(_pageNamed(ctx, builder, _pageTransitions));
      } else if (replace == true) {
        navigateResult = await _delegate.replacePush<T, TO>(
            _pageNamed(ctx, builder, _pageTransitions), result);
      } else {
        navigateResult =
            await _delegate.push(_pageNamed(ctx, builder, _pageTransitions));
      }
    } else {
      if (clearTrace == true) {
        navigateResult = await navigator.pushAndRemoveUntil<T>(
            _routeNamed<T>(ctx, builder, _pageTransitions), (check) => false);
      } else {
        navigateResult = replace == true
            ? await navigator.pushReplacement<T?, TO>(
                _routeNamed<T>(ctx, builder, _pageTransitions),
                result: result)
            : await navigator
                .push<T>(_routeNamed<T>(ctx, builder, _pageTransitions));
      }
    }
    return SynchronousFuture(navigateResult);
  }

  /// generate page route(Navigation1.0)
  ///
  /// [ctx] route context
  /// [builder] widget builder
  /// [pageTransitionsBuilder] page transactions builder
  PageRoute<T> _routeNamed<T extends Object?>(Context ctx,
      WidgetBuilder builder, PageTransitionsBuilder pageTransitionsBuilder) {
    return CustomPageRoute<T>(
        pageTransitionsBuilder: pageTransitionsBuilder,
        builder: builder,
        settings: RouteSettings(name: ctx.path, arguments: ctx.toJson()));
  }

  /// generate page by name(Navigation2.0)
  ///
  /// [ctx] route context
  /// [builder] widget builder
  /// [pageTransitionsBuilder] page transactions builder
  Page<dynamic> _pageNamed(Context ctx, WidgetBuilder builder,
      PageTransitionsBuilder pageTransitionsBuilder) {
    return _pageBuilder(ctx, builder, pageTransitionsBuilder);
  }

  /// Pop the top-most route off the navigator.
  ///
  /// [result] you want to pop value.
  pop<T extends Object?>([T? result]) {
    if (isUseNavigator2 == true) {
      return _delegate.pop<T>(result);
    } else {
      return navigator.pop<T>(result);
    }
  }

  /// Whether the navigator can be popped.
  ///
  /// {@macro flutter.widgets.navigator.canPop}
  ///
  /// See also:
  ///
  ///  * [Route.isFirst], which returns true for routes for which [canPop]
  ///    returns false.
  bool canPop() {
    if (isUseNavigator2 == true) {
      return _delegate.canPop();
    } else {
      return navigator.canPop();
    }
  }

  /// Consults the current route's [Route.willPop] method, and acts accordingly,
  /// potentially popping the route as a result; returns whether the pop request
  /// should be considered handled.
  ///
  /// {@macro flutter.widgets.navigator.maybePop}
  ///
  /// See also:
  ///
  ///  * [Form], which provides an `onWillPop` callback that enables the form
  ///    to veto a [pop] initiated by the app's back button.
  ///  * [ModalRoute], which provides a `scopedWillPopCallback` that can be used
  ///    to define the route's `willPop` method.
  Future<bool> maybePop<T extends Object?>([T? result]) {
    if (isUseNavigator2 == true) {
      return _delegate.maybePop<T>(result);
    } else {
      return navigator.maybePop<T>(result);
    }
  }

  /// run route method
  ///
  /// [path] your register path.
  /// [body] post body
  Future<WidgetBuilder?> runRoute(String path, dynamic body) async {
    final ctx = Context(
      path,
      body: body,
    );
    NavigatorRoute? handler = _register.match(ctx.uri);
    if (handler != null) {
      final result = await handler(ctx);
      if (result is WidgetBuilder) {
        return result;
      } else if (result is Redirect) {
        return runRoute(result.path, body);
      }
    }
    return null;
  }

  /// match path
  ///
  /// [registerPath] your register path.
  /// [path] your want to match path.
  bool isMatchPath(String registerPath, String path) {
    PathTree<String> tree = PathTree<String>();
    tree.addPathAsSegments(pathToSegments(registerPath), registerPath);
    Uri uri = Uri.parse(path);
    String? result = tree.match(uri.pathSegments, 'GET');
    return result == registerPath;
  }

  Future<dynamic> showDialog({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
  }) {
    assert(debugCheckHasMaterialLocalizations(context));
    final CapturedThemes themes = InheritedTheme.capture(
      from: context,
      to: Navigator.of(
        context,
        rootNavigator: false,
      ).context,
    );
    if (isUseNavigator2 == true) {
      return _delegate.push(CustomPage<dynamic>(
          child: Builder(builder: builder),
          buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) =>
              PageBasedCustomPageRoute(
                  page: page,
                  pageTransitionsBuilder: DialogTransactionBuilder(
                      useSafeArea, themes, buildMaterialDialogTransitions)),
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          name: routeSettings?.name,
          opaque: false,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          fullscreenDialog: true,
          arguments: routeSettings?.arguments,
          restorationId: routeSettings?.name));
    } else {
      return navigator.push(DialogRoute<dynamic>(
        context: context,
        builder: builder,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        useSafeArea: useSafeArea,
        settings: routeSettings,
        themes: themes,
      ));
    }
  }

  Future<dynamic> showCupertinoDialog({
    required WidgetBuilder builder,
    String? barrierLabel,
    bool barrierDismissible = false,
    RouteSettings? routeSettings,
    bool useSafeArea = true,
  }) {
    if (isUseNavigator2 == true) {
      return _delegate.push(CustomPage<dynamic>(
          child: Builder(builder: builder),
          buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) =>
              PageBasedCustomPageRoute(
                  page: page,
                  pageTransitionsBuilder: DialogTransactionBuilder(
                      useSafeArea, null, buildCupertinoDialogTransitions)),
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          name: routeSettings?.name,
          opaque: false,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          fullscreenDialog: true,
          barrierColor: CupertinoDynamicColor.resolve(
              kCupertinoModalBarrierColor, context),
          arguments: routeSettings?.arguments,
          restorationId: routeSettings?.name));
    } else {
      return navigator.push(CupertinoDialogRoute(
        builder: builder,
        context: context,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        barrierColor:
            CupertinoDynamicColor.resolve(kCupertinoModalBarrierColor, context),
        settings: routeSettings,
      ));
    }
  }

  Future<dynamic> showCupertinoModalPopup({
    required WidgetBuilder builder,
    ImageFilter? filter,
    Color barrierColor = kCupertinoModalBarrierColor,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    bool? semanticsDismissible,
    RouteSettings? routeSettings,
  }) {
    if (isUseNavigator2 == true) {
      return _delegate.push(CustomPage<dynamic>(
          child: Builder(builder: builder),
          buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) {
            return CupertinoModalPopupRoute2(page: page);
          },
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          name: routeSettings?.name,
          opaque: false,
          barrierDismissible: barrierDismissible,
          barrierLabel: 'Dismiss',
          fullscreenDialog: true,
          filter: filter,
          barrierColor: kCupertinoModalBarrierColor,
          arguments: routeSettings?.arguments,
          restorationId: routeSettings?.name));
    } else {
      return navigator.push(
        CupertinoModalPopupRoute(
          builder: builder,
          filter: filter,
          barrierColor: CupertinoDynamicColor.resolve(barrierColor, context),
          barrierDismissible: barrierDismissible,
          semanticsDismissible: semanticsDismissible,
          settings: routeSettings,
        ),
      );
    }
  }

  Future<DateTime?> showDatePicker({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    SelectableDayPredicate? selectableDayPredicate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    Locale? locale,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    TransitionBuilder? builder,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
  }) async {
    BuildContext context = RRouter.context;
    assert(initialDate != null);
    assert(firstDate != null);
    assert(lastDate != null);
    initialDate = DateUtils.dateOnly(initialDate);
    firstDate = DateUtils.dateOnly(firstDate);
    lastDate = DateUtils.dateOnly(lastDate);
    assert(!lastDate.isBefore(firstDate),
        'lastDate $lastDate must be on or after firstDate $firstDate.');
    assert(!initialDate.isBefore(firstDate),
        'initialDate $initialDate must be on or after firstDate $firstDate.');
    assert(!initialDate.isAfter(lastDate),
        'initialDate $initialDate must be on or before lastDate $lastDate.');
    assert(
        selectableDayPredicate == null || selectableDayPredicate(initialDate),
        'Provided initialDate $initialDate must satisfy provided selectableDayPredicate.');
    assert(initialEntryMode != null);
    assert(useRootNavigator != null);
    assert(initialDatePickerMode != null);
    assert(debugCheckHasMaterialLocalizations(context));

    Widget dialog = DatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialEntryMode: initialEntryMode,
      selectableDayPredicate: selectableDayPredicate,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      initialCalendarMode: initialDatePickerMode,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      fieldHintText: fieldHintText,
      fieldLabelText: fieldLabelText,
    );

    if (textDirection != null) {
      dialog = Directionality(
        textDirection: textDirection,
        child: dialog,
      );
    }

    if (locale != null) {
      dialog = Localizations.override(
        context: context,
        locale: locale,
        child: dialog,
      );
    }
    return (await showDialog(
      routeSettings: routeSettings,
      builder: (BuildContext context) {
        return builder == null ? dialog : builder(context, dialog);
      },
    )) as DateTime?;
  }

  Future<DateTimeRange?> showDateRangePicker({
    DateTimeRange? initialDateRange,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? saveText,
    String? errorFormatText,
    String? errorInvalidText,
    String? errorInvalidRangeText,
    String? fieldStartHintText,
    String? fieldEndHintText,
    String? fieldStartLabelText,
    String? fieldEndLabelText,
    Locale? locale,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    TransitionBuilder? builder,
  }) async {
    BuildContext context = RRouter.context;
    assert(
        initialDateRange == null ||
            (initialDateRange.start != null && initialDateRange.end != null),
        'initialDateRange must be null or have non-null start and end dates.');
    assert(
        initialDateRange == null ||
            !initialDateRange.start.isAfter(initialDateRange.end),
        'initialDateRange\'s start date must not be after it\'s end date.');
    initialDateRange =
        initialDateRange == null ? null : DateUtils.datesOnly(initialDateRange);
    assert(firstDate != null);
    firstDate = DateUtils.dateOnly(firstDate);
    assert(lastDate != null);
    lastDate = DateUtils.dateOnly(lastDate);
    assert(!lastDate.isBefore(firstDate),
        'lastDate $lastDate must be on or after firstDate $firstDate.');
    assert(
        initialDateRange == null || !initialDateRange.start.isBefore(firstDate),
        'initialDateRange\'s start date must be on or after firstDate $firstDate.');
    assert(
        initialDateRange == null || !initialDateRange.end.isBefore(firstDate),
        'initialDateRange\'s end date must be on or after firstDate $firstDate.');
    assert(
        initialDateRange == null || !initialDateRange.start.isAfter(lastDate),
        'initialDateRange\'s start date must be on or before lastDate $lastDate.');
    assert(initialDateRange == null || !initialDateRange.end.isAfter(lastDate),
        'initialDateRange\'s end date must be on or before lastDate $lastDate.');
    currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now());
    assert(initialEntryMode != null);
    assert(useRootNavigator != null);
    assert(debugCheckHasMaterialLocalizations(context));

    Widget dialog = DateRangePickerDialog(
      initialDateRange: initialDateRange,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialEntryMode: initialEntryMode,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      saveText: saveText,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      errorInvalidRangeText: errorInvalidRangeText,
      fieldStartHintText: fieldStartHintText,
      fieldEndHintText: fieldEndHintText,
      fieldStartLabelText: fieldStartLabelText,
      fieldEndLabelText: fieldEndLabelText,
    );

    if (textDirection != null) {
      dialog = Directionality(
        textDirection: textDirection,
        child: dialog,
      );
    }

    if (locale != null) {
      dialog = Localizations.override(
        context: context,
        locale: locale,
        child: dialog,
      );
    }
    return (await showDialog(
      routeSettings: routeSettings,
      useSafeArea: false,
      builder: (BuildContext context) {
        return builder == null ? dialog : builder(context, dialog);
      },
    )) as DateTimeRange?;
  }

  Future<TimeOfDay?> showTimePicker({
    required TimeOfDay initialTime,
    TransitionBuilder? builder,
    bool useRootNavigator = true,
    TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
    String? cancelText,
    String? confirmText,
    String? helpText,
    RouteSettings? routeSettings,
  }) async {
    BuildContext context = RRouter.context;
    assert(initialTime != null);
    assert(useRootNavigator != null);
    assert(initialEntryMode != null);
    assert(debugCheckHasMaterialLocalizations(context));

    final Widget dialog = TimePickerDialog(
      initialTime: initialTime,
      initialEntryMode: initialEntryMode,
      cancelText: cancelText,
      confirmText: confirmText,
      helpText: helpText,
    );

    return (await showDialog(
      builder: (BuildContext context) {
        return builder == null ? dialog : builder(context, dialog);
      },
      routeSettings: routeSettings,
    )) as TimeOfDay?;
  }

  Future<dynamic> showGeneralDialog({
    required RoutePageBuilder pageBuilder,
    bool barrierDismissible = false,
    String? barrierLabel,
    Color barrierColor = const Color(0x80000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    assert(pageBuilder != null);
    assert(useRootNavigator != null);
    assert(!barrierDismissible || barrierLabel != null);
    if (isUseNavigator2 == true) {
      return _delegate.push(CustomPage<dynamic>(
          child: Container(),
          buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) {
            return RawDialogRoute2(page: page)
              ..pageBuilder = pageBuilder
              ..transitionBuilder = transitionBuilder;
          },
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          name: routeSettings?.name,
          opaque: false,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          fullscreenDialog: true,
          barrierColor: barrierColor,
          arguments: routeSettings?.arguments,
          transitionDuration: transitionDuration,
          restorationId: routeSettings?.name));
    } else {
      return navigator.push(RawDialogRoute(
        pageBuilder: pageBuilder,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        barrierColor: barrierColor,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        settings: routeSettings,
      ));
    }
  }

  Future<dynamic> showModalBottomSheet({
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor = Colors.black54,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
  }) {
    assert(builder != null);
    assert(isScrollControlled != null);
    assert(useRootNavigator != null);
    assert(isDismissible != null);
    assert(enableDrag != null);
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    if (isUseNavigator2 == true) {
      return _delegate.push(CustomPage<dynamic>(
          child: Builder(builder: builder),
          buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) {
            return ModalBottomSheetRoute2(page: page)
              ..capturedThemes =
                  InheritedTheme.capture(from: context, to: navigator.context)
              ..isScrollControlled = isScrollControlled
              ..backgroundColor = backgroundColor
              ..elevation = elevation
              ..shape = shape
              ..clipBehavior = clipBehavior
              ..enableDrag = enableDrag
              ..transitionAnimationController = transitionAnimationController;
          },
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          name: routeSettings?.name,
          opaque: false,
          barrierDismissible: isDismissible,
          fullscreenDialog: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: barrierColor,
          arguments: routeSettings?.arguments,
          restorationId: routeSettings?.name));
    } else {
      return navigator.push(ModalBottomSheetRoute(
        builder: builder,
        capturedThemes:
            InheritedTheme.capture(from: context, to: navigator.context),
        isScrollControlled: isScrollControlled,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        isDismissible: isDismissible,
        modalBarrierColor: barrierColor,
        enableDrag: enableDrag,
        settings: routeSettings,
        transitionAnimationController: transitionAnimationController,
      ));
    }
  }

  void showLicensePage({
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    bool useRootNavigator = false,
  }) {
    if (isUseNavigator2 == true) {
      _delegate.push(CustomPage<dynamic>(
          child: Builder(
              builder: (BuildContext context) => LicensePage(
                    applicationName: applicationName,
                    applicationVersion: applicationVersion,
                    applicationIcon: applicationIcon,
                    applicationLegalese: applicationLegalese,
                  )),
          buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) {
            return PageBasedCustomPageRoute(
                page: page, pageTransitionsBuilder: _defaultTransitionBuilder);
          },
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          name: null,
          opaque: false,
          fullscreenDialog: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          arguments: null,
          restorationId: null));
    } else {
      navigator.push(MaterialPageRoute<void>(
        builder: (BuildContext context) => LicensePage(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
        ),
      ));
    }
  }

  Future<dynamic> showMenu<T>({
    required RelativeRect position,
    required List<PopupMenuEntry<T>> items,
    T? initialValue,
    double? elevation,
    String? semanticLabel,
    ShapeBorder? shape,
    Color? color,
    bool useRootNavigator = false,
  }) {
    BuildContext context = RRouter.context;
    assert(items.isNotEmpty);
    assert(debugCheckHasMaterialLocalizations(context));

    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        semanticLabel ??= MaterialLocalizations.of(context).popupMenuLabel;
    }
    if (isUseNavigator2 == true) {
      return _delegate.push(CustomPage<dynamic>(
          child: Container(),
          buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) {
            return PopupMenuRoute2(page: page)
              ..capturedThemes =
                  InheritedTheme.capture(from: context, to: navigator.context)
              ..position = position
              ..items = items
              ..elevation = elevation
              ..shape = shape
              ..semanticLabel = semanticLabel
              ..capturedThemes =
                  InheritedTheme.capture(from: context, to: navigator.context);
          },
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          name: null,
          opaque: false,
          fullscreenDialog: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          arguments: null,
          restorationId: null));
    } else {
      return navigator.push(PopupMenuRoute(
        position: position,
        items: items,
        initialValue: initialValue,
        elevation: elevation,
        semanticLabel: semanticLabel,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        shape: shape,
        color: color,
        capturedThemes:
            InheritedTheme.capture(from: context, to: navigator.context),
      ));
    }
  }

  void showAboutDialog({
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    List<Widget>? children,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    showDialog(
      builder: (BuildContext context) {
        return AboutDialog(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
          children: children,
        );
      },
      routeSettings: routeSettings,
    );
  }

  Future<dynamic> showSearch<T>({
    required SearchDelegate<T> delegate,
    String? query = '',
    bool useRootNavigator = false,
  }) {
    assert(delegate != null);
    assert(context != null);
    assert(useRootNavigator != null);
    delegate.query = query ?? delegate.query;
    delegate.currentBody = SearchBody.suggestions;
    if (isUseNavigator2 == true) {
      return _delegate.push(CustomPage<dynamic>(
          child: Container(),
          buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) {
            return SearchPageRoute2(page: page)..delegate = delegate;
          },
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          name: null,
          opaque: false,
          fullscreenDialog: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          arguments: null,
          restorationId: null));
    } else {
      return navigator.push(SearchPageRoute<T>(
        delegate: delegate,
      ));
    }
  }
}

extension RRouterBuildContextExtension on BuildContext {
  /// get ctx from route
  Context get readCtx {
    final modal = ModalRoute.of(this);
    assert(modal != null, 'Please use RRoute navigateTo');
    assert(modal!.settings.arguments is Map, 'Please use RRoute navigateTo');

    return Context.fromJson(modal!.settings.arguments as Map);
  }
}
