import 'package:flutter/material.dart';

class TransactionPageBuilderWrapper extends PageTransitionsBuilder {
  final RoutePageBuilder pageBuilder;

  TransactionPageBuilderWrapper(this.pageBuilder);

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return pageBuilder(context, animation, secondaryAnimation);
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

final Animatable<double> _dialogScaleTween = Tween<double>(begin: 1.3, end: 1.0)
    .chain(CurveTween(curve: Curves.linearToEaseOut));

/// cupertino dialog style
/// [context] BuildContext
/// [animation] animation
/// [secondaryAnimation] Secondary Animation
/// [child] Widget child
Widget buildCupertinoDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  final CurvedAnimation fadeAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  );
  if (animation.status == AnimationStatus.reverse) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }
  return FadeTransition(
    opacity: fadeAnimation,
    child: ScaleTransition(
      scale: animation.drive(_dialogScaleTween),
      child: child,
    ),
  );
}

/// material dialog style
/// [context] BuildContext
/// [animation] animation
/// [secondaryAnimation] Secondary Animation
/// [child] Widget child
Widget buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}

class DialogTransactionBuilder extends PageTransitionsBuilder {
  final bool useSafeArea;
  final CapturedThemes? themes;
  final RouteTransitionsBuilder transitionBuilder;

  const DialogTransactionBuilder(
      this.useSafeArea, this.themes, this.transitionBuilder);

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    final Widget pageChild = child;
    Widget dialog = themes?.wrap(pageChild) ?? pageChild;
    if (useSafeArea) {
      dialog = SafeArea(child: dialog);
    }
    return transitionBuilder(context, animation, secondaryAnimation, dialog);
  }
}
