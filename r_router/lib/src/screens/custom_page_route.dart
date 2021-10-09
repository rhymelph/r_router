import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// navigate1.0
class CustomPageRoute<T extends Object?> extends PageRoute<T> {
  CustomPageRoute({
    required this.pageTransitionsBuilder,
    required this.builder,
    RouteSettings? settings,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
    bool fullscreenDialog = false,
    this.transitionDuration = const Duration(milliseconds: 300),
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog);

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  /// page transition builder
  final PageTransitionsBuilder pageTransitionsBuilder;

  /// barrier color
  final Color? barrierColor;

  /// barrier label
  final String? barrierLabel;

  final bool maintainState;

  final Duration transitionDuration;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is CustomPageRoute && !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoPageRoute && !nextRoute.fullscreenDialog);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return pageTransitionsBuilder.buildTransitions(
        this, context, animation, secondaryAnimation, child);
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

/// navigator2.0
class CustomPage<T extends Object?> extends Page<T> {
  /// Creates a material page.
  CustomPage({
    required this.child,
    required this.pageTransitionsBuilder,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.barrierColor,
    this.barrierLabel,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  })  : completerResult = Completer(),
        assert(child != null),
        assert(maintainState != null),
        assert(fullscreenDialog != null),
        super(
            key: key,
            name: name,
            arguments: arguments,
            restorationId: restorationId);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  final PageTransitionsBuilder pageTransitionsBuilder;

  final Completer completerResult;

  final Duration transitionDuration;

  final Color? barrierColor;

  final String? barrierLabel;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedCustomPageRoute<T>(page: this);
  }
}

class _PageBasedCustomPageRoute<T> extends PageRoute<T>
    with CustomRouteTransitionMixin<T> {
  _PageBasedCustomPageRoute({
    required CustomPage<T> page,
  })  : assert(page != null),
        super(settings: page) {
    assert(opaque);
  }

  CustomPage<T> get _page => settings as CustomPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  Color? get barrierColor => _page.barrierColor;

  @override
  String? get barrierLabel => _page.barrierLabel;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  PageTransitionsBuilder get pageTransitionsBuilder =>
      _page.pageTransitionsBuilder;

  @override
  Duration get transitionDuration => _page.transitionDuration;
}

mixin CustomRouteTransitionMixin<T> on PageRoute<T> {
  /// Builds the primary contents of the route.
  @protected
  Widget buildContent(BuildContext context);

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is CustomRouteTransitionMixin &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoRouteTransitionMixin &&
            !nextRoute.fullscreenDialog);
  }

  PageTransitionsBuilder get pageTransitionsBuilder;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = buildContent(context);
    assert(() {
      if (result == null) {
        throw FlutterError(
            'The builder for route "${settings.name}" returned null.\n'
            'Route builders must never return null.');
      }
      return true;
    }());
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return pageTransitionsBuilder.buildTransitions<T>(
        this, context, animation, secondaryAnimation, child);
  }
}

class NoTransitionBuilder extends PageTransitionsBuilder {
  const NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return child;
  }
}
