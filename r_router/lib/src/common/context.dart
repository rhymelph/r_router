import 'package:flutter/material.dart' hide Route;

import 'params.dart';
import 'navigator_route.dart';

class Context {
  final DateTime at;
  final Uri uri;
  dynamic body;

  Context(this.uri,
      {required this.before, required this.after, this.body, DateTime? at})
      : at = at ?? DateTime.now();

  List<String> get pathSegments => uri.pathSegments;

  final pathParams = PathParams();

  QueryParams? _query;

  QueryParams get query => _query ??= QueryParams(uri.queryParameters);

  NavigatorRoute? route;

  WidgetBuilder? builder;

  /// Interceptors that shall be executed before route handler is executed.
  final List<RouteInterceptor> before;

  /// Interceptors that shall be executed after route handler is executed.
  ///
  /// These interceptors are executed in the reverse order of registration.
  final List<RouteInterceptor> after;

  Future<void> execute() async {
    dynamic maybeFuture;
    for (int i = 0; i < before.length; i++) {
      maybeFuture = before[i](this);
      if (maybeFuture is Future) await maybeFuture;
    }

    {
      final info = route;
      dynamic res = route!.handler(this);
      if (res is Future) res = await res;
      if (res is Widget) {
        builder = (BuildContext context) => res;
      } else if (res is WidgetBuilder) {
        builder = res;
      } else {
        if (builder == null) {
          if (info?.responseProcessor != null) {
            maybeFuture = info!.responseProcessor!(this, res);
            if (maybeFuture is Future) await maybeFuture;
          }
        }
      }
    }
    for (int i = after.length - 1; i >= 0; i--) {
      maybeFuture = after[i](this);
      if (maybeFuture is Future) await maybeFuture;
    }
  }
}
