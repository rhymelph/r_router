import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_tree/path_tree.dart';

import 'context.dart';

typedef FutureOr<void> RouteInterceptor<Result>(Context ctx);

/// Function that modifies [context]
typedef FutureOr<void> ResponseProcessor(Context context, dynamic result);

typedef FutureOr<RespType> RouteHandler<RespType>(Context context);

class NavigatorRoute {
  /// Path of the route
  final String path;

  /// Map of regular expression matchers for specific path segment
  final Map<String, String>? pathRegEx;

  RouteHandler handler;

  final List<RouteInterceptor> _before;

  final List<RouteInterceptor> _after;

  final _pathVarMapping = <String, int>{};

  int? _pathGlobVarMapping;

  String? _pathGlobVarName;

  final Iterable<String> pathSegments;

  final ResponseProcessor? responseProcessor;

  PageTransitionsBuilder? defaultPageTransaction;

  NavigatorRoute.fromInfo(this.path, this.handler,
      {this.pathRegEx,
      this.responseProcessor,
      this.defaultPageTransaction = const OpenUpwardsPageTransitionsBuilder(),
      List<RouteInterceptor>? after,
      List<RouteInterceptor>? before})
      : pathSegments = pathToSegments(path),
        _before = before ?? [],
        _after = after ?? [] {
    for (int i = 0; i < pathSegments.length; i++) {
      String seg = pathSegments.elementAt(i);
      if (seg.startsWith(':')) {
        if (i == pathSegments.length - 1 && seg.endsWith('*')) {
          _pathGlobVarMapping = i;
          _pathGlobVarName = seg.substring(1, seg.length - 1);
        } else {
          seg = seg.substring(1);
          if (seg.isNotEmpty) _pathVarMapping[seg] = i;
        }
      }
    }
  }

  Future<void> call(Context ctx) {
    ctx.route = this;

    ctx.before.addAll(_before);
    ctx.after.addAll(_after);

    for (String pathParam in _pathVarMapping.keys) {
      ctx.pathParams[pathParam] = ctx.pathSegments[_pathVarMapping[pathParam]!];
    }
    if (_pathGlobVarMapping != null) {
      ctx.pathParams[_pathGlobVarName!] =
          ctx.pathSegments.skip(_pathGlobVarMapping!).join('/');
    }
    return ctx.execute();
  }

  List<RouteInterceptor> getBefore() => _before.toList();

  List<RouteInterceptor> getAfter() => _after.toList();

  /// Add [interceptor] and optionally [interceptors] to be executed before
  /// [handler] in the route chain.
  void before(RouteInterceptor interceptor,
      [List<RouteInterceptor>? interceptors]) {
    _before.add(interceptor);
    if (interceptors != null) {
      _before.addAll(interceptors);
    }
  }

  /// Add [interceptor] and optionally [interceptors] to be executed after
  /// [handler] in the route chain.
  void after(RouteInterceptor interceptor,
      [List<RouteInterceptor>? interceptors]) {
    _after.add(interceptor);
    if (interceptors != null) {
      _after.addAll(interceptors);
    }
  }

  String toString() => '$path';
}
